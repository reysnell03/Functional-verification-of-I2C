class coverage extends ncsu_component#(.T(wb_transaction));

  env_configuration     configuration;
  //abc_transaction_base  covergae_transaction;
  //header_type_t         header_type;
  //bit                   loopback;
  //bit                   invert;
bit[3:0] wb_add;
bit[1:0] wb_op;
bit[1:0] i2_op;
bit [7:0] wb_data;
bit [4:0] i2_addr;
int i2_transfer;

  covergroup env_covrg;
  	wb_addr_off: coverpoint wb_add;
    wb_operation: coverpoint wb_op;
    wb_addXop:cross wb_addr_off,wb_operation;
  endgroup

   covergroup dpr_covrg;
     dpr_value: coverpoint wb_data;
   endgroup

  covergroup i2c_coverage;
    i2c_addr: coverpoint i2_addr;
    i2c_op: coverpoint i2_op;
    i2c_transfer: coverpoint i2_transfer;
    i2c_addXop: cross i2c_addr, i2c_op;
    i2c_addXtransfer: cross i2c_addr,i2c_transfer;
  endgroup

  function void set_configuration(env_configuration cfg);
  	configuration = cfg;
  endfunction

  function new(string name = "", ncsu_component_base parent = null); 
    super.new(name,parent);
    env_covrg = new;
    dpr_covrg = new;
    i2c_coverage = new;
  endfunction

  virtual function void nb_put(T trans);
    /*$display({get_full_name()," ",trans.convert2string()});
    header_type = header_type_t'(trans.header[63:60]);
    loopback    = configuration.loopback;
    invert      = configuration.invert;*/
    env_covrg.sample();
    dpr_covrg.sample();
    i2c_coverage.sample();
  endfunction

endclass
