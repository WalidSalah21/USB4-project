/* 

Author: Ahmed Tarek Shafik Mohamed
Date: 11/2/2024
Block: Transactions generator FSM
Project: USB4 Logical layer Human based VS AI based code
sponsered by: Siemens EDA

Description:

- The following block is responsible of the building of the SB transactions.

- The RTL design Team decided to implement feautures that depends mainly on AT and LT transactions.

- The Block takes (trans_sel) signal from the control unit that enables the block to identify which 
  type of transaction the control unit wants to send in order to initialize the routers on the link.

- for more information please refer to the spec document.

*/


module transactions_gen_fsm (

	input            sb_clk,                            //clk signal slower than the rest of the system
	input            rst,                              //global reset 

	input [ 23 : 0 ] sb_read,                         //data read from the SB register in case of AT read response 
	//input [ 7  : 0 ] control_unit_data,              //data Value to write in AT write command or LEN field or address
	input [ 2  : 0 ] trans_sel,                     //transaction select wire
	input            disconnect_sbtx,  
	input            tdisconnect_tx_min,  


	output reg [ 9 : 0 ] trans,                  //output including start and stop bit
	output reg [ 1 : 0 ] trans_state,            //disconnected, IDLE or started a transaction
	output reg           crc_en,                 //CRC enable data for the pauload only not the delimiters 
	output reg           sbtx_sel,               //mux select signal to show when the data is finished to add CRC parity bits
	output reg           trans_sent,             //indicates transaction sent
	output wire          disconnected_s          //fsm in disconnected state

	);



typedef enum logic [4:0] {
DISCONNECT = 5'b00000,
IDLE = 5'b00001,
DLE1 = 5'b00010,
LSE = 5'b00011,
CLSE = 5'b00100,

STX_COMMAND = 5'b00101,
DATA_WRITE_COMMAND_ADDRESS = 5'b00110,
DATA_WRITE_COMMAND_LENGTH = 5'b00111,
DATA_WRITE_COMMAND_DATA = 5'b01000,

DATA_READ_COMMAND_ADDRESS = 5'b01001,
DATA_READ_COMMAND_LENGTH = 5'b01010,


STX_RESPONSE = 5'b01011,
DATA_WRITE_RESPONSE_ADDRESS = 5'b01100,
DATA_WRITE_RESPONSE_LENGTH = 5'b01101,
DATA_WRITE_RESPONSE_DATA = 5'b01110,

DATA_READ_RESPONSE_ADDRESS = 5'b01111,
DATA_READ_RESPONSE_LENGTH = 5'b10000,
DATA_READ_RESPONSE_DATA = 5'b10001,

CRC1=5'b10010,
CRC2=5'b10011,

DLE2 = 5'b10100,
ETX = 5'b10101

} state;




state cs,ns;





localparam STX_COMMAND_SYMBOL = 8'b00000101;
localparam STX_RESPONSE_SYMBOL = 8'b00000100;


localparam LSE_SYMBOL = 8'b10000000;
localparam CLSE_SYMBOL = ~LSE_SYMBOL;

localparam DISCONNECTED_S = 2'h0,
	       IDLE_S         = 2'h1,
		   START          = 2'h2;



reg [2:0] data_clock_cycles; //clock cycles to burst the data out in write commands 
reg [3:0] ser_clk_cycles;



//registers to ensure the output of the data at rising edge of the clock
reg [9:0] trans_reg ;
reg [1:0] trans_state_reg ;
reg	crc_en_reg ;
reg	sbtx_sel_reg;



//pulse that enables the state machine and hold selection value
reg [2:0] trans_sel_reg;


//delay for sending trans for training sync
reg trans_sent_1;
reg trans_sent_2;
reg trans_sent_3;

always @ (posedge sb_clk or negedge rst) begin

	if (!rst) begin

		trans_sel_reg <= 0;
		trans_sent_1 <= 0;
		trans_sent_2 <= 0;
		trans_sent_3 <= 0;
		trans_sent <= 0;

	end else if (trans_sel != 0) begin
		trans_sel_reg <= trans_sel;
		trans_sent_1 <= 0;
		trans_sent_2 <= trans_sent_1;
		trans_sent_3 <= trans_sent_2;
		trans_sent <= trans_sent_3;

	end else if ((cs==CLSE || cs==ETX) && (ser_clk_cycles==9)) begin
		trans_sel_reg <= 0;
		trans_sent_1 <= 1;
		trans_sent_2 <= trans_sent_1;
		trans_sent_3 <= trans_sent_2;
		trans_sent <= trans_sent_3;
	end else begin
		trans_sel_reg <= trans_sel_reg;
		trans_sent_1 <= 0;
		trans_sent_2 <= trans_sent_1;
		trans_sent_3 <= trans_sent_2;
		trans_sent <= trans_sent_3;
	end
	
end



