interface electrical_layer_if(input clk,
        input SB_clock,
	    input gen2_lane_clk,
	    input gen3_lane_clk,
	    input gen4_lane_clk);

	// elec layer inputs signals
	logic sbrx;
	logic lane_0_rx;
	logic lane_1_rx;
    logic data_incoming;

	// elec layer Output signals
	logic sbtx;
	logic lane_0_tx;
	logic lane_1_tx;
	logic enable_rs;
endinterface 