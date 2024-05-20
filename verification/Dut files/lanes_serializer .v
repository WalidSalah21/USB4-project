////////////////////////////////////////////////////////////////////////////////////////////////////////
// Block: lanes serializer
// Author: Seif Hamdy Fadda
//
// Description: serialize the parallel input (the WIDTH depends on the gen speed) in the lanes
////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module lanes_serializer #(parameter WIDTH = 132)
(
    input                  clk, rst,
    input                  enable_ser,
    input      [WIDTH-1:0] lane_0_tx_parallel,
    input      [WIDTH-1:0] lane_1_tx_parallel,
    input      [1:0]       gen_speed,
    output reg             lane_0_tx_ser,
    output reg             lane_1_tx_ser,
    output reg             scr_rst, //signal to resest scrambler's seed
    output reg             enable_scr
);
    reg        [WIDTH-1:0] temp;
    reg        [WIDTH-1:0] temp1;
	localparam COUNTER_WIDTH = $clog2(WIDTH);
    reg        [COUNTER_WIDTH-1:0] count, count_max;
	wire done;
	
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
            lane_0_tx_ser <= 1'b0;
            lane_1_tx_ser <= 1'b0;
            temp <= 'b0;
            temp1 <= 'b0;
            count <= 'b0;
			scr_rst <= 0;
			enable_scr <= 0;
        end
        else if (!enable_ser) begin
            lane_0_tx_ser <= 1'b0;
            lane_1_tx_ser <= 1'b0;
            temp <= 0;
            temp1 <= 0;
            count <= count_max-1;
			scr_rst <= 0;
			enable_scr <= 0;
        end
        else begin
            if (gen_speed == GEN4) begin
			    lane_0_tx_ser <= temp[7];
                lane_1_tx_ser <= temp1[7];
                temp  <= (done)? lane_0_tx_parallel : {temp[6:0], 1'b0};
                temp1 <= (done)? lane_1_tx_parallel : {temp1[6:0], 1'b0};
            end else begin
			    lane_0_tx_ser <= temp[0];
                lane_1_tx_ser <= temp1[0];
                temp  <= (done)? lane_0_tx_parallel : {1'b0, temp[WIDTH-1:1]};
                temp1 <= (done)? lane_1_tx_parallel : {1'b0, temp1[WIDTH-1:1]};
			end
			count <= (done)? 1'b0 : count+1;
			scr_rst <= done;
			enable_scr <= 1;
            end
        end
		
	assign done = (count == count_max-1);
		
endmodule

`default_nettype none
`resetall
