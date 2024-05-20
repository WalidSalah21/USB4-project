`default_nettype none

module prbs11_rec #(parameter SEED = 'h400)
(
    input wire clk,
    input wire reset,
    input wire enable,
    input wire slos1_slos2,
    input wire data_in,
    output reg slos_rec
);

reg [10:0] reg_val;
reg round_started;
reg error;
reg correct_val;
wire is_seed;

assign is_seed = (reg_val == 'h400);

always @(posedge clk or negedge reset) begin
    if (!reset) begin
        reg_val <= SEED;
        round_started <= 0;
        slos_rec <= 0;
        error <= 1;
    end else begin
        if (enable) begin
            if (is_seed && !round_started) begin //while receiving the last bit in the previous slos 
                round_started <= 1;
				reg_val <= SEED;
				if (data_in != correct_val)
                    error <= 1;
            end else if (is_seed && round_started) begin //after previous slos being sent completely
                round_started <= 0;
				reg_val <= {reg_val[9:0], (reg_val[10] ^ reg_val[8])};
				slos_rec <= !error;
				if (data_in != correct_val)
                    error <= 1;
				else 
                    error <= 0;
            end else begin
                reg_val <= {reg_val[9:0], (reg_val[10] ^ reg_val[8])};
				slos_rec <= 0;
				if (data_in != correct_val)
                    error <= 1;
            end
        end else begin //if not enabled
            reg_val <= SEED;
            round_started <= 0;
            slos_rec <= 0;
            error <= 1;
        end
    end
end

always @(*) begin
    if (slos1_slos2)
        correct_val = ~reg_val[0];
    else
        correct_val = reg_val[0];
end

endmodule

`resetall