/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Block: data_bus
//Author: Seif Hamdy Fadda
//
//Description: Top data bus module instantiate the tx and rx data bus,the data bus transmiter waits for a d_select signal coming from the control fsm //             indicating the type of ordered set to be sent and then send it through the lane_0_tx, after sending the ordered set it sends the control //             fsm a signal indicating that the ordered set has been sent successfully, it also forwards the transport layer data coming from      
//             transport layer.the data bus reciever is used in detecting the different ordered sets of gen3 and gen4 and sending the control fsm 
//             a signal indicating the type of the ordered set, it also forowards the transport layer data to the transport layer. The data bus 
//             outputs an os_in_l0 signal to the control unit to indicate the type of the ordered set received.
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module data_bus (

    input         rst, fsm_clk, data_os,lane_rx_on,
    input   [7:0] lane_0_rx,
    input   [7:0] lane_1_rx,
	input   [3:0] d_sel,
	input   [7:0] transport_layer_data_in,
	output        tx_lanes_on,
	output  [3:0] os_in_l0,
	output  [3:0] os_in_l1,
	output  [7:0] lane_0_tx,
	output  [7:0] lane_1_tx,
	output        os_sent,
	output  [7:0] transport_layer_data_out
);
    data_bus_transmit t_data_bus (
	    .rst                    (         rst             ),
		.fsm_clk                (       fsm_clk           ),
		.d_sel                  (        d_sel            ),
		.lane_0_tx              (      lane_0_tx          ),
		.lane_1_tx              (      lane_1_tx          ),
		.os_sent                (       os_sent           ),
		.transport_layer_data_in( transport_layer_data_in ),
		.tx_lanes_on            (     tx_lanes_on         )
	);
	
	data_bus_receive r_data_bus (
	    .rst                     (         rst              ),
		.fsm_clk                 (       fsm_clk            ),
		.d_sel                   (        d_sel             ),
		.lane_0_rx               (      lane_0_rx           ),
		.lane_1_rx               (      lane_1_rx           ),
		.os_in_l0                (       os_in_l0           ),
		.os_in_l1                (       os_in_l1           ),
		.data_os                 (       data_os            ),
		.lane_rx_on              (       lane_rx_on         ),
		.transport_layer_data_out( transport_layer_data_out )
	);
endmodule
`default_nettype none
`resetall
