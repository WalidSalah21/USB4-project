////////////////////////////////////////////////////////////////////////////////////
// Block: descrambler
//
// Author: Ahmed Zakaria
//
// Description: descrambling of serial input stream of scrambled bits 
//
/////////////////////////////////////////////////////////////////////////////////////

`default_nettype none

module descrambler 
#(parameter SEED = 'h1f_eedd)
(
  input  wire clk, 
  input  wire rst, 
  input  wire scrambled_in, 
  input  wire enable, 
  input  wire descr_rst, 
  output reg  data_out,
  output reg  enable_deser
);

//polynomial is x^23 + x^21 + x^16 + x^8 + x^5 + x^2 + 1
reg[23:0] lfsr; 

wire data_out_reg;

always@(posedge clk or negedge rst)
  begin
	if (!rst) 
      begin
	    lfsr <= SEED;
	    data_out <= 0;
	    enable_deser <= 0;
	  end
	else if(enable)
	  begin	  
        data_out <= data_out_reg;
        enable_deser <= 1;
        if(descr_rst)	
          lfsr <= SEED;
		else
          lfsr <= {lfsr[22:0], scrambled_in};		
	  end
	else
	  begin
	    lfsr <= SEED;
		data_out <= 0;
		enable_deser <= 0;
	  end
  end

assign data_out_reg = scrambled_in ^ lfsr[23] ^ lfsr[21] ^ lfsr[16] ^ lfsr[8] ^ lfsr[5] ^ lfsr[2];
		   
endmodule

`resetall