////////////////////////////////////////////////////////////////////////////////////////////////////
// Block: pulse_generator
//
// Description: This block takes a level signal input and changes it to a 
//              single pulse   
//
////////////////////////////////////////////////////////////////////////////////////////////////////

module pulse_generator 
(
input  wire        clk, reset_n,
input  wire        s_read,
input  wire        s_write,
input  wire        trans_error,
input  wire        t_valid,
output wire        s_read_pul,
output wire        s_write_pul,
output wire        trans_error_pul,
output wire        t_valid_pul
);

pul_gen pul_gen1
(
.clk(clk), 
.reset_n(reset_n),
.lvl_sig(s_read),
.pulse_sig(s_read_pul)
);

pul_gen pul_gen2
(
.clk(clk), 
.reset_n(reset_n),
.lvl_sig(s_write),
.pulse_sig(s_write_pul)
);

pul_gen pul_gen3
(
.clk(clk), 
.reset_n(reset_n),
.lvl_sig(trans_error),
.pulse_sig(trans_error_pul)
);

pul_gen pul_gen4
(
.clk(clk), 
.reset_n(reset_n),
.lvl_sig(t_valid),
.pulse_sig(t_valid_pul)
);
		
endmodule					 