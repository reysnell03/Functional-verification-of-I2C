export ECE745_PROJECT_HOME ?= $(PWD)/../../..

include $(ECE745_PROJECT_HOME)/verification_ip/interface_packages/ncsu_pkg/Makefile
include $(ECE745_PROJECT_HOME)/verification_ip/interface_packages/wb_pkg/Makefile
include $(ECE745_PROJECT_HOME)/verification_ip/interface_packages/i2c_pkg/Makefile
include $(ECE745_PROJECT_HOME)/verification_ip/interface_packages/environment_packages/i2cmb_env_pkg/Makefile


GEN_TRANS_TYPE ?= generator
test1name ?= i2cmb_generator_test
TEST_SEED ?= 1234567890
CLI_DO_COMMANDS = -do " \
                    set NoQuitOnFinish 1; \
                    run -all; \
                     do save_coverage.do $(GEN_TRANS_TYPE); \
                    quit -f;" 

DEBUG_DO_COMMANDS = -do " \
                    set NoQuitOnFinish 1; \
                    do wave.do;\
                    run -a;"\

clean: 
	rm -rf work *.wlf transcript qrun.out

comp_I2C_MB:
	vcom ../rtl/iicmb_int_pkg.vhd
	vcom ../rtl/iicmb_pkg.vhd
	vcom ../rtl/mbyte.vhd -cover bcsef
	vcom ../rtl/mbit.vhd -cover bcsef
	vcom ../rtl/bus_state.vhd
	vcom ../rtl/filter.vhd -cover bcsef
	vcom ../rtl/conditioner.vhd -cover bcsef
	vcom ../rtl/conditioner_mux.vhd -cover bcsef
	vcom ../rtl/iicmb_m.vhd
	vcom ../rtl/regblock.vhd
	vcom ../rtl/wishbone.vhd
	vcom ../rtl/iicmb_m_wb.vhd


comp_bench: comp_ncsu_pkg comp_wb_pkg comp_i2c_pkg comp_i2cmb_env_pkg 
	vlog -cover bcsef ../testbench/top.sv

optimize:
	vopt +acc top -o optimized_debug_top_tb

compile: comp_I2C_MB comp_bench optimize

simulate:
	vsim  -i -classdebug -msgmode both -do "set NoQuitOnFinish 1; do wave.do" optimized_debug_top_tb

debug_3step: clean compile simulate

run_cli:
ifeq ($(GEN_TRANS_TYPE),test1)
	vsim -c -coverage -do "set NoQuitOnFinish 1; run -all; coverage attribute -name TESTNAME -value $(test1name); coverage save $(test1name).ucdb; quit -f" +GEN_TRANS_TYPE=$(test1name) +GEN_SEQ_TYPE=$(GEN_SEQ_TYPE_DIR) optimized_debug_top_tb
else
	vsim -c -coverage -sv_seed $(TEST_SEED) $(CLI_DO_COMMANDS) +GEN_TRANS_TYPE=$(GEN_TRANS_TYPE) optimized_debug_top_tb
endif


run_gui: 
	vsim -coverage -sv_seed $(TEST_SEED) $(DEBUG_DO_COMMANDS) +GEN_TRANS_TYPE=$(GEN_TRANS_TYPE) optimized_debug_top_tb

cli: clean compile optimize run_cli

debug : clean compile optimize run_gui

merge_coverage:
	xml2ucdb -format Excel ./test_plan_layered_testbench.xml ./test_plan_layered_testbench.ucdb
	vcover merge -stats=none -strip 0 -totals sim_and_testplan_merged.ucdb ./*.ucdb

regress:
	./regress.sh

view_coverage:
	vsim -viewcov ./sim_and_testplan_merged.ucdb
