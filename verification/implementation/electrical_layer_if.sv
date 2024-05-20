
interface electrical_layer_if(input clk,
	input SB_clock,
	input gen2_lane_clk,
	input gen3_lane_clk,
	input gen4_lane_clk,
	input [1:0] up_clk_counter
	);

	// elec layer inputs signals
	logic sbrx;
	logic lane_0_rx;
	logic lane_1_rx;
	bit data_incoming;

	// elec layer Output signals
	logic sbtx;
	logic lane_0_tx;
	logic lane_1_tx;

	// Internal signals
	GEN generation_speed;
	logic [2:0] phase;
	bit phase_5_read_enable;


endinterface : electrical_layer_if
