`default_nettype none

module crc_16_rec(
    input wire sb_clk,
    input wire rst,
    input wire crc_en,
    input wire trans_ser,
    output reg error
    );

reg  [15:0] crc_reg;
reg  [3:0] cnt;
reg  flag;
wire feedback;

assign feedback = crc_reg[15] ^ trans_ser;

always @(posedge sb_clk or negedge rst) begin
    if (!rst) begin
        crc_reg <= 16'hFFFF;
        error <= 1'b0;
        flag <= 1'b0;
        cnt <= 4'b0;
    end else if (crc_en) begin
        error <= 1'b0;
		cnt <= (cnt == 9)? 0 : cnt + 1;
		if (cnt!=0 && cnt!=9) begin // Normal CRC Calculation Mode
            crc_reg <= {crc_reg[14:0], feedback};
            crc_reg[2] <= crc_reg[1] ^ feedback;
            crc_reg[15] <= crc_reg[14] ^ feedback;
			flag <= 1'b0;
        end
    end else begin
	    crc_reg <= 16'hFFFF;
		error <= (crc_reg!=16'h0 && !crc_reg); 
		flag <= 1;
		cnt <= 4'b0;
	end
end

endmodule

`resetall
