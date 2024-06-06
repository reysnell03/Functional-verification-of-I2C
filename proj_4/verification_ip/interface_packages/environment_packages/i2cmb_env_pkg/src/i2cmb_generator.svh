class generator extends ncsu_component#(.T(ncsu_transaction));


  wb_transaction transaction_wb;
  i2c_transaction transaction_i2c;
 
  wb_agent agent_wb;
  i2c_agent agent_i2c;
  bit [7:0] hold;
  int i=64;
  int j=63;
  int k;
  int r=0;

  function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
    /*if ( !$value$plusargs("GEN_TRANS_TYPE=%s", trans_name)) begin
      $display("FATAL: +GEN_TRANS_TYPE plusarg not found on command line");
      $fatal;
    end
    $display("%m found +GEN_TRANS_TYPE=%s", trans_name);*/
  endfunction

virtual task run();
    begin
      fork
        begin
          $cast(transaction_wb,ncsu_object_factory::create("wb_transaction"));
      //*************************** setting up core for operation ********************************

          transaction_wb.we=1;                            //Enabling the core 
          transaction_wb.addr=2'b0;                       //Enabling the core 
          transaction_wb.data=8'b1xxxxxxx;                //Enabling the core 
          agent_wb.bl_put(transaction_wb);                //Enabling the core 
         
                
          transaction_wb.we=1;                            //set bus command.
          transaction_wb.addr=2'b10;                      //set bus command.
          transaction_wb.data=8'bxxxxx110;                //set bus command.
          agent_wb.bl_put(transaction_wb);                //set bus command.
 
          transaction_wb.we=1;                            //Start Command.
          transaction_wb.addr=2'b10;                      //Start Command.
          transaction_wb.data=8'bxxxxx100;                //Start Command.
          agent_wb.bl_put(transaction_wb);                //Start Command.
     
          transaction_wb.we=1;                            //Writing 0x44 to DPR (This is Slave address 22)
          transaction_wb.addr=2'd1;                       //Writing 0x44 to DPR (This is Slave address 22)
          transaction_wb.data=8'h44;                      //Writing 0x44 to DPR (This is Slave address 22)
          agent_wb.bl_put(transaction_wb);                //Writing 0x44 to DPR (This is Slave address 22)

          transaction_wb.we=1;                            //Write Command to CMDR.
          transaction_wb.addr=2'd2;                       //Write Command to CMDR.
          transaction_wb.data=8'bxxxxx001;                //Write Command to CMDR.
          agent_wb.bl_put(transaction_wb);                //Write Command to CMDR.
          
          
         //********************************************** Writing operation from 0 to 31 ********************************************
         $display("****************************************** Writing from 0 to 31 ******************************************");

          begin
          for(k=0; k<32; k++)
            begin
              transaction_wb.we=1;                          // Writing the value of k to the DPR
              transaction_wb.addr=2'b01;                    // Writing the value of k to the DPR
              transaction_wb.data=k;                        // Writing the value of k to the DPR
              agent_wb.bl_put(transaction_wb);              // Writing the value of k to the DPR

              transaction_wb.we=1;                          //Write Command to CMDR
              transaction_wb.addr=2'b10;                    //Write Command to CMDR
              transaction_wb.data=8'bxxxxx001;              //Write Command to CMDR
              agent_wb.bl_put(transaction_wb);              //Wrtie Command to CMDR
              //$display("write done");
            end
            
          if(k == 32) write_assert:assert(1);
          end
          
          transaction_wb.we=1;                              //Stop Command to CMDR
          transaction_wb.addr=2'b10;                        //Stop Command to CMDR
          transaction_wb.data=8'bxxxxx101;                  //Stop Command to CMDR
          agent_wb.bl_put(transaction_wb);                  //Stop Command to CMDR
        end
        
        
        
        begin
          $cast(transaction_i2c,ncsu_object_factory::create("i2c_transaction"));
          agent_i2c.bl_put(transaction_i2c);
        end
      join_any

