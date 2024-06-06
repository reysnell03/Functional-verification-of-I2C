class i2cmb_coverage_wb extends ncsu_component #(.T(wb_transaction));
bit[3:0]wb_add;
bit[1:0]wb_op;

	covergroup env_covrg;
	wb_addr_off: coverpoint wb_add;
	wb_operation: coverpoint wb_op;
	wb_addXop:cross wb_addr_off,wb_operation;
	endgroup	


	covergroup DPR_covrg;

	endgroup

endclass
