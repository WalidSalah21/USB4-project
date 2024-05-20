////////////////////////////////////////////////////////////////////////////////////
// Block: timer
//
// Author: Ahmed Zakaria
//
// Description: sends flags with timeouts necessary for different blocks 
//
/////////////////////////////////////////////////////////////////////////////////////


`default_nettype none

module timer
(
  input  wire sb_clk, //sideband clk --> F = 1M --> T = 1u
  input  wire clk_b, //slower clk --> F = 1K --> T = 1m
  input  wire rst, //rst signal
  input  wire disconnected_s,
  input  wire fsm_disabled,
  input  wire fsm_training,
  input  wire ts1_gen4_s,
  input  wire ts2_gen4_s,
  input  wire sbrx,
  output reg  tdisconnect_tx_min,
  output reg  tdisconnect_rx_min,
  output reg  tconnect_rx_min,
  output reg  tdisabled_min,
  output reg  ttraining_error_timeout,
  output reg  tgen4_ts1_timeout,
  output reg  tgen4_ts2_timeout      
);

localparam TDISCONNECT_TX  = 'd1,
           TDISCONNECT_RX  = 'd14,
           TCONNECT_RX     = 'd25,
           TDISABLED      = 'd10,
		   TTRAINING_ERROR = 'd500,
		   TGEN4_TS1       = 'd400,
		   TGEN4_TS2       = 'd200;

reg [5:0]  tdisconnect_tx_cnt;
reg [3:0]  tdisconnect_rx_cnt;
reg [4:0]  tconnect_rx_cnt;
reg [3:0]  tdisabled_cnt;
reg [8:0]  ttraining_error_cnt;
reg [8:0]  tgen4_ts1_cnt;
reg [7:0]  tgen4_ts2_cnt;
	
always @(posedge sb_clk or negedge rst)
  begin
    if(!rst)
	  begin
        tdisconnect_rx_cnt  <= 'd0;
        tconnect_rx_cnt     <= 'd0;
        ttraining_error_cnt <= 'd0;
	  end
	  
	else
	  begin
        if (sbrx)
		  begin
		  tconnect_rx_cnt <= tconnect_rx_cnt + 1;
		  tdisconnect_rx_cnt <= 0;
		  end
		else
		  begin
		  tconnect_rx_cnt <= 0;
		  tdisconnect_rx_cnt <= tdisconnect_rx_cnt + 1;
		  end
		if(fsm_training)
		  ttraining_error_cnt <= ttraining_error_cnt + 1;
        else
		  ttraining_error_cnt <= 'd0;
	  end
  end
  

always @(posedge clk_b or negedge rst)
  begin
    if(!rst)
	  begin
        tdisconnect_tx_cnt  <= 'd0;
        tdisabled_cnt      <= 'd0;
        tgen4_ts1_cnt       <= 'd0;
        tgen4_ts2_cnt       <= 'd0;
	  end
	  
	else
	  begin
        if(disconnected_s) //if zeros are sent in sbtx
		  if (tdisconnect_tx_cnt != TDISCONNECT_TX)
		    tdisconnect_tx_cnt <= tdisconnect_tx_cnt + 1;
		  else
		    tdisconnect_tx_cnt <= tdisconnect_tx_cnt;
		else
		  tdisconnect_tx_cnt <= 'd0;
        if(fsm_disabled)
		  tdisabled_cnt <= tdisabled_cnt + 1;
        else
		  tdisabled_cnt <= 'd0;
        if(ts1_gen4_s)
		  tgen4_ts1_cnt <= tgen4_ts1_cnt + 1;
        else
		  tgen4_ts1_cnt <= 'd0;
        if(ts2_gen4_s)
		  tgen4_ts2_cnt <= tgen4_ts2_cnt + 1;
        else
		  tgen4_ts2_cnt <= 'd0;
	  end
  end  


always @(posedge sb_clk or negedge rst)
  begin
    if(!rst)
	  begin
        tdisconnect_rx_min  <= 'd0;
        tconnect_rx_min     <= 'd0;
        ttraining_error_timeout <= 'd0;
	  end
	  
	else
	  begin
        tdisconnect_rx_min <= (tdisconnect_rx_cnt == TDISCONNECT_RX);
        tconnect_rx_min <= (tconnect_rx_cnt == TCONNECT_RX);
		ttraining_error_timeout <= (ttraining_error_cnt == TTRAINING_ERROR);
	  end
  end
  
  
always @(posedge clk_b or negedge rst)
  begin
    if(!rst)
	  begin
        tdisconnect_tx_min  <= 'd0;
        tdisabled_min      <= 'd0;
        tgen4_ts1_timeout       <= 'd0;
        tgen4_ts2_timeout       <= 'd0;
	  end
	  
	else
	  begin
        tdisconnect_tx_min <= (tdisconnect_tx_cnt == TDISCONNECT_TX);
        tdisabled_min <= (tdisabled_cnt == TDISABLED);
        tgen4_ts1_timeout <= (tgen4_ts1_cnt == TGEN4_TS1);
        tgen4_ts2_timeout <= (tgen4_ts2_cnt == TGEN4_TS2);
	  end
  end 
 
endmodule

`resetall

