`default_nettype none

module bus_deserializer #(
    parameter DATA_WIDTH = 8  // Define the width of the parallel data output
)(
    input wire clk,                  // Clock input
    input wire rst,                // Active low reset
    input wire enable,               // Enable signal for deserialization
    input wire serial_in,            // Serial data input
    output reg [DATA_WIDTH-1:0] parallel_data  // Parallel data output
);

    // Internal variables
    reg [DATA_WIDTH-1:0] shift_reg;    // Shift register for the data being deserialized
    reg [$clog2(DATA_WIDTH)-1:0] counter; // Counter for synchronization

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            // Reset logic
            shift_reg <= 0;
            parallel_data <= 0;
            counter <= 0;
        end else if (enable) begin
            if (counter == (DATA_WIDTH-1)) begin
                // Shift in the new bit
                shift_reg <= (shift_reg << 1) | serial_in;
                counter <= 0;
                parallel_data <= (shift_reg << 1) | serial_in; // Update parallel data after all bits are received
            end else begin
                // Keep shifting in the new bits
                shift_reg <= (shift_reg << 1) | serial_in;
                counter <= counter + 1'b1;
            end
        end else begin
            // When enable is low, reset deserializer
            shift_reg <= 0;
            counter <= 0;
            parallel_data <= 0;
        end
    end
endmodule

`resetall