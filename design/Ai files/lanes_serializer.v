`default_nettype none

module lanes_serializer 
(
    input wire  clk,                    // Clock input
    input wire  rst,                  // Active low reset
    input wire  enable,                 // Enable signal for serialization
    input wire  [1:0] gen_speed,        // 2-bit input for generation speed
    input wire  [131:0] Lane_0_tx_in, // Parallel data input
    input wire  [131:0] Lane_1_tx_in, // Parallel data input
    output reg  Lane_0_tx_out,             // Serial data output
    output reg  Lane_1_tx_out,             // Serial data output
    output reg  enable_scr,                   // Ready signal, high when not serializing
    output reg scr_rst                    // Reset seed of scrambler in the following stage
);

    // Internal variables
    reg [131:0] shift_reg0;    // Shift register for the data being serialized
    reg [131:0] shift_reg1;    // Shift register for the data being serialized
    reg [7:0] counter; // Extended counter size for synchronization
    reg [7:0] max_count;
	wire done;	// Maximum count based on gen_speed

    always @(*) begin
        // Assign max_count based on gen_speed
        case (gen_speed)
            2'b00: max_count = 8;
            2'b01: max_count = 132;
            2'b10: max_count = 66;
            default: max_count = 8; // Default to gen_speed=2'b00
        endcase
    end

        always @(posedge clk or negedge rst) begin
        if (!rst) begin
            Lane_0_tx_out <= 1'b0;
            Lane_1_tx_out <= 1'b0;
            shift_reg0 <= 'b0;
            shift_reg1 <= 'b0;
            counter <= 'b0;
			scr_rst <= 0;
			enable_scr <= 0;
        end
        else if (!enable) begin
            Lane_0_tx_out <= 1'b0;
            Lane_1_tx_out <= 1'b0;
            shift_reg0 <= 0;
            shift_reg1 <= 0;
            counter <= max_count-1;
			scr_rst <= 0;
			enable_scr <= 0;
        end
        else begin
            if (gen_speed == 0) begin
			    Lane_0_tx_out <= shift_reg0[7];
                Lane_1_tx_out <= shift_reg1[7];
                shift_reg0  <= (done)? Lane_0_tx_in : {shift_reg0[6:0], 1'b0};
                shift_reg1 <= (done)? Lane_1_tx_in : {shift_reg1[6:0], 1'b0};
            end else begin
			    Lane_0_tx_out <= shift_reg0[0];
                Lane_1_tx_out <= shift_reg1[0];
                shift_reg0  <= (done)? Lane_0_tx_in : {1'b0, shift_reg0[131:1]};
                shift_reg1 <= (done)? Lane_1_tx_in : {1'b0, shift_reg1[131:1]};
			end
			counter <= (done)? 1'b0 : counter+1;
			scr_rst <= done;
			enable_scr <= 1;
            end
        end
		
	assign done = (counter == max_count-1);

endmodule

`resetall
