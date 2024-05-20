////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Block: clock_divider
// Author: Seif Hamdy Fadda
// 
// Description: The clock divider uses the 80 GHz local clock to generate lower frequences to be used by other blocks as serializer
// , fsm, and encoder, the clock divider uses counters to count the number of positive and negative edges.
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module clock_div (
    input local_clk, rst, 
	input [1:0] gen_speed,
	output reg ser_clk, enc_clk, fsm_clk
);
    reg         clk_div_2_delay, clk_div_2, clk_div_4, clk_div_4_delay, clk_div_8, clk_div_8_delay , clk_div_16, clk_div_66, clk_div_33;
	reg [5:0]   count_en_gen3;
	reg [5:0]   count_en_gen2;
	reg [1:0]   r_reg4, r_reg4_delay;
	reg [2:0]   r_reg8, r_reg8_delay;
	reg [2:0]   r_reg16;
	reg [5:0]   r_reg66;
	reg [5:0]   r_reg33_pos, r_reg33_neg;
 
	always @(posedge local_clk or negedge rst) begin
        if (!rst) begin
            clk_div_2 <= 1'b0;
			clk_div_2_delay <= 1'b0;
	        clk_div_4 <= 1'b0;
			clk_div_4_delay <= 1'b0;
			clk_div_8 <= 1'b0;
			clk_div_8_delay <= 1'b0;
			clk_div_66 <=1'b0;
			clk_div_16 <=1'b0;
	        r_reg4_delay <= 2'b00;
			r_reg4 <= 2'b00;
			r_reg8 <= 3'b000;
			r_reg8_delay <= 3'b000;
			r_reg66 <= 0;
			r_reg16 <= 0;
			r_reg33_pos <= 0;
			count_en_gen2 <= 0;
			count_en_gen3 <= 0;
			
        end
///////////////////////////////////////////////////////////////////////////////		
        else begin 
		    if (count_en_gen3 != 32)  begin
			    count_en_gen3 <= count_en_gen3 +1;
			end
            else begin
                count_en_gen3 <= 0;
			end
//////////////////////////////////////////////////////////////////////////////			
            if (count_en_gen2 != 32)  begin
			    count_en_gen2 <= count_en_gen2 +1;
			end
            else begin
                count_en_gen2 <= 0;
			end
//////////////////////////////////////////////////////////////////////////////			
            if (count_en_gen3 != 31) begin			
            clk_div_2_delay <= ~clk_div_2_delay; //clk/2 with delay
			end
			else begin 
			clk_div_2_delay <= clk_div_2_delay;
			end
//////////////////////////////////////////////////////////////////////////////			
	        if (r_reg4_delay == 2'b01) begin //clk/4 with delay
		        r_reg4_delay <= 2'b00;
				if (count_en_gen2 != 31) begin
			    clk_div_4_delay <= ~clk_div_4_delay;
				end
				else begin 
				clk_div_4_delay <= clk_div_4_delay;
				end
		    end
		    else begin
			    if (count_en_gen2 == 32) begin
				clk_div_4_delay <= ~clk_div_4_delay;
				r_reg4_delay <= 0;
				end
				else begin
		        r_reg4_delay <= r_reg4_delay + 1;
				end
		    end
/////////////////////////////////////////////////////////////////////////////		
	        if (r_reg8_delay == 3'b011) begin //clk/4 with delay
		        r_reg8_delay <= 3'b000;
				if (count_en_gen2 != 31) begin
			    clk_div_8_delay <= ~clk_div_8_delay;
				end
				else begin 
				clk_div_8_delay <= clk_div_8_delay;
				end
		    end
		    else begin
			    if (count_en_gen2 == 32) begin
				clk_div_8_delay <= ~clk_div_8_delay;
				r_reg8_delay <= 0;
				end
				else begin
		        r_reg8_delay <= r_reg8_delay + 1;
				end
		    end
/////////////////////////////////////////////////////////////////////////////
            clk_div_2 <= ~clk_div_2; //clk/2
/////////////////////////////////////////////////////////////////////////////
            if (r_reg4 == 2'b01) begin //clk/4
		        r_reg4 <= 2'b00;
			    clk_div_4 <= ~clk_div_4;
		    end
		    else begin
		        r_reg4 <= r_reg4 + 1;
		    end			
/////////////////////////////////////////////////////////////////////////////			
			if (r_reg8 == 3'b011) begin //clk/8
			    r_reg8 <= 3'b000;
				clk_div_8 <= ~ clk_div_8;
			end	
		
			else begin
                r_reg8 <= r_reg8 + 1;
			end
/////////////////////////////////////////////////////////////////////////////			
			if (r_reg16 == 3'b111) begin //clk/16
			    r_reg16 <= 3'b000;
				clk_div_16 <= ~ clk_div_16;
			end	
			else begin
                r_reg16 <= r_reg16 + 1;
			end
////////////////////////////////////////////////////////////////////////////			
			if (r_reg66 == 32) begin //clk/66
			    r_reg66 <= 6'b0;
				clk_div_66 <= ~ clk_div_66;
			end	
			else begin
                r_reg66 <= r_reg66 + 1;
			end
///////////////////////////////////////////////////////////////////////////			
			if (r_reg33_pos == 32) begin //clk/33
			    r_reg33_pos <= 0;
			end
            else begin
			    r_reg33_pos <= r_reg33_pos + 1'b1;
			end
			
        end
	end	
//////////////////////////////////////////////////////////////////////////		
	always @(negedge local_clk or negedge rst) begin //clk/odd number
        if (!rst) begin
		    r_reg33_neg <= 0;
		end
		else begin
		    if (r_reg33_neg == 32) begin //clk/33
			    r_reg33_neg <= 0;
			end	
			else begin 
                r_reg33_neg <= r_reg33_neg + 1'b1;
			end
		end
	end		
    always @(*) begin
	    if (!rst) begin
		    clk_div_33 = 1'b0;
		end
		else begin
	       clk_div_33 = ((r_reg33_pos > (33 >> 1)) | (r_reg33_neg > (33 >> 1)));
		end
	    case (gen_speed)
            2'b00: begin //gen4
			    ser_clk = clk_div_2;
				fsm_clk = clk_div_2;
				enc_clk = clk_div_16;
			end	
			2'b01: begin //gen3
			    ser_clk = clk_div_4;
				fsm_clk = clk_div_4_delay;
				enc_clk = clk_div_33;
			end	
			2'b10: begin //gen2 
			    ser_clk = clk_div_8;
				fsm_clk = clk_div_8_delay;
				enc_clk = clk_div_66;
			end	
			default: begin //gen4
                ser_clk = clk_div_2;
				fsm_clk = clk_div_2;
				enc_clk = clk_div_16;
			end	
		endcase
    end
endmodule	
	