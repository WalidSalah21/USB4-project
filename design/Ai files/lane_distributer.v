/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Block: lane_distributer
//Author: Seif Hamdy Fadda
//
//Description: distributtion of data from data bus on lane 0 and lane 1
//Note: This block is implemented totally using AI (Chatgpt 3.5). 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
`default_nettype none
module lane_distributer (
    input  wire       clk,
    input  wire       rst, 
    input  wire       enable_t, //enable for transmitting side
    input  wire       enable_r, //enable for receiving side
    input  wire       data_os_i, 
    input  wire [3:0] d_sel, 
    input  wire [7:0] lane_0_tx_in, //data input from data bus
    input  wire [7:0] lane_1_tx_in, //data input from data bus
    input  wire [7:0] lane_0_rx_in, 
    input  wire [7:0] lane_1_rx_in, 
    output reg  [7:0] lane_0_tx_out, 
    output reg  [7:0] lane_1_tx_out, 
    output reg  [7:0] lane_0_rx_out, //data output to data bus
    output reg  [7:0] lane_1_rx_out, //data output to data bus
    output reg        enable_enc, //enable encoder next stage
    output reg        rx_lanes_on, //enable data bus rx side
	output reg        data_os_o,
    output reg        transport_data_flag 
);

// Transmitter
reg [7:0] lane_0_tx_reg;
reg [7:0] lane_1_tx_reg;
reg [1:0] tx_counter;
reg tx_flip_flop;

always @(posedge clk or negedge rst) begin
    if (!rst) begin
        lane_0_tx_out <= 8'b0;
        lane_1_tx_out <= 8'b0;
        tx_counter <= 2'b0;
        tx_flip_flop <= 1'b0;
        lane_0_tx_reg <= 8'b0; // Reset register
        lane_1_tx_reg <= 8'b0; // Reset register
        enable_enc <= 1'b0; // Reset enable_enc
    end
    else begin
        if (!enable_t) begin
            lane_0_tx_reg <= 8'b0; // Reset register
            lane_1_tx_reg <= 8'b0; // Reset register
            tx_counter <= 2'b0;
            tx_flip_flop <= 1'b0;
            enable_enc <= 1'b0; // Disable encoder
        end
        else begin
            if (d_sel != 4'h8) begin
                enable_enc <= 1'b1; // Enable encoder
                lane_0_tx_reg <= 8'b0; // Reset register
                lane_1_tx_reg <= 8'b0; // Reset register
				tx_flip_flop <= 0;
				tx_counter <= 0;
            end
            else begin
            if (tx_counter == 2'b11) begin
                tx_counter <= 2'b00; // Reset counter
            end
            else begin
                tx_counter <= tx_counter + 1'b1; // Increment counter
            end
            
            // Toggle the flip-flop when counter is zero
            if (tx_counter == 2'b00) begin
                tx_flip_flop <= ~tx_flip_flop;
            end
            
            // Update registers based on flip-flop value
            if (tx_flip_flop) begin // At the rising edge
                lane_0_tx_reg = lane_0_tx_in;
            end
            else begin // At the falling edge
                lane_1_tx_reg = lane_0_tx_in;
            end
			end 
        end
    end
end

// Transmitting combinational always block
always @* begin
    if (d_sel != 4'h8) begin // Forward ordered sets
        lane_0_tx_out = lane_0_tx_in;
        lane_1_tx_out = lane_1_tx_in;
    end
    else begin // Data input
        if (tx_flip_flop) begin // At the rising edge
            lane_0_tx_out = lane_0_tx_in;
            lane_1_tx_out = lane_1_tx_reg;
        end
        else begin // At the falling edge
            lane_1_tx_out = lane_0_tx_in;
            lane_0_tx_out = lane_0_tx_reg;
        end
    end
end

// Receiver
reg [1:0] rx_counter;
reg rx_flip_flop;

always @(posedge clk or negedge rst) begin
    if (!rst) begin
        lane_0_rx_out <= 8'b0;
        lane_1_rx_out <= 8'b0;
        rx_counter <= 2'b0;
        rx_flip_flop <= 1'b0;
		rx_lanes_on <= 1'b0;
		data_os_o <= 1'b0;
		transport_data_flag <= 1'b0;
		
    end
    else begin
        if (!enable_r) begin
            lane_0_rx_out <= 8'b0;
            lane_1_rx_out <= 8'b0;
            rx_counter <= 2'b0;
            rx_flip_flop <= 1'b0;
            rx_lanes_on <= 1'b0; // Disable output lanes
			data_os_o <= 1'b0;
			transport_data_flag <= 1'b0;

        end
        else begin
            rx_lanes_on <= 1'b1; // Enable output lanes
            
            if (data_os_i) begin
			    data_os_o <= 1'b1;
				transport_data_flag <= (rx_counter == 'h2);
                if (rx_counter == 2'b11) begin
                    rx_flip_flop <= ~rx_flip_flop; // Flip the flip-flop when counter is 3
                    rx_counter <= 2'b00; // Reset counter
                end
                else begin
                    rx_counter <= rx_counter + 1'b1; // Increment counter
                end
                
                // Update output lanes based on flip-flop value
                if (rx_flip_flop) begin // At the rising edge
                    lane_0_rx_out = lane_1_rx_in;
                    lane_1_rx_out = 8'b0;
                end
                else begin // At the falling edge
                    lane_0_rx_out = lane_0_rx_in;
                    lane_1_rx_out = 8'b0;
                end
            end
            else begin
                rx_counter <= 2'b0; // Reset counter
                lane_0_rx_out <= lane_0_rx_in; // Forward inputs to outputs
                lane_1_rx_out <= lane_1_rx_in;
                rx_flip_flop <= 1'b0; // Reset flip_flop
				data_os_o <= 1'b0;
				transport_data_flag <= 1'b0;
            end
        end
    end
end

endmodule

`resetall	
