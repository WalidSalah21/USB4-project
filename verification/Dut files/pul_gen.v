////////////////////////////////////////////////////////////////////////////////////////////////////
// Block: pul_gen
//
// Author: Ahmed Zakaria
//
// Description: This block takes a level signal input and changes it to a 
//              single pulse   
//
////////////////////////////////////////////////////////////////////////////////////////////////////

module pul_gen 
(
  input  wire clk, reset_n,
  input  wire lvl_sig,
  output wire pulse_sig
);

reg ff1_out;
reg ff2_out;

always @(posedge clk or negedge reset_n)
begin
	if(!reset_n)
	begin
		ff1_out <= 0;
		ff2_out <= 0;
	end
	else
	begin
		ff1_out <= lvl_sig;
		ff2_out <= ff1_out;
	end
end

assign pulse_sig = ff1_out & (~ff2_out);
		
endmodule					 