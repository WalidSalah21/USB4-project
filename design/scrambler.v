////////////////////////////////////////////////////////////////////////////////////
// Block: scrambler
//
// Author: Ahmed Zakaria
//
// Description: scrambling of serial input stream 
//
/////////////////////////////////////////////////////////////////////////////////////

`default_nettype none

module scrambler 
#(parameter SEED = 'h1f_eedd)
(
  input  wire clk, 
  input  wire rst, 
  input  wire data_in, 
  input  wire enable, 
  input  wire scr_rst, 
  output reg  scrambled_out,
  output reg  enable_rs
);

//polynomial is x^23 + x^21 + x^16 + x^8 + x^5 + x^2 + 1
reg[23:0] lfsr; 

wire feedback;

always@(posedge clk or negedge rst)
  begin
	if (!rst) 
      begin
	    lfsr <= SEED;
	    scrambled_out <= 0;
	    enable_rs <= 0;
	  end
	else if(enable)
	  begin	 
	    scrambled_out <= feedback;
	    enable_rs <= 1;
		if (scr_rst)
		  lfsr <= SEED;
		else
		  lfsr <= {lfsr[22:0], feedback}; 		
	  end
	else
	  begin
	    lfsr <= SEED;
		scrambled_out <= 0;
		enable_rs <= 0;
	  end
  end

assign feedback = data_in ^ lfsr[23] ^ lfsr[21] ^ lfsr[16] ^ lfsr[8] ^ lfsr[5] ^ lfsr[2];
		   
endmodule

`resetall