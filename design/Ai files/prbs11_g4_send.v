`default_nettype none

module prbs11_g4_send #
(
    parameter lane0_lane1 = 1
)
(
    input wire clk,
    input wire reset,
    input wire enable,
    output wire data_out,
    output wire os_sent
);

reg [10:0] reg_val;
reg round_started;
reg flag; //to prevent counting os_sent before starting the first round
wire is_seed;
wire [10:0] seed;
reg [8:0] counter;

assign seed = (lane0_lane1)? 11'h7ff : 11'h770;
assign is_seed = (reg_val == seed);
assign os_sent = (counter == 9'h1bf);
assign data_out = reg_val[10];

always @(posedge clk or negedge reset) begin
    if (!reset) begin
        reg_val <= seed;
        round_started <= 0;
        flag <= 0;
        counter <= 0;
    end else begin
        if (enable) begin
            if (is_seed && !round_started) begin
                reg_val <= seed;
                round_started <= 1;
                counter <= 0;
            end else begin
                reg_val <= {reg_val[9:0], (reg_val[10] ^ reg_val[8])};
                round_started <= 0;
				flag <= 1;
				counter <= (counter == 9'h1bf)? 0 : counter + 1;
            end
        end else begin //if not enabled
            reg_val <= seed;
            round_started <= 0;
            flag <= 0;
            counter <= 0;
        end
    end
end

endmodule

`resetall
