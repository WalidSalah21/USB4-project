interface upper_layer_if(input clk,
	
	input gen2_fsm_clk, 
	input gen3_fsm_clk,
	input gen4_fsm_clk,
 	input logic reset);

	//upper layer inputs signals
	logic [7:0] transport_layer_data_in;
	
	//upper layer Output signals
	logic [7:0] transport_layer_data_out;

	GEN generation_speed;
	logic [2:0] phase; 
	logic transport_data_flag;
	logic cl0_s;


	logic 	enable_sending ; // signal to enable sending data from transport layer
	logic 	enable_receive; // signal sent by the driver to enable the monitor to receive data from transport_layer_data_out

endinterface: upper_layer_if


