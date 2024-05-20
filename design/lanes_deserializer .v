////////////////////////////////////////////////////////////////////////////////////////////////////////
// Block: lanes_deserializer
// Author: Seif Hamdy Fadda
//
// Description: deserialize the serial input into 132-bits output in the lanes
////////////////////////////////////////////////////////////////////////////////////////////////////////

module lanes_deserializer #(parameter WIDTH = 132) (

    input                  rst, clk,
    input                  enable_deser,
	input      [1:0]       gen_speed,
	input                  lane_0_rx_ser, lane_1_rx_ser,
    output reg [WIDTH-1:0] lane_0_rx_parallel, lane_1_rx_parallel,
    output wire            descr_rst,
    output reg             enable_dec
); 

    reg [WIDTH-1:0] temp0;
    reg [WIDTH-1:0] temp1;
	localparam COUNTER_WIDTH = $clog2(WIDTH);
    reg [COUNTER_WIDTH-1:0] count, count_max;
	reg started;
	
	localparam GEN4 = 'b00,
               GEN3 = 'b01,
		       GEN2 = 'b10;
	
	always @(*)
	  begin
	    case(gen_speed)
		GEN4: count_max = 8;
		GEN3: count_max = 132;
		GEN2: count_max = 66;
		default: count_max = 8;
		endcase
	  end
	
	always @(posedge clk or negedge rst) begin
	    if (!rst) begin
            lane_0_rx_parallel <= 'b0;
			lane_1_rx_parallel <= 'b0;
			temp0 <= 'b0;
			temp1 <= 'b0;
			count <= 'b0;
			enable_dec <= 0;
			started <= 0;
		end	
		
		else if (!enable_deser && count == 0) begin
            lane_0_rx_parallel <= 'b0;
			lane_1_rx_parallel <= 'b0;
			temp0 <= 'b0;
			temp1 <= 'b0;
			count <= 'b0;
			enable_dec <= 0;
			started <= 0;
		end	
		
		else begin
			if (gen_speed == GEN4) begin
			    temp0 <= {temp0[6:0], lane_0_rx_ser};
			    temp1 <= {temp1[6:0], lane_1_rx_ser};
			end else begin
			    temp0 <= {lane_0_rx_ser, temp0[WIDTH-1:1]};
			    temp1 <= {lane_1_rx_ser, temp1[WIDTH-1:1]};
			end
			
			if (count == count_max-1)
			  count <= 0;
			  
			else if (count == 0) begin
			    count <= count + 1;
				started <= 1;
				enable_dec <= started;
				case (gen_speed)
			    GEN4 : begin
				         lane_0_rx_parallel <= {124'h0, temp0[7 : 0]};
				         lane_1_rx_parallel <= {124'h0, temp1[7 : 0]};
					   end
					   
			    GEN3 : begin
				         lane_0_rx_parallel <= temp0;
				         lane_1_rx_parallel <= temp1;
					   end
					   
			    GEN2 : begin
				         lane_0_rx_parallel <= {66'h0, temp0[WIDTH-1 : WIDTH-66]};
				         lane_1_rx_parallel <= {66'h0, temp1[WIDTH-1 : WIDTH-66]};
					   end
				endcase
			end	
			
			else begin	
			    count <= count + 1;
			end	
		end	
	end	

    assign descr_rst = (count == count_max-2);	
	
endmodule

`default_nettype none
`resetall
