////////////////////////////////////////////////////////////////////////////////////////////////////////
// Block: serializer
// Author: Seif Hamdy Fadda
//
// Description: serialize the parallel input (10-bits) in the sideband 
////////////////////////////////////////////////////////////////////////////////////////////////////////

module serializer #(parameter WIDTH = 10)
(
    input                  clk, rst,
    input      [WIDTH-1:0] parallel_in,
    input      [1:0]       trans_state,
    output reg             ser_out
);
    reg [WIDTH-1:0] temp;
	localparam      COUNTER_WIDTH = $clog2(WIDTH);
    reg        [COUNTER_WIDTH-1:0] count;
	
	localparam DISCONNECTED_S = 2'h0,
	           IDLE_S         = 2'h1,
			   START          = 2'h2;

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            ser_out <= 1'b0;
            temp <= 'b0;
            count <= 0;
        end
        else begin
            case (trans_state)
			  DISCONNECTED_S: begin
			    ser_out <= 0;
				count <= 0;
			  end
			  
			  IDLE_S: begin      
			    ser_out <= 1;
				count <= 0;
			  end
			  
			  START: begin
			  
			    if (count == 0) begin
				    ser_out <= parallel_in[0];
					temp <= parallel_in;
					count <= WIDTH-1;
				end
				
				else begin
				    ser_out <= temp[1];
					temp <= {1'b0, temp[WIDTH-1:1]};
					count <= count - 1;
				end
				
			  end
			endcase
        end
    end

endmodule

`default_nettype none
`resetall
