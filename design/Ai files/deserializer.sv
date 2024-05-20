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
           shift_reg <= {in_bit, shift_reg[DATA_WIDTH-1:1]};
			if (counter == DATA_WIDTH-1) begin
			    counter <= 0;
				parallel_data <= {in_bit, shift_reg[DATA_WIDTH-1:1]};
			end	
			else begin	
			    counter <= counter + 1;
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
		if (!rst)
		    started <= 0;
		else if (counter == 0 && start)
		    started <= 1;
		else if (counter == 0 && !start)
		    started <= 0;
		end
	
endmodule

`resetall
