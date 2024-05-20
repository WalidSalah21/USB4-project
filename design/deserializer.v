////////////////////////////////////////////////////////////////////////////////////////////////////////
// Block: deserializer
// Author: Seif Hamdy Fadda
//
// Description: deserialize the serial input into 8-bits output in the sideband
////////////////////////////////////////////////////////////////////////////////////////////////////////

module deserializer #(parameter WIDTH = 10) (

    input                   rst, clk,
	input                   in_bit, 
    output reg  [WIDTH-1:0] parallel_data
); 
    reg        [WIDTH-1:0]        temp, temp1;
	localparam COUNTER_WIDTH =    $clog2(WIDTH);
    reg       [COUNTER_WIDTH-1:0] count;
	reg                           start, started;
	
	always @(posedge clk or negedge rst) begin
	    if (!rst) begin
			temp <= 0;
			parallel_data <= 0;
			count <= 0;
		end	
		else if (start) begin
			temp <= {in_bit, temp[WIDTH-1:1]};
			if (count == WIDTH-1) begin
			    count <= 0;
				parallel_data <= {in_bit, temp[WIDTH-1:1]};
			end	
			else begin	
			    count <= count + 1;
			end
		end	
	end		
	
	//assign parallel_data = (count == WIDTH-1)? {in_bit, temp[WIDTH-1:1]} : temp1; 
	
	always @(*) begin
	    if (count == 0 && in_bit == 0) 
            start = 1;
	    else if (count == 0 && in_bit != 0) 
            start = 0;
	    else if (started) 
            start = 1;
		else
			start = 0;
	end	
	
	always @(posedge clk) begin
		if (!rst)
		    started <= 0;
		else if (count == 0 && start)
		    started <= 1;
		else if (count == 0 && !start)
		    started <= 0;
	end	
	
endmodule			

`default_nettype none
`resetall

