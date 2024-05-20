`default_nettype none

module bus_serializer #(
    parameter DATA_WIDTH = 8  // Define the width of the parallel data input
)(
    input wire clk,                    // Clock input
    input wire rst,                  // Active low reset
    input wire enable,                 // Enable signal for serialization
    input wire [DATA_WIDTH-1:0] parallel_data, // Parallel data input
    output reg serial_out             // Serial data output
);

    // Internal variables
    reg [DATA_WIDTH-1:0] shift_reg;    // Shift register for the data being serialized
    reg [$clog2(DATA_WIDTH)-1:0] counter; // Extended counter size for synchronization

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            // Reset logic
            shift_reg <= 0;
            counter <= 0;
            serial_out <= 1'b0;
        end else if (enable) begin
            if (counter == 0) begin
                // Load new data into shift register every DATA_WIDTH cycles
                shift_reg <= parallel_data;
                serial_out <= parallel_data[DATA_WIDTH-1];
                counter <= DATA_WIDTH-1;
            end else begin
                // Serialize the data, shifting right each clock cycle
                shift_reg <= shift_reg << 1;
                serial_out <= shift_reg[DATA_WIDTH-2]; // Output the next bit
                counter <= counter - 1'b1;
            end
        end else begin
            // When enable is low, reset serializer
            shift_reg <= 0;
            counter <= 0;
            serial_out <= 1'b0;
        end
    end
endmodule

`resetall
