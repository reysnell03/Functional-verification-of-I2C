`include "../ncsu_pkg/ncsu_pkg.sv"
//`include "../ncsu_pkg/ncsu_macros.svh"

package i2c_pkg;
import ncsu_pkg::*;
`include"/mnt/ncsudrive/s/sreyya/745/project_2_provided_files/ece745_projects/proj_2/verification_ip/ncsu_pkg/ncsu_macros.svh"

`include "src/i2c_configuration.svh"
`include "src/i2c_transaction.svh"
`include "src/i2c_driver.svh"
`include "src/i2c_monitor.svh"
`include "src/i2c_agent.svh"


endpackage
