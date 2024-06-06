class i2cmb_generator_test extends generator;
//`ncsu_register_object(i2cmb_generator_test)

bit err_bit;
bit value;

function new(string name = "",ncsu_component_base parent = null);
  super.new(name,parent);
endfunction

virtual task run();
  begin
    fork
      begin
        transaction_wb.we=1;                            //Enabling the core 
        transaction_wb.addr=2'd1;                       //Enabling the core 
        transaction_wb.data=8'h0f;                      //Enabling the core 
        agent_wb.bl_put(transaction_wb);                //Enabling the core 
         
                
        transaction_wb.we=1;                            //set bus command.
        transaction_wb.addr=2'b10;                      //set bus command.
        transaction_wb.data=8'bxxxxx110;                //set bus command.
        agent_wb.bl_put(transaction_wb);                //set bus command.
        
        transaction_wb.we=1;                            //Start Command.
        transaction_wb.addr=2'b10;                      //Start Command.
        transaction_wb.data=8'bxxxxx100;                //Start Command.
        agent_wb.bl_put(transaction_wb);                //Start Command.
        
        
        if (err_bit == 1) value: assert(1);            // The ERR bit is high that means the bus is given invalid ID
        
        
        transaction_wb.we=1;                              //Stop Command to CMDR
        transaction_wb.addr=2'b10;                        //Stop Command to CMDR
        transaction_wb.data=8'bxxxxx101;                  //Stop Command to CMDR
        agent_wb.bl_put(transaction_wb);                  //Stop Command to CMDR
      end
    join_any
  end        
endtask


endclass
