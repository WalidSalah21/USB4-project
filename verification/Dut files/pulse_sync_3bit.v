////////////////////////////////////////////////////////////////////////////////////
// Block: pulse_sync_4bit
//
// Author: Ahmed Zakaria
//
// Description: synchronizing a 4-bit-width pulse from fast clock domain to slow 
//              clock domain. 
//
/////////////////////////////////////////////////////////////////////////////////////


`default_nettype none

module pulse_sync_3bit
(
input  wire [2:0] sig_3bit, //input signal
input  wire rst, //rst signal
input  wire clk_a, //fast clk
input  wire clk_b, //slow clk
output wire [2:0] sig_sync_3bit, //output synchronized signal
output wire busy
);

wire [2:0] busy_3bit;

pulse_sync sync1
(
.sig(sig_3bit[0]), 
.rst(rst), 
.clk_a(clk_a), 
.clk_b(clk_b), 
.sig_sync(sig_sync_3bit[0]),
.busy(busy_3bit[0])
);

pulse_sync sync2
(
.sig(sig_3bit[1]), 
.rst(rst), 
.clk_a(clk_a), 
.clk_b(clk_b), 
.sig_sync(sig_sync_3bit[1]),
.busy(busy_3bit[1])
);

pulse_sync sync3
(
.sig(sig_3bit[2]), 
.rst(rst), 
.clk_a(clk_a), 
.clk_b(clk_b), 
.sig_sync(sig_sync_3bit[2]),
.busy(busy_3bit[2])
);

assign busy = |busy_3bit;
  
endmodule

`resetall
