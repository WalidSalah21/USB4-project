////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Block: pulse_sync_3bit
// Author: Seif Hamdy Fadda
// 
// Description: Synchronizing a 4-bit pulse from fast clock domain to slow clock domain.
// Note: This block is implemented using AI (chatgpt3.5).
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
`default_nettype none
module pulse_sync_3bit
(
input  wire [2:0] sig_3bit,
input  wire rst,
input  wire clk_a,
input  wire clk_b,
output wire [2:0] sig_sync_3bit,
output wire busy
);

wire [2:0] busy_inst;

pulse_sync pulse_sync_inst1
(
.sig(sig_3bit[0]), 
.rst(rst), 
.clk_a(clk_a), 
.clk_b(clk_b), 
.sig_sync(sig_sync_3bit[0]),
.busy(busy_inst[0])
);

pulse_sync pulse_sync_inst2
(
.sig(sig_3bit[1]), 
.rst(rst), 
.clk_a(clk_a), 
.clk_b(clk_b), 
.sig_sync(sig_sync_3bit[1]),
.busy(busy_inst[1])
);

pulse_sync pulse_sync_inst3
(
.sig(sig_3bit[2]), 
.rst(rst), 
.clk_a(clk_a), 
.clk_b(clk_b), 
.sig_sync(sig_sync_3bit[2]),
.busy(busy_inst[2])
);

assign busy = |busy_inst;
  
endmodule

`resetall	
