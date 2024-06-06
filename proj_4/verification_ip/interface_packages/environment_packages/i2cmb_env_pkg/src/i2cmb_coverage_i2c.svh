class i2cmb_coverage_i2c extends ncsu_component #(.T(i2c_transaction));
bit[1:0]i2_op;
bit[4:0]i2_addr;
int i2_transfer;

covergroup i2c_coverage;
	i2c_addr: coverpoint i2_addr;
	i2c_op: coverpoint i2_op;
	i2c_transfer: coverpoint i2_transfer;
	i2c_addXop: cross i2c_addr,i2c_op;
	i2c_addXtransfer :cross i2c_addr,i2c_transfer;

endgroup
endclass
