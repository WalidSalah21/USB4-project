////////////////////////////////////////////////////////////////////////////////////
// Block: scrambler
//
// Author: Ahmed Zakaria
//
// Description: scrambling and descrambling of serial input stream 
//
/////////////////////////////////////////////////////////////////////////////////////

`default_nettype none

module scrambler_descrambler 
#(parameter SEED = 'h1f_eedd)
(
  input  wire clk, 
  input  wire rst, 
  input  wire data_incoming, 
  input  wire enable_scr, 
  input  wire scr_rst, 
  input  wire descr_rst,
  input  wire lane_0_tx, 
  input  wire lane_1_tx, 
  input  wire lane_0_rx_scr,
  input  wire lane_1_rx_scr, 
  output wire lane_0_tx_scr,
  output wire lane_1_tx_scr,
  output wire lane_0_rx, 
  output wire lane_1_rx, 
  output wire enable_deser, 
  output wire enable_rs 
);

scrambler #(.SEED(SEED)) scr_lane_0
(
  .clk           ( clk           ), 
  .rst           ( rst           ), 
  .data_in       ( lane_0_tx     ), 
  .enable        ( enable_scr    ), 
  .scr_rst       ( scr_rst       ), 
  .scrambled_out ( lane_0_tx_scr ),
  .enable_rs     ( enable_rs     )
);

scrambler #(.SEED(SEED)) scr_lane_1
(
  .clk           ( clk           ), 
  .rst           ( rst           ), 
  .data_in       ( lane_1_tx     ), 
  .enable        ( enable_scr    ), 
  .scr_rst       ( scr_rst       ), 
  .scrambled_out ( lane_1_tx_scr ),
  .enable_rs     ( enable_rs     )
);

descrambler #(.SEED(SEED)) descr_lane_0
(
  .clk           ( clk           ), 
  .rst           ( rst           ), 
  .scrambled_in  ( lane_0_rx_scr ), 
  .enable        ( data_incoming ), 
  .descr_rst     ( descr_rst     ), 
  .data_out      ( lane_0_rx     ),
  .enable_deser  ( enable_deser  )
);

descrambler #(.SEED(SEED)) descr_lane_1
(
  .clk           ( clk           ), 
  .rst           ( rst           ), 
  .scrambled_in  ( lane_1_rx_scr ), 
  .enable        ( data_incoming ), 
  .descr_rst     ( descr_rst     ), 
  .data_out      ( lane_1_rx     ),
  .enable_deser  ( enable_deser  )
);
		   
endmodule

`resetall