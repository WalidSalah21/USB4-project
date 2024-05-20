`default_nettype none

module lanes_deserializer
(
    input wire clk,                    // Clock input
    input wire rst,                    // Active low reset
    input wire enable,                 // Enable signal for deserialization
    input wire [1:0] gen_speed,        // 2-bit input for generation speed
    input wire Lane_0_rx_in,           // Serial data input for Lane 0
    input wire Lane_1_rx_in,           // Serial data input for Lane 1
    output reg [131:0] Lane_0_rx_out,  // Parallel data output for Lane 0
    output reg [131:0] Lane_1_rx_out,  // Parallel data output for Lane 1
    output reg enable_dec,             // Ready signal, high when not deserializing
    output wire descr_rst                // Reset seed of descrambler in the following stage
);

    // Internal variables
    reg [131:0] shift_reg0;    // Shift register for Lane 0 data being deserialized
    reg [131:0] shift_reg1;    // Shift register for Lane 1 data being deserialized
    reg [7:0] counter;         // Extended counter size for synchronization
    reg [7:0] max_count;       // Maximum count based on gen_speed

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
            // Reset logic
            shift_reg0 <= 0;
            shift_reg1 <= 0;
            counter <= 0;
            Lane_0_rx_out <= 0;
            Lane_1_rx_out <= 0;
            enable_dec <= 1'b0;
        end else if (enable) begin
            // Deserialize the data, shifting in each clock cycle
            shift_reg0 <= {Lane_0_rx_in, shift_reg0[131:1]};
            shift_reg1 <= {Lane_1_rx_in, shift_reg1[131:1]};
            
            if (counter == 0) begin
                 // Adjust based on gen_speed and prepare for the next bit
                case(gen_speed)
                    2'b00: begin // Gen4
                        Lane_0_rx_out <= {124'b0, shift_reg0[131:124]};
                        Lane_1_rx_out <= {124'b0, shift_reg1[131:124]};
                    end
                    2'b01: begin // Gen3
                        Lane_0_rx_out <= shift_reg0;
                        Lane_1_rx_out <= shift_reg1;
                    end
                    2'b10: begin // Gen2
                        Lane_0_rx_out <= {66'b0, shift_reg0[131:66]};
                        Lane_1_rx_out <= {66'b0, shift_reg1[131:66]};
                    end
                    default: begin
                        // Handle other speeds or default case
                        Lane_0_rx_out <= {124'b0, shift_reg0[131:124]};
                        Lane_1_rx_out <= {124'b0, shift_reg1[131:124]};
                    end
                endcase
                counter <= counter + 1;
                enable_dec <= 1'b1; // Enable descrambler for the next stage
            end else begin
                if (counter == max_count-1) begin
                    counter <= 0;
				end else begin
				    counter <= counter + 1'b1;
				end
            end
        end else begin
            // When enable is low, reset the deserializer
            shift_reg0 <= 0;
            shift_reg1 <= 0;
            counter <= 0;
            Lane_0_rx_out <= 0;
            Lane_1_rx_out <= 0;
            enable_dec <= 1'b0;
        end
    end
	
assign descr_rst = (counter == max_count-2);

endmodule

`resetall