/**********************************2 always blocks State Machine type***********************************************************/

always @(posedge sb_clk or negedge rst) begin 
	if(~rst) begin
		cs <= DISCONNECT;
	end else begin
		cs <= ns;
	end
end



always @(*) begin 

	trans_reg = trans ;
	crc_en_reg = crc_en ;
	sbtx_sel_reg = sbtx_sel ;
	trans_state_reg = trans_state ;
	ns=cs;
	
	case (cs)

		DISCONNECT: begin 

			if (disconnect_sbtx || !tdisconnect_tx_min) begin

				ns = DISCONNECT;
				trans_reg = 0;
				trans_state_reg = DISCONNECTED_S;
				crc_en_reg = 0;
				sbtx_sel_reg=0;

			end else begin

				ns = IDLE;
				trans_reg = 10'b1111111111;
				trans_state_reg = IDLE_S;
				crc_en_reg = 0;
				sbtx_sel_reg=0;

			end
		end

		IDLE: begin 
			case (trans_sel_reg)

				0: begin 
					ns = IDLE;
					trans_reg = 10'b1111111111;
					trans_state_reg = IDLE_S;
					crc_en_reg = 0;
					sbtx_sel_reg=0;
				end 

				2: begin 
					ns = DLE1;
					trans_reg = {1'b1,8'hFE,1'b0};
					trans_state_reg = START;
					crc_en_reg = 0;
					sbtx_sel_reg=0;
				end 

				3:begin 
					ns = DLE1;
					trans_reg = {1'b1,8'hFE,1'b0};
					trans_state_reg = START;
					crc_en_reg = 0;
					sbtx_sel_reg=0;
				end 

				4: begin 
					ns = DLE1;
					trans_reg = {1'b1,8'hFE,1'b0};
					trans_state_reg = START;
					crc_en_reg = 0;
					sbtx_sel_reg=0;
				end 

				default: begin 
					ns = IDLE;
					trans_reg = 10'b1111111111;
					trans_state_reg = IDLE;
					crc_en_reg = 0;
					sbtx_sel_reg=0;
				end

			endcase

		end

		DLE1: begin 

			if (ser_clk_cycles == 9) begin
				case (trans_sel_reg)

					2: begin 
						ns = STX_COMMAND;
						trans_reg = {1'b1,STX_COMMAND_SYMBOL,1'b0};
						crc_en_reg = 0;
						sbtx_sel_reg=0;
					end 

					3:begin 
						ns = STX_RESPONSE;
						trans_reg = {1'b1,STX_RESPONSE_SYMBOL,1'b0};
						crc_en_reg = 0;
						sbtx_sel_reg=0;
					end 

					4: begin 
						ns = LSE;
						trans_reg = {1'b1,LSE_SYMBOL,1'b0};
						crc_en_reg = 0;
						sbtx_sel_reg=0;
					end 

				endcase

			end

		end

		LSE: begin 

			crc_en_reg = 1;
			
			if (ser_clk_cycles == 9) begin
				case (trans_sel_reg)

					4: begin 
						ns = CLSE;
						trans_reg = {1'b1,CLSE_SYMBOL,1'b0};
						crc_en_reg = 1;
						sbtx_sel_reg=0;
					end 

				endcase
			end

			
		end

		CLSE: begin 

			if (ser_clk_cycles == 9) begin
				case (trans_sel_reg)

					4: begin 
						ns = IDLE;
						trans_reg = 10'b1111111111;
						crc_en_reg = 0;
						sbtx_sel_reg=0;
					end 

				endcase
			end

			
		end

		STX_COMMAND: begin 

			crc_en_reg = 1;
			
			if (ser_clk_cycles == 9) begin
				case (trans_sel_reg)


				2: begin 
					ns = DATA_READ_COMMAND_ADDRESS;
					trans_reg = {1'b1,8'd78,1'b0};
					crc_en_reg = 1;
					sbtx_sel_reg=0;
				end 


			endcase
		end


	end


		DATA_READ_COMMAND_ADDRESS: begin 

			if (ser_clk_cycles == 9) begin
				case (trans_sel_reg) 

					2: begin 
						ns = DATA_READ_COMMAND_LENGTH;
						trans_reg = {1'b1,1'b0,7'h3,1'b0};
						crc_en_reg = 1;
						sbtx_sel_reg=0;
					end 


				endcase
			end

			
		end

		DATA_READ_COMMAND_LENGTH: begin 

			if (ser_clk_cycles == 9) begin
				case (trans_sel_reg) 

					2: begin 
						ns = CRC1;
						trans_reg = 0;
						crc_en_reg = 1;
						sbtx_sel_reg=0;
					end 

				endcase
			end

			
		end





		STX_RESPONSE: begin 

			crc_en_reg = 1;
			
			if (ser_clk_cycles == 9) begin
				case (trans_sel_reg)


				3: begin 
					ns = DATA_READ_RESPONSE_ADDRESS;
					trans_reg = {1'b1,8'd78,1'b0};
					crc_en_reg = 1;
					sbtx_sel_reg=0;
				end 

			endcase
		end


	end



		DATA_READ_RESPONSE_ADDRESS: begin 

			if (ser_clk_cycles == 9) begin
				case (trans_sel_reg) 

					3: begin 
						ns = DATA_READ_RESPONSE_LENGTH;
						trans_reg = {1'b1,1'b0,7'h3,1'b0};
						crc_en_reg = 1;
						sbtx_sel_reg=0;
					end 


				endcase
			end

			
		end

		DATA_READ_RESPONSE_LENGTH: begin 

			if (ser_clk_cycles == 9) begin
				case (trans_sel_reg) 

					3: begin 
						ns = DATA_READ_RESPONSE_DATA;
						trans_reg = {1'b1,sb_read[7:0],1'b0};
						crc_en_reg = 1;
						sbtx_sel_reg=0;
					end 


				endcase
			end

			
		end


		DATA_READ_RESPONSE_DATA: begin

			if (ser_clk_cycles == 9) begin
				case (trans_sel_reg) 

					3: begin 
						if (data_clock_cycles==2) begin
							ns = CRC1;
							trans_reg = 0;
							crc_en_reg = 1;
							sbtx_sel_reg=0;
						end else begin
							case (data_clock_cycles)

								0: begin 
									ns = DATA_READ_RESPONSE_DATA;
									trans_reg = {1'b1,sb_read[15:8],1'b0};
									crc_en_reg = 1;
									sbtx_sel_reg=0;
								end

								1: begin
									ns = DATA_READ_RESPONSE_DATA;
									trans_reg = {1'b1,sb_read[23:16],1'b0};
									crc_en_reg = 1;
									sbtx_sel_reg=0; 
								end


							endcase
						end
					end 

				endcase
			end 



			

		end


		DLE2:  begin 

			crc_en_reg = 0;
			sbtx_sel_reg = 0;
			
			if (ser_clk_cycles == 9) begin
				case (trans_sel_reg)

					2: begin 
						ns = ETX;
						trans_reg = {1'b1,8'h40,1'b0};
						crc_en_reg = 0;
						sbtx_sel_reg=0;
					end 

					3:begin 
						ns = ETX;
						trans_reg = {1'b1,8'h40,1'b0};
						crc_en_reg = 0;
						sbtx_sel_reg=0;
					end 



			endcase
		end


	end



	ETX:  begin 

		if (ser_clk_cycles == 9) begin
			case (trans_sel_reg)

				2: begin 
					ns = IDLE;
					trans_reg = 10'b1111111111;
					crc_en_reg = 0;
					sbtx_sel_reg=0;
				end 

				3:begin 
					ns = IDLE;
					trans_reg = 10'b1111111111;
					crc_en_reg = 0;
					sbtx_sel_reg=0;
				end 


			endcase
		end
	end


		CRC1: begin 

			sbtx_sel_reg=1;
			
			if (ser_clk_cycles == 9) begin

				ns = CRC2;
				trans_reg = 0;
				crc_en_reg = 1;
				sbtx_sel_reg=1;

			end
			
		end

		CRC2: begin 
			  
			if (ser_clk_cycles == 9) begin

				ns = DLE2;
				trans_reg = {1'b1,8'hFE,1'b0};
				crc_en_reg = 1;
				sbtx_sel_reg = 1;

			end

			
		end

endcase

end


/**********************************************************************************************************/


//ensure registered output (release every clock cycle) 
always @(posedge sb_clk) begin 

	
	trans <= trans_reg ;
	crc_en <= crc_en_reg ;
	sbtx_sel <= sbtx_sel_reg ;
	trans_state <= trans_state_reg ;
	
	
end




always @(posedge sb_clk or negedge rst) begin 
	if(~rst) begin
		ser_clk_cycles <= 0;
	end else if (cs != 0  && cs != 1 && ser_clk_cycles < 9) begin
		ser_clk_cycles <= ser_clk_cycles + 1;
	end else begin 
		ser_clk_cycles <= 0 ;
	end
end





//data symbols clock cycles in AT transactions (fixed to 3 bytes)
always @(posedge sb_clk or negedge rst) begin 
	if(~rst) begin
		data_clock_cycles <= 0;
	end else if (data_clock_cycles != 2 && (cs == DATA_WRITE_COMMAND_DATA|| cs == DATA_READ_RESPONSE_DATA) && ser_clk_cycles == 9) begin
		data_clock_cycles <= data_clock_cycles + 1;
	end else if (cs == IDLE) begin 
		data_clock_cycles <= 0 ;
	end else begin 
		data_clock_cycles <= data_clock_cycles;
	end
end


assign disconnected_s = (cs==DISCONNECT);

endmodule 
