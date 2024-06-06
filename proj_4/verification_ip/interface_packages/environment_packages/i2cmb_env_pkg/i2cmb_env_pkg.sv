//`include "../../ncsu_pkg/ncsu_macros.svh"
//`include "../../interface_packages/i2c_pkg/i2c_pkg.sv"

package i2cmb_env_pkg;
import ncsu_pkg::*;
import wb_pkg::*;
import i2c_pkg::*;


`include "src/i2cmb_env_configuration.svh"
`include "src/i2cmb_coverage.svh"
`include "src/i2cmb_generator.svh"
`include "src/i2cmb_predictor.svh"
`include "src/i2cmb_scoreboard.svh"
`include "src/i2cmb_environment.svh"
`include "src/i2cmb_test.svh"
`include "src/i2cmb_generator_test.svh"
`include "src/i2cmb_coverage_i2c.svh"
`include "src/i2cm_coverage_wb.svh"


endpackage
