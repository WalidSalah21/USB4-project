`default_nettype none

module scrambler (
  input wire clk,
  input wire rst,
  input wire data_in,
  input wire enable,
  input wire scr_rst,
  output reg scrambled_out,
  output reg enable_rs
);

  reg [23:0] lfsr;
  reg [23:0] poly;
  wire msb;
  reg [31:0] output_reg;

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      lfsr <= 24'b00000000000000000000001;
      poly <= 24'h124;
      output_reg <= 32'b0;
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
      output_reg <= (output_reg << 1) + msb;
    end
  end

  always @(posedge clk) begin
    if (enable) begin
      scrambled_out <= data_in ^ msb;
    end
  end

  assign msb = lfsr[22];

endmodule
