`default_nettype none

module deserializer #(
    parameter DATA_WIDTH = 10  // Define the width of the parallel data output
)(
    input wire clk,                  // Clock input
    input wire rst,                // Active low reset
    input wire in_bit,            // Serial data input
    output reg [DATA_WIDTH-1:0] parallel_data  // Parallel data output
);

    // Internal variables
    reg [DATA_WIDTH-1:0] shift_reg;    // Shift register for the data being deserialized
    reg [$clog2(DATA_WIDTH)-1:0] counter; // Counter for synchronization
	reg start, started;

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            // Reset logic
            shift_reg <= 0;
            parallel_data <= 0;
            counter <= 0;
        end else if (start) begin
            if (counter == (DATA_WIDTH-1)) begin
                // Shift in the new bit
                shift_reg <= (shift_reg << 1) | in_bit;
                counter <= 0;
                parallel_data <= (shift_reg << 1) | in_bit; // Update parallel data after all bits are received
            end else begin
                // Keep shifting in the new bits
                shift_reg <= (shift_reg << 1) | in_bit;
                counter <= counter + 1'b1;
            end
        end
    end
	
	always @(*) begin
	    if (counter == 0 && in_bit == 0) begin
            start = 1;
	    end else if (counter == 0 && in_bit != 0) begin
            start = 0;
	    end else if (started) begin
            start = 1;
		end else begin
			start = 0;
		end
	end	
	
	always @(posedge clk) begin
		if (counter == 0 && start) begin
		    started <= 1;
		end else if (counter == 0 && !start) begin
		    started <= 0;
		end
	end	
	
endmodule

`resetall
