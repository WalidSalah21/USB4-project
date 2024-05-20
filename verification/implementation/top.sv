`timescale 1fs/1fs

`include "tb_pkg.sv"
//import tb_pkg::*;



module top;

	parameter Sys_clock_cycle = 1 * 10**6; parameter Rx_clock_cycle = 50;

	parameter [63:0] SB_freq = 1 * 10**6;
	parameter [63:0] freq_9_697 = 9.697 * 10 ** 9;		//9.697 GHz
	parameter [63:0] freq_19_394 = 19.394 * 10 ** 9;	//19.394 GHz
	parameter [63:0] freq_10 = 64'd10 * 10 ** 9;		//10 GHz
	parameter [63:0] freq_20 = 64'd20 * 10 ** 9;		//20 GHz
	parameter [63:0] freq_40 = 40 * 10 ** 9;			//40 GHz
	parameter [63:0] freq_80 = 80 * 10 ** 9;			//80 GHz

	/*
	parameter clock_10G = 100;
	parameter clock_20G = 50;
	parameter clock_40G = 25;
	parameter clock_1_212G = 825;
	parameter clock_2_424G = 825;
	*/
	logic SystemClock; logic Rx_Clock;
	logic local_clk;
	logic SB_clock;
	logic gen2_lane_clk, gen3_lane_clk, gen4_lane_clk;
	logic gen2_fsm_clk, gen3_fsm_clk, gen4_fsm_clk;
	logic SystemReset;

	logic enable_rs_dummy;


	//Reset generation
	task reset();
		repeat (3) @(posedge SB_clock) SystemReset = 0;
		SystemReset = 1;
		
		
	endtask

	// interfaces 
	upper_layer_if UL_if(SystemClock, gen2_fsm_clk, gen3_fsm_clk, gen4_fsm_clk, SystemReset);
	electrical_layer_if elec_if(SystemClock, SB_clock, gen2_lane_clk, gen3_lane_clk, gen4_lane_clk, UL_if.clk_cycles_counter);
	config_space_if config_if(SystemClock, gen4_fsm_clk);

	//DUT instatiation
	logical_layer_no_scr logical_layer (
									.local_clk(local_clk),
									.sb_clk(SB_clock),
									.rst(SystemReset),
									.lane_disable(config_if.lane_disable),
									.sbtx(elec_if.sbtx),
									.c_read(config_if.c_read),
									.c_write(config_if.c_write), 
									.c_address(config_if.c_address),
									.c_data_in(config_if.c_data_in),
									.c_data_out(config_if.c_data_out),
									.transport_layer_data_in(UL_if.transport_layer_data_in),
									.lane_0_rx_i(elec_if.lane_0_rx),		
									.lane_1_rx_i(elec_if.lane_1_rx),
									// .control_unit_data(0),
									.enable_deser(elec_if.data_incoming),
									.transport_layer_data_out(UL_if.transport_layer_data_out),
									.sbrx(elec_if.sbrx),		
									.lane_0_tx_o(elec_if.lane_0_tx),
									.lane_1_tx_o(elec_if.lane_1_tx),
									.enable_scr(enable_rs_dummy),
									.cl0_s(UL_if.cl0_s),
									.transport_data_flag(UL_if.transport_data_flag)
								);

	//Clocks' Initialization
	initial begin
		
		//$timeformat(-9 , 2 , " ns", 10);

		SystemClock = 0 ;
		Rx_Clock = 0;
		local_clk = 0;
		gen2_lane_clk = 0;
		gen3_lane_clk = 0;
		gen4_lane_clk = 1;
		gen2_fsm_clk = 0;
		gen3_fsm_clk = 1;
		gen4_fsm_clk = 0;
		SB_clock = 0;
		
	end




	

	always #(Sys_clock_cycle/2) SystemClock = ~SystemClock;

	always #((10**15)/(2*freq_80)) local_clk = ~local_clk;

	always #((10**15)/(2*SB_freq)) SB_clock = ~SB_clock; // sideband clock
	
	always #((10**15)/(2*freq_10)) gen2_lane_clk = ~gen2_lane_clk;
	
	always #((10**15)/(2*freq_20)) gen3_lane_clk = ~gen3_lane_clk;
	
	always #((10**15)/(2*freq_40)) gen4_lane_clk = ~gen4_lane_clk;

	always #((10**15)/(2*freq_9_697)) gen2_fsm_clk = ~gen2_fsm_clk;
	
	always #((10**15)/(2*freq_19_394)) gen3_fsm_clk = ~gen3_fsm_clk;

	always #((10**15)/(2*freq_40)) gen4_fsm_clk = ~gen4_fsm_clk;

	//always #(Rx_clock_cycle/2) Rx_Clock = ~Rx_Clock;


	// TEST 
	initial begin 
		
		Test test;
		test = new (UL_if, elec_if, config_if);
		reset();
		test.run("normal_scenario_gen_4");
		
	end


	


endmodule : top
