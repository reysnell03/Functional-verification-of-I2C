class i2c_driver extends ncsu_component#(.T(i2c_transaction));

  function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
  endfunction

  virtual i2c_if bus_i2c;
  i2c_configuration config_i2c;
  i2c_transaction i2c_trans;

  function void set_configuration(i2c_configuration cfg_i2c);
    config_i2c = cfg_i2c;
  endfunction
  
  virtual task bl_put(T trans);
   // $display("addr in driver:%x",trans.addr);
    //$display({get_full_name()," ",trans.convert2string()});
    bus_i2c.wait_for_i2c_transfer(trans.op,trans.data);
    if(trans.op==1)begin
      bus_i2c.provide_read_data(trans.read_data,trans.transfer_complete);
  end
  endtask
endclass

