////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Block: pulse_sync
// Author: Seif Hamdy Fadda
// 
// Description: Synchronizing a  pulse from fast clock domain to slow clock domain.
// Note: This block is implemented using AI (chatgpt3.5).
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
`default_nettype none
module pulse_sync (
    input wire clk_a,         // Fast Clock
    input wire clk_b,         // Slow Clock
    input wire rst,           // Reset
    input wire sig,           // Input Pulse
    output wire sig_sync,     // Synchronized Output
    output wire busy          // Busy Output
);

wire mux1_out;
wire mux2_out;

reg reg1_out;
reg reg2_out;
reg reg3_out;
reg reg4_out;
reg reg5_out;
reg reg6_out;

// Synchronize input signal to fast clock domain
always @(posedge clk_a or negedge rst) begin
    if (!rst) begin
        reg1_out <= 1'b0;
        reg2_out <= 1'b0;
        reg3_out <= 1'b0;
    end
    else begin
        reg1_out <= mux2_out;
        reg2_out <= reg5_out;
        reg3_out <= reg2_out;
    end
end

// Synchronize signal from fast clock domain to slow clock domain using handshake
always @(posedge clk_b or negedge rst) begin
    if (!rst) begin
        reg4_out <= 1'b0;
        reg5_out <= 1'b0;
        reg6_out <= 1'b0;
    end
    else begin
        reg4_out <= reg1_out;
        reg5_out <= reg4_out;
        reg6_out <= reg5_out;
    end
end

// Output assignment using assign statement
assign sig_sync = reg5_out & ~reg6_out;

// Define mux outputs
assign mux2_out = (sig) ? 1'b1 : mux1_out;
assign mux1_out = (reg3_out) ? 1'b0 : reg1_out;

// Assign busy output
assign busy = reg1_out | reg3_out;

endmodule

`resetall	
