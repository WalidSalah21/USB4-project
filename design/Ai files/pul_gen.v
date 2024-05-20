////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Block: pul-gen
// Author: Seif Hamdy Fadda
// 
// Description: converting a level signal into a pulse signal.
// Note: This block is implemented using AI (chatgpt3.5).
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
`default_nettype none
module pul_gen (
    input wire clk,
    input wire reset_n,
    input wire lvl_sig,
    output reg pulse_sig
);

// Internal register to track previous level signal
reg prev_lvl_sig;

// Initialize pulse signal to 0
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        pulse_sig <= 0;
        prev_lvl_sig <= 0;
    end else begin
        // Detect rising edge of level signal
        if (lvl_sig && !prev_lvl_sig) begin
            // Generate pulse
            pulse_sig <= 1;
        end else begin
            // Reset pulse signal
            pulse_sig <= 0;
        end
        // Update previous level signal
        prev_lvl_sig <= lvl_sig;
    end
end

endmodule

`resetall	
