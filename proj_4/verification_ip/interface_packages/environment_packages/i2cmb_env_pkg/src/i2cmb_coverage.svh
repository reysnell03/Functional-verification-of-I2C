class coverage extends ncsu_component#(.T(wb_transaction));

  env_configuration     configuration;
  //abc_transaction_base  covergae_transaction;
  //header_type_t         header_type;
  //bit                   loopback;
  //bit                   invert;
bit[3:0] wb_add;
bit[1:0] wb_op;
bit[1:0] i2_op;
bit [7:0] i2c_transfer;
bit [7:0] wb_data;
bit [4:0] i2_addr;
int i2_transfer;

  covergroup env_covrg;
    option.per_instance = 1;
    option.name = get_full_name();
  	wb_addr_off: coverpoint wb_add      //coverpoint for addr
    {
      bins addr_bin_0 = {0};
      bins addr_bin_1 = {[1:$]};
      bins wb_addr_other =  default;
    }
    wb_operation: coverpoint wb_op      //coverpoint for operation
    {
      bins op_high = {1};
      bins op_low = {0};
      bins op_other = default;
    }
    wb_addXop:cross wb_addr_off,wb_operation;      //cross of addr and operation
  endgroup

  /* covergroup dpr_covrg;
     dpr_value: coverpoint wb_data;                //Removed 
   endgroup*/      

  covergroup i2c_coverage;
    i2c_addr: coverpoint i2_addr    
    {
      bins addr_bin_3 = {[0:$]};
      bins i2c_addr_other = default;
    }
    i2c_op: coverpoint i2_op
    {
      bins op_read = {1};
      bins op_write = {0};
    }
    i2c_transfer: coverpoint i2_transfer          //Coverpoint for data
    {
      bins data_bin_1 = {0};
      bins data_bin_2 = {[1:$]};
      bins i2c_data_other = default;
    }
    i2c_addXop: cross i2c_addr, i2c_op;
    i2c_addXtransfer: cross i2c_addr,i2c_transfer;        //Cross for data and addr
  endgroup

  function void set_configuration(env_configuration cfg);
  	configuration = cfg;
  endfunction

  function new(string name = "", ncsu_component_base parent = null); 
    super.new(name,parent);
    env_covrg = new;
   // dpr_covrg = new;
    i2c_coverage = new;
  endfunction

  virtual function void nb_put(T trans);
    /*$display({get_full_name()," ",trans.convert2string()});
    header_type = header_type_t'(trans.header[63:60]);
    loopback    = configuration.loopback;
    invert      = configuration.invert;*/
    wb_add = trans.addr;
    wb_op = trans.we;
    i2_addr = trans.addr;
    i2_transfer = trans.data[7];
    i2_op = trans.we;
    env_covrg.sample();
   // dpr_covrg.sample();
    i2c_coverage.sample();
  endfunction

endclass