//**************************** Reading values from 100 to 131 ******************************************************

      fork
        begin
          transaction_wb.we=1;                            //Start Command
          transaction_wb.addr=2'b10;                      //Start Command
          transaction_wb.data=8'bxxxxx100;                //Start Command
          agent_wb.bl_put(transaction_wb);                //Start Command


            transaction_wb.we=1;                             // Writing 0x45 to DPR to shift slave address by 1 bit + 1 to the rightmost bit meaning READ
            transaction_wb.addr=2'b01;                       // Writing 0x45 to DPR to shift slave address by 1 bit + 1 to the rightmost bit meaning READ
            transaction_wb.data=8'h45;                       // Writing 0x45 to DPR to shift slave address by 1 bit + 1 to the rightmost bit meaning READ
            agent_wb.bl_put(transaction_wb);                 // Writing 0x45 to DPR to shift slave address by 1 bit + 1 to the rightmost bit meaning READ

          transaction_wb.we=1;                            //Write Command
          transaction_wb.addr=2'b10;                      //Write Command
          transaction_wb.data=8'bxxxxx001;                //Write Command
          agent_wb.bl_put(transaction_wb);                //Write Command
          
          
          
          $display("******************************************Reading values from 100 to 131******************************************");
          begin
          for(int i=0;i<32;i++)
            begin
              transaction_wb.we=1;                        //Read CMDR with NAK
              transaction_wb.addr=2'b10;                  //Read CMDR with NAK
              transaction_wb.data=8'bxxxxx011;            //Read CMDR with NAK
              agent_wb.bl_put(transaction_wb);            //Read CMDR with NAK

  
              transaction_wb.we=0;                        // Reading values from DPR
              transaction_wb.addr=2'b01;                  // Reading values from DPR
              agent_wb.read_func();                       // Reading values from DPR
              r=r+1;
            end
          if(r == 32) read_assert: assert(1);
          end

          transaction_wb.we=1;                            //Stop command to CMDR
          transaction_wb.addr=2'b10;                      //Stop command to CMDR
          transaction_wb.data=8'bxxxxx101;                //Stop command to CMDR
          agent_wb.bl_put(transaction_wb);                //Stop command to CMDR
        end
        
        
        
        begin
          for(integer i=0; i<32; i++)
            begin
              hold=i+100;
              transaction_i2c.read_data.push_front(hold);
            end
          agent_i2c.bl_put(transaction_i2c);
        end
      join
      // ************************************************ Alternate Read and Write **********************************************************
    
          $display("******************************************Alternate Read and Write******************************************");


      fork
        begin

          repeat(64)
            begin
              transaction_i2c.read_data.delete();
              transaction_i2c.read_data.push_front(j);              //pushout the value stored in read_data

                transaction_wb.we=1;                                  //Start Command to start reading
                transaction_wb.addr=2'b10;                            //Start Command to start reading
                transaction_wb.data=8'bxxxxx100;                      //Start Command to start reading
                agent_wb.bl_put(transaction_wb);                      //Start Command to start reading

              transaction_wb.we=1;                                  //Selecting Slave address 22.
              transaction_wb.addr=2'b01;                            //Selecting Slave address 22.
              transaction_wb.data=8'h44;                            //Selecting Slave address 22.
              agent_wb.bl_put(transaction_wb);                      //Selecting Slave address 22.

                transaction_wb.we=1;                                  // Write command
                transaction_wb.addr=2'b10;                            // Write command
                transaction_wb.data=8'bxxxxx001;                      // Write command
                agent_wb.bl_put(transaction_wb);                      // Write command

              transaction_wb.we=1;                                  //Writing value of i to DPR
              transaction_wb.addr=2'b01;                            //Writing value of i to DPR
              transaction_wb.data=i;                                //Writing value of i to DPR
              agent_wb.bl_put(transaction_wb);                      //Writing value of i to DPR
  
                transaction_wb.we=1;                                  //write command
                transaction_wb.addr=2'b10;                            //write command
                transaction_wb.data=8'bxxxxx001;                      //write command
                agent_wb.bl_put(transaction_wb);                      //write command


              transaction_wb.we=1;                                  // Start Command to start reading 
              transaction_wb.addr=2'b10;                            // Start Command to start reading 
              transaction_wb.data=8'bxxxxx100;                      // Start Command to start reading 
              agent_wb.bl_put(transaction_wb);                      // Start Command to start reading 

                transaction_wb.we=1;                                  //Writing 0x45 to DPR to shift slave address by 1 bit + 1 to the rightmost bit meaning READ
                transaction_wb.addr=2'b01;                            //Writing 0x45 to DPR to shift slave address by 1 bit + 1 to the rightmost bit meaning READ
                transaction_wb.data=8'h45;                            //Writing 0x45 to DPR to shift slave address by 1 bit + 1 to the rightmost bit meaning READ
                agent_wb.bl_put(transaction_wb);                      //Writing 0x45 to DPR to shift slave address by 1 bit + 1 to the rightmost bit meaning READ

              transaction_wb.we=1;                                  //Write command.
              transaction_wb.addr=2'b10;                            //Write command.
              transaction_wb.data=8'bxxxxx001;                      //Write command.
              agent_wb.bl_put(transaction_wb);                      //Write command.

                transaction_wb.we=1;                                  //Read with a NACK
                transaction_wb.addr=2'b10;                            //Read with a NACK
                transaction_wb.data=8'bxxxxx011;                      //Read with a NACK
                agent_wb.bl_put(transaction_wb);                      //Read with a NACK

              transaction_wb.we=0;
              transaction_wb.addr=2'b01;
              agent_wb.read_func();


                      i=i+1;
                      j=j-1;

            end

  
            transaction_wb.we=1;                                    //Stop Command
            transaction_wb.addr=2'b10;                              //Stop Command
            transaction_wb.data=8'bxxxxx101;                        //Stop Command
            agent_wb.bl_put(transaction_wb);                        //Stop Command


        end

        

              begin
      
                repeat(128)
                  begin
                    agent_i2c.bl_put(transaction_i2c);
                  end
 
              end
            join
 

    end
  endtask
      
        function void set_agent_wb(wb_agent agent_wb);
          this.agent_wb = agent_wb;
        endfunction

     function void set_agent_i2c(i2c_agent agent_i2c);
      this.agent_i2c = agent_i2c;
    endfunction

endclass

