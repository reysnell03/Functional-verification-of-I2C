interface i2c_if #(
    int i2c_DATA_WIDTH = 8,
    int i2c_ADDR_WIDTH = 7,
    int i2c_BUS =1
)
(
        input wire [i2c_BUS-1:0] sda_input,
        input wire[i2c_BUS-1:0] scl_input,
        output reg[i2c_BUS-1:0] sda_output,
        output reg[i2c_BUS-1:0] scl_output
);

logic Start,Stop;
bit [i2c_ADDR_WIDTH-1:0] reg_adr;
bit [i2c_DATA_WIDTH-1:0] reg_data;
bit [i2c_DATA_WIDTH-1:0] read;
bit [i2c_DATA_WIDTH-1:0] mdata_reg;
bit [i2c_DATA_WIDTH-1:0] mread_reg;
bit [i2c_ADDR_WIDTH-1:0] temp;
bit control=1;
bit driver=0;
bit value;
bit monitor_old_value;
int i,j,k,l,m,n,size;
integer saddr=7'b0100010;

//*************************************************************************************************************
assign sda_output=control?sda_input:driver;                     //Controling the SDA output 
//*************************************************************************************************************

//***************Determining Start and Stop condition using specification sheet.*****************************
task check();
fork   
@(negedge sda_input)
    begin
        if(scl_input)begin
            Start=1;
            Stop=0;
            end
    end
@(posedge sda_input)
    begin
        if(scl_input)
            Stop=1;
            Start=0;
    end
join_any
endtask

 initial
    begin
      forever
        begin
          check();
        end
    end


task wait_for_i2c_transfer(output bit op,output bit [i2c_DATA_WIDTH-1:0]write_data[$]);
    begin
        control=1;
        driver=1'b0;
        //$display("waiting for start condition insdie wait for i2c task");
        wait(Start)
        //$display("got Start");
        begin
         for(int i=6;i>=0;i=i-1)begin                              //Capturing Address 
          // $display("In for loop");
            @(posedge scl_input);begin
            control=1;
            reg_adr[i]=sda_input;
          //  $display("Waiting for the address to come from SDA_input");
            end
         end
        end
        begin
             @(posedge scl_input);
                op=sda_input;
        end

        begin
        @(posedge scl_input);
            control=0;
        end

        if(op==0)
            begin
                forever
                    begin
                   // $display("enterd forever again in wait for i2c"); 
                        @(posedge scl_input)
                            begin
                            control=1;
                            value=sda_input;
                            end
                        @(negedge scl_input)
                            begin
                                if(Start||Stop)
                                    begin
                                        Stop=0;
                                        break;
                                    end
                                else
                                    begin
                                    reg_data[7]=value;
                                    end
                            end

                            if(op==1'b0 && saddr == reg_adr)
                                begin
                                    for(int i=6;i>=0;i=i-1)begin
                                    @(posedge scl_input);begin
                                    reg_data[i]=sda_input;
                                    end
                                    end
                                    write_data.push_front(reg_data);            //Writing the data to the address calculated earlier
                                    @(posedge scl_input)
                                    begin
                                        control=0;
                                    end
                            end         
                    end    
            end   
    end
endtask

task provide_read_data(input bit[i2c_DATA_WIDTH-1:0] read_data[$],output bit transfer_complete);
begin
    size=read_data.size();
    for(int i=0;i<size;i++)begin
        begin
            if(Start||Stop)
                begin
                Stop=0;
                break;
                end
                 read=read_data.pop_back();
                for(int i=7;i>=0;i--)begin
                    @(negedge scl_input);begin
                            control=0;
                            driver=read[i];
                    end
                end
                @(negedge scl_input);
                    control=1;
                @(posedge scl_input);
        end
        transfer_complete=1;
        end
end 
endtask

task monitor (output bit [i2c_ADDR_WIDTH-1:0] addr,output bit op, output bit [i2c_DATA_WIDTH-1:0] data[$]);
    begin
        wait(Start);
        data.delete();
        begin
                begin
                    for(int i=6;i>=0;i=i-1)begin
                    @(posedge scl_input); begin
                    addr[i]=sda_input;
                    end
                    end
                  // $write("Address is %h \n",reg_adr);
                end
                begin
                    @(posedge scl_input);
                    begin
                    op=sda_input;
                    end
                    // if(op==0)
                    // //$write("Operation to do is Write \n");
                    // else
                    // //$write("Operation to do is Read \n");
                end

                begin
                    if(saddr!=addr)
                        begin
                            $write("Error \n ");
                        end
                        begin
                        @(posedge scl_input);
                        end
                end

                if(op==0)
                    begin
                        forever
                            begin
                                @(posedge scl_input)
                                    begin
                                        monitor_old_value = sda_input;
                                    end
                                @(negedge scl_input)
                                    begin
                                        if(Start || Stop)
                                            begin   
                                                break;
                                            end
                                        else
                                            begin
                                                mdata_reg[7]=value;
                                            end
                                    end
                                    if(op==1'b0 && saddr==addr)
                                        begin
                                            begin
                                            for(m=6; m>=0; m--)
                                                    begin
                                                    @(posedge scl_input);
                                                        begin
                                                        mdata_reg[m]=sda_input;
                                                        end
                                                        end
                                                end
                                              data.push_front(mdata_reg);
                                            @(posedge scl_input);
                                            begin
                                            end
                                         end
                             end
                    end
                else if(op==1)
                begin
                    @(posedge scl_input);
                            for(int i=0;i<size;i++)
                            begin
                                if(Start || Stop)
                                 begin
                                    break;
                                    end
                                  for(int n=7;n>=0;n=n-1)begin
                                @(negedge scl_input)
                                     begin
                                     mread_reg[n]=sda_output;
                                 end
                                 end
			                            	data.push_front(mread_reg);
                                    @(negedge scl_input);
                           end
                    end
        end                            
    end
    endtask
    endinterface



