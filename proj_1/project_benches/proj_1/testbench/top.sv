`timescale 1ns / 10ps
module top();
  parameter int WB_ADDR_WIDTH = 2;
  parameter int WB_DATA_WIDTH = 8;
  parameter int i2c_BUS= 1;
  parameter int i2c_ADDR_WIDTH = 7;
  parameter int i2c_DATA_WIDTH = 8;


  bit  clk;
  bit  rst = 1'b1;
  wire cyc;
  wire stb;
  wire we;
  tri1 ack;
  wire [WB_ADDR_WIDTH-1:0] adr;
  wire [WB_DATA_WIDTH-1:0] dat_wr_o;
  wire [WB_DATA_WIDTH-1:0] dat_rd_i;
  wire irq;
  tri  [i2c_BUS-1:0] scl;
  logic  [WB_DATA_WIDTH-1:0] data_rd;
  bit [i2c_DATA_WIDTH-1:0] write_data [$];
  bit [i2c_DATA_WIDTH-1:0] read_data [$];
   bit [i2c_DATA_WIDTH-1:0] temp;
  bit [i2c_ADDR_WIDTH-1:0] monitor_addr;
  bit [i2c_DATA_WIDTH-1:0] monitor_data [$];
  bit transfer_complete;
  bit [7:0] i;
  bit [7:0] j=63;
  bit [7:0] k=64;
  bit monitor_op;
  bit op;
  integer l;
  wire sda_o;
  wire sda_i;
  // ****************************************************************************
  // Clock generator
  initial begin
      forever #10 clk=~clk; end 
    
  // ****************************************************************************
  // Reset generator
  initial
    begin
      #113 rst=0;
    end

  // ****************************************************************************
  // Monitor Wishbone bus and display transfers in the transcript
  // ****************************************************************************
  // Define the flow of the simulation
  // ****************************************************************************
    task wait_done();
     forever begin 
        if(irq ==1 )                                //Waiting for irq
         break;
        wb_bus.master_read(2'b10,data_rd);          //reading  DON bit of CMDR.
        if(data_rd[7]==1)                           //Checking is DON bit is 1.
         break;
      end
    endtask

     initial begin
      forever
        begin
          i2c_bus.check();
        end
        end


    initial
    begin
      forever
        begin
          i2c_bus.wait_for_i2c_transfer(op,write_data);
          if(op)
            begin
              i2c_bus.provide_read_data( read_data,transfer_complete);
            end
        end
    end

    initial
    begin
      forever
        begin
         i2c_bus.monitor(monitor_addr,monitor_op,monitor_data);
       end
    end

  //****************************Setting up the core and slave to start the transaction**************************************
  initial 
    begin
      wb_bus.master_write(2'b0,8'b1xxxxxxx);        //Enabling the core 
      wb_bus.master_write(2'b10,8'bxxxxx110);       //set bus command.
      
      // forever begin 
      //   if(irq ==1 )                                //Waiting for irq
      //    break;
      //   wb_bus.master_read(2'b10,data_rd);          //reading  DON bit of CMDR.
      //   if(data_rd[7]==1)                           //Checking is DON bit is 1.
      //    break;
      // end  
      wait_done();

      wb_bus.master_write(2'b10,8'bxxxxx100);       //Start Command.

      // forever begin 
      //   if(irq ==1 ) break;                         //Waiting for irq
      //   wb_bus.master_read(2'b10, data_rd);         //reading  DON bit of CMDR.
      //   if(data_rd[7]==1) break;                    //Checking is DON bit is 1.
      // end
      wait_done();
      wb_bus.master_write(2'b01,8'h44);              //Writing 0x44 to DPR (This is Slave address 22)
      wb_bus.master_write(2'b10,8'bxxxxx001);        //Write Command to CMDR.


      // forever begin                                
      //   if(irq ==1 ) break;                          //Waiting for irq
      //   wb_bus.master_read(2'b10,data_rd);           //reading  DON bit of CMDR.
      //   if(data_rd[7]==1) break;                     //Checking is DON bit is 1.
      // end
      wait_done();

//**********************************************Writing operation from 0 to 31********************************************
      $display("****************************************** Writing from 0 to 31 ******************************************");
      for(i=0; i<32; i++)
        begin
          wb_bus.master_write(2'b01,i);               // Writing the value of i to the DPR
          wb_bus.master_write(2'b10,8'bxxxxx001);     // Write Command to CMDR.

          // forever begin 
          //   if(irq ==1 ) break;                         //Waiting for irq
          //   wb_bus.master_read(2'b10,data_rd);          //reading  DON bit of CMDR.
          //   if(data_rd[7]==1) break;                    //Checking is DON bit is 1.
          // end
           wait_done();
        end

      wb_bus.master_write(2'b10,8'bxxxxx101);          //Stop Command to CMDR
       
      // forever begin                                    
      //   if(irq ==1 ) break;                             //Waiting for irq
      //   wb_bus.master_read(2'b10,data_rd);              //reading  DON bit of CMDR.
      //   if(data_rd[7]==1) break;                        //Checking is DON bit is 1.
      // end
       wait_done();
      #200000;
//***************************setting up core for operation********************************
      wb_bus.master_write(2'b10,8'bxxxxx100);            //Start Command

      // forever begin 
      //   if(irq ==1 ) break;                             //Waiting for irq
      //   wb_bus.master_read(2'b10,data_rd);              //reading  DON bit of CMDR.
      //   if(data_rd[7]==1) break;                        //Checking if DON bit is 1.
      // end

       wait_done();


      wb_bus.master_write(2'b01,8'h45);                 // Writing 0x45 to DPR to shift slave address by 1 bit + 1 to the rightmost bit meaning READ
      wb_bus.master_write(2'b10,8'bxxxxx001);           //Write Command

      // forever begin   
      //   if(irq ==1 ) break;                           // Wait for irq
      //   wb_bus.master_read(2'b10,data_rd);            // reading DON bit of CMDR.
      //   if(data_rd[7]==1) break;                      // Checking if DON bit 1.      
      // end
       wait_done();
      #200000;

//****************************Reading values from 100 to 131******************************************************
      $display("******************************************Reading values from 100 to 131******************************************");
      for(int i=0;i<32;i++)
        begin  
          wb_bus.master_write(2'b10,8'bxxxxx011);     //Read CMDR with NAK

          // forever begin 
          //   if(irq==1) break;                         // wait for irq.
          //   wb_bus.master_read(2'b10,data_rd);        //reading DON bit of CMDR.
          //   if(data_rd[7]==1) break;                  //Checking if DON bit is 1.
          // end
         wait_done();
          wb_bus.master_read(2'b1,data_rd);           // Reading values from DPR   
        end


      wb_bus.master_write(2'b10,8'bxxxxx101);          //Stop command to CMDR


      // forever begin   
      //   if(irq ==1 ) break;                           // wait for irq.
      //   wb_bus.master_read(2'b10,data_rd);            //reading DON bit of CMDR.
      //   if(data_rd[7]==1) break;                      //Checking if DON bit is 1.
      // end
       wait_done();
      read_data.delete();

      // **********************************************************************************************************
      $display("******************************************Alternate Read and Write******************************************");
        for(int i=0;i<64;i++)
        begin
          read_data.push_front(j);                        //pushout the value stored in read_data
         wb_bus.master_write(2'b10,8'bxxxxx100);         //Start Command to start reading

          // forever begin 
          //   if(irq ==1 ) break;                           // wait for irq.
          //   wb_bus.master_read(2'b10,data_rd);            //reading DON bit of CMDR.
          //   if(data_rd[7]==1) break;                      //Checking if DON bit is 1.
          // end
             wait_done();


          wb_bus.master_write(2'b01,8'h44);                //Selecting Slave address 22.
          wb_bus.master_write(2'b10,8'bxxxxx001);          // Write command 

          // forever begin 
          //   if(irq ==1 ) break;                            // wait for irq.
          //   wb_bus.master_read(2'b10,data_rd);             //reading DON bit of CMDR.
          //   if(data_rd[7]==1) break;                       //Checking if DON bit is 1.
          // end
           wait_done();

          wb_bus.master_write(2'b01,k);                   //Writing value of k to DPR
          wb_bus.master_write(2'b10,8'bxxxxx001);         //write command


          // forever begin 
          //   if(irq ==1 ) break;                           // wait for irq.
          //   wb_bus.master_read(2'b10,data_rd);            //reading DON bit of CMDR.
          //   if(data_rd[7]==1) break;                      //Checking if DON bit is 1.
          // end

           wait_done();

         wb_bus.master_write(2'b10,8'bxxxxx100);         // Start Command to start reading 

          // forever begin 
          //   if(irq ==1 ) break;                            // wait for irq.
          //   wb_bus.master_read(2'b10,data_rd);             //reading DON bit of CMDR. 
          //   if(data_rd[7]==1) break;                        //Checking if DON bit is 1.
          // end

           wait_done();

          wb_bus.master_write(2'b01,8'h45);               //Writing 0x45 to DPR to shift slave address by 1 bit + 1 to the rightmost bit meaning READ
          wb_bus.master_write(2'b10,8'bxxxxx001);         //Write command. 

          // forever begin 
          //   if(irq ==1 ) break;                           // wait for irq.
          //   wb_bus.master_read(2'b10,data_rd);            //reading DON bit of CMDR.
          //   if(data_rd[7]==1) break;                      //Checking if DON bit is 1.
          // end

           wait_done();

          wb_bus.master_write(2'b10,8'bxxxxx011);          //Read with a NACK
          // forever begin 
          //   wb_bus.master_read(2'b10,data_rd);
          //   if(data_rd[7]==1) break;
          // end
           wait_done();
          #200000;
          wb_bus.master_read(2'b01,data_rd);
          j=j-1;
          k=k+1;
          read_data.delete();
        end

      wb_bus.master_write(2'b10,8'bxxxxx101);               //Stop Command
      // forever begin 
      //   if(irq ==1 ) break;
      //   wb_bus.master_read(2'b10,data_rd);
      //   if(data_rd[7]==1) break;
      // end
         wait_done();

      $finish;
    end

  initial
    begin
      for(l=0; l<32; l++)
        begin
          temp=l+100;
          read_data.push_front(temp);
        end
      end

  // ****************************************************************************
  // Instantiate the Wishbone master Bus Functional Model
  wb_if       #(
    .ADDR_WIDTH(WB_ADDR_WIDTH),
    .DATA_WIDTH(WB_DATA_WIDTH)
  )
  wb_bus (
    // System sigals
    .clk_i(clk),
    .rst_i(rst),
    // Master signals
    .cyc_o(cyc),
    .stb_o(stb),
    .ack_i(ack),
    .adr_o(adr),
    .we_o(we),
    // Slave signals
    .cyc_i(),
    .stb_i(),
    .ack_o(),
    .adr_i(),
    .we_i(),
    // Shred signals
    .dat_o(dat_wr_o),
    .dat_i(dat_rd_i)
  );

  // ****************************************************************************
  i2c_if       #(
    .i2c_ADDR_WIDTH(i2c_ADDR_WIDTH),
    .i2c_DATA_WIDTH(i2c_DATA_WIDTH)
  )
  i2c_bus (
    .scl_input(scl),        
    .sda_input(sda_o),         
    .scl_output(),        
    .sda_output(sda_i)
  );

  // ****************************************************************************

  // Instantiate the DUT - I2C Multi-Bus Controller
  \work.iicmb_m_wb(str) #(.g_bus_num(i2c_BUS)) DUT
  (
    // ------------------------------------
    // -- Wishbone signals:
    .clk_i(clk),         // in    std_logic;                            -- Clock
    .rst_i(rst),         // in    std_logic;                            -- Synchronous reset (active high)
    // -------------
    .cyc_i(cyc),         // in    std_logic;                            -- Valid bus cycle indication
    .stb_i(stb),         // in    std_logic;                            -- Slave selection
    .ack_o(ack),         //   out std_logic;                            -- Acknowledge output
    .adr_i(adr),         // in    std_logic_vector(1 downto 0);         -- Low bits of Wishbone address
    .we_i(we),           // in    std_logic;                            -- Write enable
    .dat_i(dat_wr_o),    // in    std_logic_vector(7 downto 0);         -- Data input
    .dat_o(dat_rd_i),    //   out std_logic_vector(7 downto 0);         -- Data output
    // ------------------------------------
    // ------------------------------------
    // -- Interrupt request:
    .irq(irq),           //   out std_logic;                            -- Interrupt request
    // ------------------------------------
    // ------------------------------------
    // -- I2C interfaces:
    .scl_i(scl),         // in    std_logic_vector(0 to g_bus_num - 1); -- I2C Clock inputs
    .sda_i(sda_i),         // in    std_logic_vector(0 to g_bus_num - 1); -- I2C Data inputs
    .scl_o(scl),         //   out std_logic_vector(0 to g_bus_num - 1); -- I2C Clock outputs
    .sda_o(sda_o)          //   out std_logic_vector(0 to g_bus_num - 1)  -- I2C Data outputs
    // ------------------------------------
  );


endmodule


