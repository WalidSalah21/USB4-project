`default_nettype none

module crc_16(
    input wire sb_clk,
    input wire rst,
    input wire crc_en,
    input wire crc_active,
    input wire trans_ser,
    output reg parity
    );

reg [15:0] crc_reg;
reg [3:0] cnt;
wire feedback;

assign feedback = crc_reg[15] ^ trans_ser;

always @(posedge sb_clk or negedge rst) begin
    if (!rst) begin
        crc_reg <= 16'hFFFF;
        cnt <= 4'b0;
    end else if (crc_en) begin
        cnt <= (cnt == 9)? 0 : cnt + 1;
		if (!crc_active && cnt !=0 && cnt!=9) begin // Normal CRC Calculation Mode
            crc_reg <= {crc_reg[14:0], feedback};
            crc_reg[2] <= crc_reg[1] ^ feedback;
            crc_reg[15] <= crc_reg[14] ^ feedback;
        end else if (crc_active && cnt!=0 && cnt!=9) begin // Output CRC bits serially
            crc_reg <= {crc_reg[14:0], 1'b0};
        end
    end else begin
	    crc_reg <= 16'hFFFF;
		cnt <= 4'b0;
	end
end

always @(*) begin
    if (crc_active && cnt==0) begin
        parity = 1'b0;
    end else if (crc_active && cnt==9) begin
        parity = 1'b1;
	end else if (crc_active) begin
	    parity = crc_reg[15]; 
	end else begin
	    parity <= 1'b0;
	end
end

endmodule

`resetall
