class i2c_agent extends ncsu_component#(.T(i2c_transaction));

  i2c_configuration config_i2c;
  i2c_driver        drv_i2c;
  i2c_monitor       mntr_i2c;
  //i2c_coverage      cvrg_i2c;
  ncsu_component #(T) subscribers[$];
  virtual i2c_if    bus_i2c;
  parameter int i2c_ADDR_WIDTH = 7;
  parameter int i2c_DATA_WIDTH = 8;
  parameter int i2c_BUS =1;

  function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
    if ( !(ncsu_config_db#(virtual i2c_if#(.ADDR_WIDTH(i2c_ADDR_WIDTH),.DATA_WIDTH(i2c_DATA_WIDTH),.i2c_num_buses(i2c_BUS)))::get(get_full_name(), this.bus_i2c))) begin;
      $display("i2c_agent::ncsu_config_db::get() call for BFM handle failed for name: %s ",get_full_name());
      $finish;
    end
  endfunction

  function void set_configuration(i2c_configuration cfg_i2c);
    config_i2c = cfg_i2c;
  endfunction

  virtual function void build();
    drv_i2c = new("driver",this);
    drv_i2c.set_configuration(config_i2c);
    drv_i2c.build();
    drv_i2c.bus_i2c = this.bus_i2c;
   /* if ( configuration.collect_coverage) begin
      coverage = new("coverage",this);
      coverage.set_configuration(configuration);
      coverage.build();
      connect_subscriber(coverage);
    end*/
    mntr_i2c = new("monitor",this);
    mntr_i2c.set_configuration(config_i2c);
    mntr_i2c.set_agent(this);
    mntr_i2c.enable_transaction_viewing = 1;
    mntr_i2c.build();
    mntr_i2c.bus_i2c = this.bus_i2c;
  endfunction

  virtual function void nb_put(T trans);
    foreach (subscribers[i]) subscribers[i].nb_put(trans);
  endfunction

  virtual task bl_put(T trans);
    drv_i2c.bl_put(trans);
  endtask

  virtual function void connect_subscriber(ncsu_component#(T) subscriber);
    subscribers.push_back(subscriber);
  endfunction

  virtual task run();
     fork mntr_i2c.run(); join_none
  endtask

endclass




