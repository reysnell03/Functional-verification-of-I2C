class i2c_monitor extends ncsu_component#(.T(i2c_transaction));

  i2c_configuration  config_i2c;
  virtual i2c_if bus_i2c;

  T monitored_trans;
  ncsu_component #(T) agent_i2c;

  function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
  endfunction

  function void set_configuration(i2c_configuration cfg_i2c);
    config_i2c = cfg_i2c;
  endfunction

  function void set_agent(ncsu_component#(T) agent_i2c);
    this.agent_i2c = agent_i2c;
  endfunction
  
  virtual task run ();
        forever 
        begin
          monitored_trans = new("monitored_trans");
              if ( enable_transaction_viewing)
               begin
                     monitored_trans.start_time = $time;
                end
          bus_i2c.monitor(monitored_trans.addr,
                    monitored_trans.op,
                      monitored_trans.data
                    );
                    
                   // $display("i2c_monitor address is: %x",monitored_trans.addr);          //debug line    
         
        if(monitored_trans.op==1)
          begin
              #500000;
          end
        agent_i2c.nb_put(monitored_trans);
        if ( enable_transaction_viewing) 
        begin
           monitored_trans.end_time = $time;
           monitored_trans.add_to_wave(transaction_viewing_stream);
        end
    end
  endtask

endclass

