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


lanes_deserializer #(.WIDTH(WIDTH)) deser
(
.clk(clk), 
.rst(rst),
.enable_deser(enable_deser),
.lane_0_rx_ser(lane_0_rx_ser),
.lane_1_rx_ser(lane_1_rx_ser),
.gen_speed(gen_speed),
.lane_0_rx_parallel(lane_0_rx_parallel), 
.lane_1_rx_parallel(lane_1_rx_parallel),
.descr_rst(descr_rst), 
.enable_dec(enable_dec) 
);


lanes_serializer #(.WIDTH(WIDTH)) ser
(
.clk(clk), 
.rst(rst),
.enable_ser(enable_ser),
.lane_0_tx_parallel(lane_0_tx_parallel),
.lane_1_tx_parallel(lane_1_tx_parallel),
.gen_speed(gen_speed),
.lane_0_tx_ser(lane_0_tx_ser),
.lane_1_tx_ser(lane_1_tx_ser),
.scr_rst(scr_rst),
.enable_scr(enable_scr)
);


endmodule