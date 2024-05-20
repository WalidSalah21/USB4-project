interface config_space_if (input clk,
	input gen4_fsm_clk
	);

	logic lane_disable;
	logic [31:0] c_data_in;

	logic c_read, c_write;
	logic [7:0] c_address;
	logic [31:0] c_data_out;

	//GEN generation_speed;
	
endinterface : config_space_if
