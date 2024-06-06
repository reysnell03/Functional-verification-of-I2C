make clean
make compile
#make run_cli
make run_cli GEN_TRANS_TYPE=i2cmb_generator_test TEST_SEED=1234567890
make merge_coverage
make view_coverage
