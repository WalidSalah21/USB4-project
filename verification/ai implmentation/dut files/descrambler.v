`default_nettype none

module descrambler (
  input wire clk,
  input wire rst,
  input wire scrambled_in,
  input wire enable,
  input wire scr_rst,
  output wire descrambled_out,
  output reg enable_rs
);

  reg [23:0] lfsr;
  reg [23:0] poly;
  wire msb;
  reg [31:0] descrambled_out_reg;

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      lfsr <= 24'b00000000000000000000001;
      poly <= 24'h124;
      descrambled_out_reg <= 32'b0;
      enable_rs <= 1'b0;
    end else if (scr_rst) begin
      lfsr <= 24'h178225;
      enable_rs <= 1'b1;
    end else if (enable) begin
      lfsr <= lfsr << 1;
      lfsr[23] = 0;
      if (msb == 1) begin
        lfsr <= lfsr ^ poly;
        lfsr <= lfsr + msb;
      end
      descrambled_out_reg <= (descrambled_out_reg << 1) + msb;
    end
  end

  always @(posedge clk) begin
    if (enable) begin
      descrambled_out_reg[0] <= scrambled_in ^ msb;
    end
  end


assign descrambled_out = descrambled_out_reg [0]; 

assign msb = lfsr[22];


endmodule
