////////////////////////////////////////////////////////////////////////////////////
// Block: lane_distributer
//
// Author: Ahmed Zakaria
//
// Description: distributes data from data bus on both lanes 
//
/////////////////////////////////////////////////////////////////////////////////////

`default_nettype none

module lane_distributer 
(
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
 
reg flag1, flag2;
reg [1:0] counter1;
reg [2:0] counter2;
reg [7:0] data1, data2;

always@(posedge clk or negedge rst)
  begin
	if (!rst) 
      begin
		flag1 <= 0;
		data_os_o <= 0;
		lane_0_rx_out <= 'h0;
		lane_1_rx_out <= 'h0;
		rx_lanes_on <= 0;
		counter1 <= 'h0;
		transport_data_flag <= 1'b0;
	  end
	else if (!enable_r) 
      begin
		flag1 <= 0;
		data_os_o <= 0;
		lane_0_rx_out <= 'h0;
		lane_1_rx_out <= 'h0;
		rx_lanes_on <= 0;
		counter1 <= 'h0;
		transport_data_flag <= 1'b0;
	  end
	else if (data_os_i == 0) //ordered sets received
      begin
		flag1 <= 0;
		data_os_o <= 0;
		lane_0_rx_out <= lane_0_rx_in;
		lane_1_rx_out <= lane_1_rx_in;
		rx_lanes_on <= 1;
		counter1 <= 'h0;
		transport_data_flag <= 1'b0;
	  end
	else //transport layer data received
	  begin
		flag1 <= (counter1 == 'h3)? !flag1 : flag1;
		data_os_o <= 1;
		lane_0_rx_out <= (flag1)? lane_1_rx_in : lane_0_rx_in; //data output to data bus
		lane_1_rx_out <= 'h0;
		rx_lanes_on <= 1;
		counter1 <= (counter1 == 'h3)? 'h0 : counter1 + 1;
		transport_data_flag <= (counter1 == 'h2);
	  end
  end


always@(posedge clk or negedge rst)
  begin
	if (!rst) 
      begin
		data1 <= 0;
		data2 <= 0;
		enable_enc <= 0;
		counter2 <= 0;
		flag2 <= 0;
	  end
	else if (!enable_t) 
      begin
		data1 <= 0;
		data2 <= 0;
		enable_enc <= 0;
		counter2 <= 0;
		flag2 <= 0;
	  end
	else if (d_sel != 8) 
      begin
		data1 <= 0;
		data2 <= 0;
		enable_enc <= 1;
		flag2 <= 0;
	  end
	else 
	  begin
		data1 <= (flag2)? lane_0_tx_in : data1;
		data2 <= (!flag2)? lane_0_tx_in : data2;
		flag2 <= (counter2 == 'h0)? !flag2 : flag2;
		counter2 <= (counter2 == 'h3)? 'h0 : counter2 + 1;
	  end
  end
		
		
always@ (*)
  begin
    if(d_sel != 8)
	  begin
	    lane_0_tx_out = lane_0_tx_in;
	    lane_1_tx_out = lane_1_tx_in;
	  end  
    else if(flag2)
	  begin
	    lane_0_tx_out = lane_0_tx_in;
	    lane_1_tx_out = data2;
	  end
    else
	  begin
	    lane_0_tx_out = data1;
	    lane_1_tx_out = lane_0_tx_in;
	  end
  end
  
endmodule

`resetall
