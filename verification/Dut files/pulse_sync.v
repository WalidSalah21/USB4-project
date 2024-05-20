////////////////////////////////////////////////////////////////////////////////////
// Block: pulse_sync
//
// Author: Ahmed Zakaria
//
// Description: synchronizing a pulse from fast clock domain to slow clock domain 
//
/////////////////////////////////////////////////////////////////////////////////////


`default_nettype none

module pulse_sync
(
input  wire sig, //input signal
input  wire rst, //rst signal
input  wire clk_a, //fast clk
input  wire clk_b, //slow clk
output wire sig_sync, //output synchronized signal
output wire busy
);

wire mux1_out,
     mux2_out;
	
reg	 a1_ff_out,
	 a2_ff_out,
	 a3_ff_out,
	 b1_ff_out,
	 b2_ff_out,
	 b3_ff_out;
	
always @(posedge clk_a or negedge rst)
  begin
    if(!rst)
	  begin
	    a1_ff_out <= 0;
	    a2_ff_out <= 0;
	    a3_ff_out <= 0;
	  end
	  
	else
	  begin
	    a1_ff_out <= mux2_out;
	    a2_ff_out <= b2_ff_out;
	    a3_ff_out <= a2_ff_out;
	  end
  end
  
always @(posedge clk_b or negedge rst)
  begin
    if(!rst)
	  begin
	    b1_ff_out <= 0;
	    b2_ff_out <= 0;
	    b3_ff_out <= 0;
	  end
	  
	else
	  begin
	    b1_ff_out <= a1_ff_out;
	    b2_ff_out <= b1_ff_out;
	    b3_ff_out <= b2_ff_out;
	  end
  end  

assign mux1_out = (a3_ff_out)? 1'b0 : a1_ff_out;
assign mux2_out = (sig)? 1'b1 : mux1_out;
assign busy = a3_ff_out | a1_ff_out;
assign sig_sync = b2_ff_out & (~b3_ff_out);
  
endmodule

`resetall