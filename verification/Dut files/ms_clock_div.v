////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Block: clock_divider
// Author: Seif Hamdy Fadda
// 
// Description: The clock divider for ms_clk uses the side band clock to generate lower frequencey which is side band clock /1000.
// 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module ms_clock_div (
    input sb_clk, rst, 
	output ms_clk
);
    reg clk_div_1000;
	reg [8:0] r_reg1000;
 
	always @(posedge sb_clk or negedge rst) begin
        if (!rst) begin
            clk_div_1000 <= 1'b0;
	        r_reg1000 <= 9'b0;
        end	 
        else begin 
	        if (r_reg1000 == 2) begin //clk/1000   //! that should be a limititation to speed up simulation 
		        r_reg1000 <= 9'b0;
			    clk_div_1000 <= ~clk_div_1000;
		    end
		    else begin
		        r_reg1000 <= r_reg1000 + 1;
		    end
		end
	end
    assign ms_clk = clk_div_1000;
endmodule	
