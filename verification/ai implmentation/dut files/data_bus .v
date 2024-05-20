`default_nettype none

module data_bus (

    input   wire       fsm_clk, 
    input   wire       rst, 
    input   wire       data_os,
    input   wire       rx_lanes_on,
    input   wire [7:0] lane_0_rx,
    input   wire [7:0] lane_1_rx,
    input   wire [3:0] d_sel,
    input   wire[7:0]  transport_layer_data_in,
	output  wire       tx_lanes_on,
	output wire [3:0] os_in_l0,
	output wire [3:0] os_in_l1,
	output wire [7:0] lane_0_tx,
	output wire [7:0] lane_1_tx,
	output wire       os_sent,
	output wire [7:0] transport_layer_data_out
);

    data_bus_transmit t_data_bus 
	(
		.clk                     (       fsm_clk           ),
	    .rst                     (         rst             ),
		.d_sel                   (        d_sel            ),
		.lane_0_tx               (      lane_0_tx          ),
		.lane_1_tx               (      lane_1_tx          ),
		.os_sent                 (       os_sent           ),
		.transport_layer_data_in ( transport_layer_data_in ),
		.tx_lanes_on             (     tx_lanes_on         )
	);
	
	data_bus_receive r_data_bus 
	(
		.clk                      (       fsm_clk            ),
	    .rst                      (         rst              ),
		.d_sel                    (        d_sel             ),
		.lane_0_rx                (      lane_0_rx           ),
		.lane_1_rx                (      lane_1_rx           ),
		.os_in_l0                 (       os_in_l0           ),
		.os_in_l1                 (       os_in_l1           ),
		.data_os                  (       data_os            ),
		.lane_rx_on               (       rx_lanes_on        ),
		.transport_layer_data_out ( transport_layer_data_out )
	);
	
endmodule

`resetall

