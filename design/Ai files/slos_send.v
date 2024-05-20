`default_nettype none

module slos_send #
(
    parameter SEED = 'h400
)
(
    input wire clk,
    input wire reset,
    input wire enable,
    input wire slos1_slos2,
    output reg  data_out,
    output reg  slos_sent
);

reg [10:0] reg_val;
reg round_started;
reg flag; //to prevent counting slos_sent before starting the first round
reg is_seed;

always @(*) begin
    if (SEED == 'h0a3) begin
        is_seed = (reg_val == 'h200);
    end else begin
        is_seed = (reg_val == 'h400);
    end
end

always @(*) begin
    if (SEED == 'h400) begin
        slos_sent = (round_started && flag);
    end else if (SEED == 'h0a3) begin
        slos_sent = ((reg_val == 'h0a3 || reg_val == 'h7ed) && flag);
    end else begin
        slos_sent = 0;
    end
end

always @(posedge clk or negedge reset) begin
    if (!reset) begin
        reg_val <= SEED;
        round_started <= 0;
        flag <= 0;
    end else begin
        if (enable) begin
            if (is_seed && !round_started) begin
                reg_val <= SEED;
                round_started <= 1;
            end else begin
                reg_val <= {reg_val[9:0], (reg_val[10] ^ reg_val[8])};
                round_started <= 0;
				flag <= 1;
            end
        end else begin //if not enabled
            reg_val <= SEED;
            round_started <= 0;
            flag <= 0;
        end
    end
end

always @(*) begin
    if (slos1_slos2)
        data_out = ~reg_val[0];
    else if (SEED == 'h0a3 && reg_val == 'h0a3)
        data_out = ~reg_val[0];
    else
        data_out = reg_val[0];
end

endmodule

`resetall