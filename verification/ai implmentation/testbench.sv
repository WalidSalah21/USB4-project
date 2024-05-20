//package testbench;

//symbols 
`include"symbols.sv"

//include the transaction classes
`include "elec_layer_tr.svh"
`include "config_space_pkg.sv"
`include "upper_layer_tr.svh"

//include the memory classes
`include "env_cfg_class.sv"

//include the driver classes
`include "config_driver.sv"
`include "up_driver.sv"
`include "elec_layer_driver.svh"


// REFERENCE MODEL
	`include "configuration_space_reference.sv"
	`include "elec_reference.sv"
	`include "upper_reference.sv"
	`include"reference_model_AI.sv"

	/*`include "int_packet.sv"
	`include "R_Mod_extentions.sv"
	`include "my_memory.sv"
	`include "primary_steps.sv"

	`include "phase1.sv"
	`include "phase2.sv"
	`include "phase3.sv"
	`include "phase4.sv"
	`include "phase5.sv"

	`include "ref_model.sv"*/


//include the generator classes
`include "elec_layer_generator.svh"
`include "up_stimulus_generator.sv"
`include "config_generator.sv"

//include the monitor classes
`include "elec_layer_monitor.svh"
`include "up_monitor.sv"
`include "config_monitor.sv"

//include the agent classes
`include "elec_layer_agent.svh"
`include "up_agent.sv"
`include "config_agent.sv"

//include the scoreboard classes
`include "elec_layer_scoreboard.svh"
`include "up_scoreboard.sv"
`include "config_scoreboard.sv"

//include the virtual sequence classes
`include "virtual_sequence.sv"


//include the test environment classes
`include "Env.svh"

//include the test classes
//`include "TEST.sv" 


//endpackage

