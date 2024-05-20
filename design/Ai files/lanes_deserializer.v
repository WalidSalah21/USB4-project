`default_nettype none

module lanes_deserializer
(
    input wire clk,                    // Clock input
    input wire rst,                    // Active low reset
    input wire enable,                 // Enable signal for deserialization
    input wire [1:0] gen_speed,        // 2-bit input for generation speed
    input wire Lane_0_rx_in,           // Serial data input for Lane 0
    input wire Lane_1_rx_in,           // Serial data input for Lane 1
    output reg [131:0] Lane_0_rx_out,  // Parallel data output for Lane 0
    output reg [131:0] Lane_1_rx_out,  // Parallel data output for Lane 1
    output reg enable_dec,             // Ready signal, high when not deserializing
    output wire descr_rst                // Reset seed of descrambler in the following stage
);

    // Internal variables
    reg [131:0] shift_reg0;
    reg [131:0] shift_reg1;
    reg [7:0] counter, max_numb;
	reg start;
	
	
	always @(*)
	  begin
	    case(gen_speed)
		2'b00: max_numb = 8;
		2'b01: max_numb = 132;
		2'b10: max_numb = 66;
		default: max_numb = 8;
		endcase
	  end
	
	always @(posedge clk or negedge rst) begin
	    if (!rst) begin
            Lane_0_rx_out <= 'b0;
			Lane_1_rx_out <= 'b0;
			shift_reg0 <= 'b0;
			shift_reg1 <= 'b0;
			counter <= 'b0;
			enable_dec <= 0;
			start <= 0;
		end	
		
	    else if (!enable) begin
            Lane_0_rx_out <= 'b0;
			Lane_1_rx_out <= 'b0;
			shift_reg0 <= 'b0;
			shift_reg1 <= 'b0;
			counter <= 'b0;
			enable_dec <= 0;
			start <= 0;
		end	
		
		else begin
			if (gen_speed == 2'b00) begin
			    shift_reg0 <= {shift_reg0[6:0], Lane_0_rx_in};
			    shift_reg1 <= {shift_reg1[6:0], Lane_1_rx_in};
			end else begin
			    shift_reg0 <= {Lane_0_rx_in, shift_reg0[131:1]};
			    shift_reg1 <= {Lane_1_rx_in, shift_reg1[131:1]};
			end
			
			if (counter == max_numb-1)
			  counter <= 0;
			  
			else if (counter == 0) begin
			    counter <= counter + 1;
				start <= 1;
				enable_dec <= start;
				case (gen_speed)
			    2'b00 : begin
				         Lane_0_rx_out <= {124'h0, shift_reg0[7 : 0]};
				         Lane_1_rx_out <= {124'h0, shift_reg1[7 : 0]};
					   end
					   
			    2'b01 : begin
				         Lane_0_rx_out <= shift_reg0;
				         Lane_1_rx_out <= shift_reg1;
					   end
					   
			    2'b10 : begin
				         Lane_0_rx_out <= {66'h0, shift_reg0[131 : 66]};
				         Lane_1_rx_out <= {66'h0, shift_reg1[131 : 66]};
					   end
				endcase
			end	
			
			else begin	
			    counter <= counter + 1;
			end	
		end	
	end	

    assign descr_rst = (counter == max_numb-2);
endmodule

`resetall
