class predictor extends ncsu_component#(.T(wb_transaction));

  ncsu_component#(i2c_transaction) scoreboard;
  i2c_transaction transport_trans;
  i2c_transaction i2c_pred_transaction;
  env_configuration configuration;
  
  bit [7:0] temp_op;
  bit [7:0] temp_d[$];
  bit Start;
  bit Stop;
  

  function new(string name = "", ncsu_component_base  parent = null); 
      super.new(name,parent);
        $cast(transport_trans,ncsu_object_factory::create("i2c_transaction"));
        $cast(i2c_pred_transaction,ncsu_object_factory::create("i2c_transaction"));
  endfunction

    function void set_configuration(env_configuration cfg);
    configuration = cfg;
  endfunction

  virtual function void set_scoreboard(ncsu_component #(i2c_transaction) scoreboard);
      this.scoreboard = scoreboard;
  endfunction

  virtual function void nb_put(T trans);
       Start=0;
       Stop=0;
        if(trans.addr==2'd2 && trans.data[2:0]==3'b110)
          begin
            temp_d.delete();
           end
           
        if(trans.addr==2'd2 && trans.data[2:0]==3'b100)
        begin
            Start=1;
        end
          if(trans.addr == 2'd2 && trans.data[2:0]==3'b101)
          begin
            Stop=1;
          end

        if(trans.addr==2'd1)
          begin
              temp_d.push_front(trans.data);
          end

        if(temp_d.size()!=0 && (Start||Stop))
          begin
                temp_op = temp_d[temp_d.size()-1];
              i2c_pred_transaction.addr =temp_op [7:1];
              i2c_pred_transaction.op = temp_op [0];
              temp_d.delete(temp_d.size()-1);
              i2c_pred_transaction.data=temp_d;
              scoreboard.nb_transport(i2c_pred_transaction, transport_trans);
    
              Start=0;
              Stop=0;
              temp_d.delete();
          end
  endfunction

endclass

