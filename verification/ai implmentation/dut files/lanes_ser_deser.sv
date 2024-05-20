`default_nettype none

module lanes_ser_deser #(parameter WIDTH = 132)
(
input  wire             clk, 
input  wire             rst,
input  wire             enable_ser,
input  wire             enable_deser,
input  wire [WIDTH-1:0] lane_0_tx_parallel,
input  wire [WIDTH-1:0] lane_1_tx_parallel,
input  wire [1:0]       gen_speed,
input  wire             lane_0_rx_ser,
input  wire             lane_1_rx_ser,
output wire             lane_0_tx_ser,
output wire             lane_1_tx_ser,
output wire             scr_rst,
output wire             enable_scr,
output wire [WIDTH-1:0] lane_0_rx_parallel, 
output wire [WIDTH-1:0] lane_1_rx_parallel,
output wire             descr_rst,
output wire             enable_dec
);


lanes_deserializer deser
(
.clk(clk), 
.rst(rst),
.enable(enable_deser),
.Lane_0_rx_in(lane_0_rx_ser),
.Lane_1_rx_in(lane_1_rx_ser),
.gen_speed(gen_speed),
.Lane_0_rx_out(lane_0_rx_parallel), 
.Lane_1_rx_out(lane_1_rx_parallel),
.descr_rst(descr_rst), 
.enable_dec(enable_dec) 
);


lanes_serializer ser
(
.clk(clk), 
.rst(rst),
.enable(enable_ser),
.Lane_0_tx_in(lane_0_tx_parallel),
.Lane_1_tx_in(lane_1_tx_parallel),
.gen_speed(gen_speed),
.Lane_0_tx_out(lane_0_tx_ser),
.Lane_1_tx_out(lane_1_tx_ser),
.scr_rst(scr_rst),
.enable_scr(enable_scr)
);


endmodule

`resetall