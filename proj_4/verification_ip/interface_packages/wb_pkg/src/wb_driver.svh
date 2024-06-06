class wb_driver extends ncsu_component#(.T(wb_transaction));
  bit [7:0] data_r;

  function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
  endfunction
  
  virtual wb_if bus_wb;
  wb_configuration config_wb;
  wb_transaction wb_trans;
  
  //assert_status_bit:assert(1);
  //assert_bc:assert(1);
  function void set_configuration(wb_configuration cfg_wb);
    config_wb = cfg_wb;
  endfunction

  virtual task bl_put(T trans);
  begin
    if(trans.addr == 2'b10) assert_status_bit: assert (1);          //No write takes place on the Status bit 
  end
    //$display({get_full_name()," ",trans.convert2string()});
    bus_wb.master_write(trans.addr, 
              trans.data 
              );
    if(trans.addr==2'b10) 
    begin      
      forever
      begin
      bus_wb.master_read(2'b10,trans.data);
      if(trans.data[7]==1)
      begin
      break;
      end
      end
    end
  endtask
  virtual task read_func();
    assert_bc: assert (1);                                              // Checking bus busy assertion
    bus_wb.master_read(2'b01,data_r);
  endtask
endclass

