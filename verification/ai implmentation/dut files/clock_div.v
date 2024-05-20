`default_nettype none

module clock_div (
    input wire local_clk,   // Input clock
    input wire sb_clk,
    input wire rst,         // Reset signal
    input wire [1:0] gen_speed, // Clock dividing ratio selector
    output reg ser_clk,     // Serial clock output
    output reg enc_clk,     // Encoder clock output
    output reg fsm_clk,      // Finite state machine clock output
    output reg ms_clk
);

reg [3:0] ser_counter;
reg [7:0] enc_counter;
reg [4:0] fsm_counter; // Increased size to handle non-integer division ratios
reg [6:0] factor_counter;
reg [9:0] ms_counter;

localparam FREQ_FACTOR = 32;

always @(posedge local_clk or negedge rst) begin

    if (~rst) begin
        ser_counter <= 4'b0;
        enc_counter <= 8'b0;
        ser_clk <= 1'b0;
        enc_clk <= 1'b0;
        fsm_clk <= 1'b0;
		ms_clk <= 1'b0;
        fsm_counter <= 7'b0;
        factor_counter <= 6'b0;

    end else begin
        case (gen_speed)

            2'b00: begin // gen_speed is 0
                
                enc_counter <= enc_counter + 1'b1;
                
                
                    ser_clk <= ~ser_clk;

                if (enc_counter == 8'd7) begin
                    enc_clk <= ~enc_clk;
                    enc_counter <= 8'b0;
                end
                    fsm_clk <= ~fsm_clk;

            end

            2'b01: begin // gen_speed is 1
                ser_counter <= ser_counter + 1'b1;
                enc_counter <= enc_counter + 1'b1;
                fsm_counter <= fsm_counter + 1'b1;
                factor_counter <= factor_counter + 1'b1;

                if (ser_counter == 4'd3) begin
                    ser_clk <= ~ser_clk;
                    ser_counter <= 4'b0;
                end
                if (enc_counter == 8'd32) begin
                    enc_clk <= ~enc_clk;
                    enc_counter <= 8'b0;
                end
                if (fsm_counter == 5'd3) begin
                    if (factor_counter != FREQ_FACTOR-1) begin
                        fsm_clk <= ~fsm_clk;
                         fsm_counter <= 7'b0;
                    end else begin 
                        fsm_clk <= fsm_clk;
                        fsm_counter <= 7'd3;
                    end
                end

                 if (factor_counter == 32) begin
                    factor_counter <= 0 ;
                end
            end

            2'b10: begin // gen_speed is 2
                ser_counter <= ser_counter + 1'b1;
                enc_counter <= enc_counter + 1'b1;
                fsm_counter <= fsm_counter + 1'b1;
                factor_counter <= factor_counter + 1'b1;

                if (ser_counter == 4'd7) begin
                    ser_clk <= ~ser_clk;
                    ser_counter <= 4'b0;
                end
                if (enc_counter == 8'd65) begin
                    enc_clk <= ~enc_clk;
                    enc_counter <= 8'b0;
                end
                if (fsm_counter == 5'd7) begin
                    if (factor_counter != FREQ_FACTOR-1) begin
                        fsm_clk <= ~fsm_clk;
                         fsm_counter <= 7'b0;
                    end else begin 
                        fsm_clk <= fsm_clk;
                        fsm_counter <= 7'd7;
                    end
                end

                 if (factor_counter == 32) begin
                    factor_counter <= 0 ;
                end

            end
            default: begin // Default to 0
                ser_counter <= ser_counter + 1'b1;
                enc_counter <= enc_counter + 1'b1;
                fsm_counter <= fsm_counter + 1'b1;
                factor_counter <= factor_counter + 1'b1;

                if (ser_counter == 4'd1) begin
                    ser_clk <= ~ser_clk;
                    ser_counter <= 4'b0;
                end
                if (enc_counter == 8'd7) begin
                    enc_clk <= ~enc_clk;
                    enc_counter <= 8'b0;
                end
                if (fsm_counter == FREQ_FACTOR) begin
                    if (factor_counter != (FREQ_FACTOR - 1)) begin
                        fsm_clk <= ~fsm_clk;
                    end
                    fsm_counter <= 7'b0;
                    factor_counter <= 6'b0;
                end
            end
        endcase
    end
end

always @(posedge sb_clk or negedge rst) begin

    if (~rst) begin
        ms_counter <= 0;
    end else begin
         ms_counter <= ms_counter + 1'b1;
                
        if (ms_counter ==4) begin
            ms_clk <= ~ms_clk;
            ms_counter <= 0;
        end
    end
end

endmodule
