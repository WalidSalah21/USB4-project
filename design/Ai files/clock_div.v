`default_nettype none

module clock_div (
    input wire local_clk,   // Input clock
    input wire sb_clk,
    input wire rst,         // Reset signal
    input wire [1:0] gen_speed, // Clock dividing ratio selector
    output reg ser_clk,     // Serial clock output
    output reg enc_clk,     // Encoder clock output
    output reg fsm_clk,      // Finite state machine clock output
    output reg ms_clk
);

reg [3:0] ser_counter;
reg [7:0] enc_counter;
reg [4:0] fsm_counter; // Increased size to handle non-integer division ratios
reg [6:0] factor_counter;
reg [9:0] ms_counter;
reg [5:0] count_en_gen2;
reg [5:0] count_en_gen3;
reg [5:0] r_reg33_pos, r_reg33_neg;
reg       clk_div_33;
localparam FREQ_FACTOR = 32;

always @(posedge local_clk or negedge rst) begin

    if (~rst) begin
        ser_counter <= 4'b0;
        enc_counter <= 8'b0;
        ser_clk <= 1'b0;
        enc_clk <= 1'b0;
        fsm_clk <= 1'b0;
        fsm_counter <= 7'b0;
        factor_counter <= 6'b0;
		count_en_gen2  <= 0;
		count_en_gen3  <= 0;
		r_reg33_pos <= 0;


    end else begin
		if (r_reg33_pos == 32) begin //clk/33
			r_reg33_pos <= 0;
		end
		else begin
			r_reg33_pos <= r_reg33_pos + 1'b1;
		end
		//enc_clk <= clk_div_33;
        case (gen_speed)

            2'b00: begin // gen_speed is 0
                
                enc_counter <= enc_counter + 1'b1;
                
                
                    ser_clk <= ~ser_clk;

                if (enc_counter == 8'd7) begin
                    enc_clk <= ~enc_clk;
                    enc_counter <= 8'b0;
                end
                    fsm_clk <= ~fsm_clk;

            end

            2'b01: begin // gen_speed is 1
                ser_counter <= ser_counter + 1'b1;
                enc_counter <= enc_counter + 1'b1;
                fsm_counter <= fsm_counter + 1'b1;
                factor_counter <= factor_counter + 1'b1;
				 
				if (count_en_gen3 != 32)  begin
					count_en_gen3 <= count_en_gen3 +1;
				end
				else begin
					count_en_gen3 <= 0;
				end
                if (ser_counter == 4'd1) begin
                    ser_clk <= ~ser_clk;
                    ser_counter <= 4'b0;
                end
                if (fsm_counter == 2'b01) begin //clk/4 with delay
					fsm_counter <= 2'b00;
					if (count_en_gen3 != 31) begin
						fsm_clk <= ~fsm_clk;
					end
					else begin 
						fsm_clk <= fsm_clk;
					end
				end
				else begin
					if (count_en_gen3 == 32) begin
						fsm_clk <= ~fsm_clk;
						fsm_counter <= 0;
					end
					else begin
						fsm_counter <= fsm_counter + 1;
					end
				end

                 if (factor_counter == 32) begin
                    factor_counter <= 0 ;
                end
            end

            2'b10: begin // gen_speed is 2
                ser_counter <= ser_counter + 1'b1;
                enc_counter <= enc_counter + 1'b1;
                fsm_counter <= fsm_counter + 1'b1;
                factor_counter <= factor_counter + 1'b1;
				  if (count_en_gen2 != 32)  begin
					count_en_gen2 <= count_en_gen2 +1;
			      end
			      else begin
                    count_en_gen2 <= 0;
			      end

                if (ser_counter == 3) begin
                    ser_clk <= ~ser_clk;
                    ser_counter <= 4'b0;
                end
                if (enc_counter == 32) begin
                    enc_clk <= ~enc_clk;
                    enc_counter <= 8'b0;
                end
                if (fsm_counter == 3'b011) begin //clk/4 with delay
		           fsm_counter <= 3'b000;
				   if (count_en_gen2 != 31) begin
			           fsm_clk <= ~fsm_clk;
				   end
				   else begin 
				       fsm_clk <= fsm_clk;
				   end
		        end
		        else begin
			       if (count_en_gen2 == 32) begin
				       fsm_clk <= ~fsm_clk;
				       fsm_counter <= 0;
				   end
				   else begin
		               fsm_counter <= fsm_counter + 1;
				   end
		        end

                 /*if (factor_counter == 32) begin
                    factor_counter <= 0 ;
                end*/

            end
            default: begin // Default to 0
                ser_counter <= ser_counter + 1'b1;
                enc_counter <= enc_counter + 1'b1;
                fsm_counter <= fsm_counter + 1'b1;
                factor_counter <= factor_counter + 1'b1;

                if (ser_counter == 4'd1) begin
                    ser_clk <= ~ser_clk;
                    ser_counter <= 4'b0;
                end
                if (enc_counter == 8'd7) begin
                    enc_clk <= ~enc_clk;
                    enc_counter <= 8'b0;
                end
                if (fsm_counter == FREQ_FACTOR) begin
                    if (factor_counter != (FREQ_FACTOR - 1)) begin
                        fsm_clk <= ~fsm_clk;
                    end
                    fsm_counter <= 7'b0;
                    factor_counter <= 6'b0;
                end
            end
        endcase
    end
end
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
		if (gen_speed ==1) begin
			enc_clk = clk_div_33;
		end	
end		
always @(posedge sb_clk or negedge rst) begin

    if (~rst) begin
        ms_counter <= 0;
		ms_clk <= 1'b0;
    end else begin
         ms_counter <= ms_counter + 1'b1;
                
        if (ms_counter ==4) begin
            ms_clk <= ~ms_clk;
            ms_counter <= 0;
        end
    end
end

endmodule
