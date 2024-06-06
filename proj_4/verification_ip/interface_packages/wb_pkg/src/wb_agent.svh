class wb_agent extends ncsu_component#(.T(wb_transaction));

  wb_configuration config_wb;
  wb_driver        drv_wb;
  wb_monitor       mntr_wb;
 // wb_coverage      cvrg_wb;                          //proj3 part
  ncsu_component #(T) subscribers[$];
  virtual wb_if    bus_wb;
  parameter int WB_ADDR_WIDTH = 2;
  parameter int WB_DATA_WIDTH = 8;

  function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
    if ( !(ncsu_config_db#(virtual wb_if #(.ADDR_WIDTH(WB_ADDR_WIDTH),.DATA_WIDTH(WB_DATA_WIDTH)))::get(get_full_name(), this.bus_wb))) begin;
      $display("wb_agent::ncsu_config_db::get() call for BFM handle failed for name: %s ",get_full_name());
      $finish;
    end
  endfunction

  function void set_configuration(wb_configuration cfg_wb);
    config_wb = cfg_wb;
  endfunction

  virtual function void build();
    drv_wb = new("driver",this);
    drv_wb.set_configuration(config_wb);
    drv_wb.build();
    drv_wb.bus_wb = this.bus_wb;
    /*if ( configuration.collect_coverage) begin          //proj3 part
      coverage = new("coverage",this);
      coverage.set_configuration(configuration);
      coverage.build();
      connect_subscriber(coverage);
    end*/
    mntr_wb = new("monitor",this);
    mntr_wb.set_configuration(config_wb);
    mntr_wb.set_agent(this);
    mntr_wb.enable_transaction_viewing = 1;
    mntr_wb.build();
    mntr_wb.bus_wb = this.bus_wb;
  endfunction

  virtual function void nb_put(T trans);
    foreach (subscribers[i]) subscribers[i].nb_put(trans);
  endfunction

  virtual task bl_put(T trans);
    drv_wb.bl_put(trans);
  endtask

   virtual task read_func();     //check not there
    drv_wb.read_func();        //check not there
  endtask                         //check not there(abc)

  virtual function void connect_subscriber(ncsu_component#(T) subscriber);
    subscribers.push_back(subscriber);
  endfunction

  virtual task run();
     fork mntr_wb.run(); join_none
  endtask

endclass



