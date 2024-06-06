class i2c_transaction extends ncsu_transaction;
  `ncsu_register_object(i2c_transaction)

       bit [6:0] addr;
       bit [7:0] data[$];
       static bit [7:0] read_data [$];
       bit op;
       bit transfer_complete;

  function new(string name=""); 
    super.new(name);
  endfunction

  virtual function string convert2string();
     return {super.convert2string(),$sformatf("address:0x%x data:0x%p op:0x%x", addr, data, op)};
  endfunction

  function bit compare(i2c_transaction rhs);
    return ((this.addr  == rhs.addr ) && 
            (this.data == rhs.data) &&
            (this.op == rhs.op));
  endfunction

  virtual function void add_to_wave(int transaction_viewing_stream_h);
     super.add_to_wave(transaction_viewing_stream_h);
     $add_attribute(transaction_view_h,addr,"address");
     $add_attribute(transaction_view_h,op,"op");
     $add_attribute(transaction_view_h,transfer_complete,"transfer_complete");
     $end_transaction(transaction_view_h,end_time);
     $free_transaction(transaction_view_h);
  endfunction

endclass

