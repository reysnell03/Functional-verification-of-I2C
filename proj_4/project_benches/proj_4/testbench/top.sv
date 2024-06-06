`timescale 1ns / 10ps
module top();
  import ncsu_pkg::*;
  import wb_pkg::*;
  import i2c_pkg::*;
  import i2cmb_env_pkg::*;



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
  string test_name;
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

    test_base tst;
    i2cmb_generator_test tst1;
  // ****************************************************************************
  // Monitor Wishbone bus and display transfers in the transcript
  // ****************************************************************************
  
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
    .irq_i(irq),
    // Shred signals
    .dat_o(dat_wr_o),
    .dat_i(dat_rd_i)
  );

  // ****************************************************************************
  i2c_if       #(
    .i2c_ADDR_WIDTH(i2c_ADDR_WIDTH),
    .i2c_DATA_WIDTH(i2c_DATA_WIDTH),
    .i2c_BUS(i2c_BUS)
  )
  i2c_bus (
    .scl_input(scl),        
    .sda_input(sda_o),         
    .scl_output(),        
    .sda_output(sda_i)
  );

   initial begin : test_flow
   
   $value$plusargs("GEN_TRANS_TYPE=%s", test_name);
   $display("\n \n \n tran_name is %s \n \n \n",test_name);
   
   case (test_name)
   
   "test1":
   begin
     ncsu_config_db#(virtual i2c_if)::set("tst1.env.agent_i2c",i2c_bus);
     ncsu_config_db#(virtual wb_if)::set("tst1.env.agent_wb",wb_bus);
     tst1 = new("tst1",null);
     wait(rst == 0);
     tst1.run();
   end
   
   
   default:
   begin
     ncsu_config_db#(virtual i2c_if)::set("tst.env.agent_i2c",i2c_bus);
     ncsu_config_db#(virtual wb_if)::set("tst.env.agent_wb",wb_bus);
     tst = new("tst",null);
     wait(rst == 0);
     tst.run();
   end
   endcase
    #100ns
    $display("***************************** Simulation Finished *****************************");
     $finish();
  end

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



