class wb_monitor extends ncsu_component#(.T(wb_transaction));

  wb_configuration  config_wb;
  virtual wb_if bus_wb;

  T monitored_trans;
  ncsu_component #(T) agent_wb;

  function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
  endfunction

  function void set_configuration(wb_configuration cfg_wb);
    config_wb = cfg_wb;
  endfunction

  function void set_agent(ncsu_component#(T) agent_wb);
    this.agent_wb = agent_wb;
  endfunction
  
  virtual task run ();
    bus_wb.wait_for_reset();
      forever begin
        monitored_trans = new("monitored_trans");
        if ( enable_transaction_viewing)
        begin
           monitored_trans.start_time = $time;
        end
        bus_wb.master_monitor(monitored_trans.addr,
                    monitored_trans.data,
                    monitored_trans.we
                    );
       /* $display("%s abc_monitor::run() header 0x%x payload 0x%p trailer 0x%x delay 0x%x",
                 get_full_name(),
                 monitored_trans.header, 
                 monitored_trans.payload, 
                 monitored_trans.trailer, 
                 monitored_trans.delay
                 );*/
        agent_wb.nb_put(monitored_trans);
       if ( enable_transaction_viewing)
         begin
           monitored_trans.end_time = $time;
           monitored_trans.add_to_wave(transaction_viewing_stream);
        end
    end
  endtask

endclass

