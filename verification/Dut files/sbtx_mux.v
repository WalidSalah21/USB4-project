///////////////////////////////////////////////////////////////////////////////////////////////////////////
// Block: sbtx multiplexer
// Author: Seif Hamdy Fadda
//
// Description: the multiplexer is used to output the transaction serial bits and then the crc parity bits 
///////////////////////////////////////////////////////////////////////////////////////////////////////////
module sbtx_mux (
    input sb_clk, rst, parity, sbtx_sel, trans_ser,
    output reg sbtx	
);
    always @(posedge sb_clk or negedge rst) begin
	    if (!rst) begin
		    sbtx <= 1'b0;
		end	
		else begin
	        case(sbtx_sel)
		        1'b0: begin
                    sbtx <= trans_ser;
			    end
			    1'b1: begin
			    sbtx <= parity;
			    end
		    endcase
		end	
	end
endmodule