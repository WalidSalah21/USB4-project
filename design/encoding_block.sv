/* 

Author: Ahmed Tarek Shafik Mohamed
Date: 29/2/2024
Block: encoding block
Project: USB4 Logical layer Human based VS AI based code
sponsered by: Siemens EDA

Description:

- The following block is responsible of encoidng the lanes data to a 
64b/66b or 128b/132b data encoding scheme

- the block is generic, depending on the gen_speed signal the block adapts itself
to one of the encoding schemes

- for more information please refer to the spec document.

*/



module encoding_block 


	(

		input           enc_clk,
		input           rst,     
		input           enable,

		input [ 7 : 0 ] lane_0_tx,
		input [ 7 : 0 ] lane_1_tx,

  	    input [ 3 : 0 ] d_sel,
  	    input [ 1 : 0 ] gen_speed,


  	    output reg [ 131 : 0 ] lane_0_tx_enc_old,
  	    output reg [ 131 : 0 ] lane_1_tx_enc_old,

  	    output reg             enable_ser,
  	    output reg             new_sym

  	    );




	reg [7:0] mem_0  [16];
	reg [7:0] mem_1  [16];

	reg [4:0] byte_numb;
	reg [3:0] d_sel_reg;




	reg [127:0] data_0,data_1;








	assign data_0 [7:0] = mem_0 [0];
	assign data_0 [15:8] = mem_0 [1];
	assign data_0 [23:16] = mem_0 [2];
	assign data_0 [31:24] = mem_0 [3];
	assign data_0 [39:32] = mem_0 [4];
	assign data_0 [47:40] = mem_0 [5];
	assign data_0 [55:48] = mem_0 [6];
	assign data_0 [63:56] = mem_0 [7];
	assign data_0 [71:64] = mem_0 [8];
	assign data_0 [79:72] = mem_0 [9];
	assign data_0 [87:80] = mem_0 [10];
	assign data_0 [95:88] = mem_0 [11];
	assign data_0 [103:96] = mem_0 [12];
	assign data_0 [111:104] = mem_0 [13];
	assign data_0 [119:112] = mem_0 [14];
	assign data_0 [127:120] = mem_0 [15];


	assign data_1 [7:0] = mem_1 [0];
	assign data_1 [15:8] = mem_1 [1];
	assign data_1 [23:16] = mem_1 [2];
	assign data_1 [31:24] = mem_1 [3];
	assign data_1 [39:32] = mem_1 [4];
	assign data_1 [47:40] = mem_1 [5];
	assign data_1 [55:48] = mem_1 [6];
	assign data_1 [63:56] = mem_1 [7];
	assign data_1 [71:64] = mem_1 [8];
	assign data_1 [79:72] = mem_1 [9];
	assign data_1 [87:80] = mem_1 [10];
	assign data_1 [95:88] = mem_1 [11];
	assign data_1 [103:96] = mem_1 [12];
	assign data_1 [111:104] = mem_1 [13];
	assign data_1 [119:112] = mem_1 [14];
	assign data_1 [127:120] = mem_1 [15];





	always @(posedge enc_clk or negedge rst) begin 
		if(~rst) begin
			byte_numb <= 0;
		end else if(~enable) begin
			byte_numb <= 0;
		end else if (byte_numb < 8 && gen_speed==2 && d_sel != 9) begin
			byte_numb <= byte_numb + 1;
		end else if (byte_numb < 16 && gen_speed==1 && d_sel != 9) begin
			byte_numb <= byte_numb + 1;
		end else if (d_sel != 9) begin 
			byte_numb <= 1;
		end else begin
			byte_numb <= 0;
		end
	end


	always @(posedge enc_clk or negedge rst) begin 

		if(~rst) begin

			lane_0_tx_enc_old <= 0;
			lane_1_tx_enc_old <= 0;
			enable_ser <= 0 ;
			d_sel_reg <= 0 ;

		end else if(~enable) begin

			lane_0_tx_enc_old <= 0;
			lane_1_tx_enc_old <= 0;
			enable_ser <= 0 ;
			d_sel_reg <= 0 ;
			
		end else begin

			case (gen_speed)

				2: begin 

					if (byte_numb <= 7) begin

						d_sel_reg <= (byte_numb == 1)? d_sel : d_sel_reg;
						mem_0 [byte_numb] <= lane_0_tx;
						mem_1 [byte_numb] <= lane_1_tx;

					end else if (d_sel_reg != 8 && gen_speed==2) begin 
						lane_0_tx_enc_old <= {data_0[63:0],2'b01};
						lane_1_tx_enc_old <= {data_1[63:0],2'b01};
						enable_ser <= 1;

						mem_0 [0] <= lane_0_tx;
						mem_1 [0] <= lane_1_tx;

					end else if (d_sel_reg == 8 && gen_speed==2) begin 
						lane_0_tx_enc_old <= {data_0[63:0],2'b10};
						lane_1_tx_enc_old <= {data_1[63:0],2'b10};
						enable_ser <= 1;

						mem_0 [0] <= lane_0_tx;
						mem_1 [0] <= lane_1_tx;
					end


				end


				1: begin 

					if (byte_numb <= 15) begin

						d_sel_reg <= (byte_numb == 1)? d_sel : d_sel_reg;
						mem_0 [byte_numb] <= lane_0_tx;
						mem_1 [byte_numb] <= lane_1_tx;


					end else if (d_sel_reg != 8 && gen_speed==1) begin 
						lane_0_tx_enc_old <= {data_0[127:0],4'b0101};
						lane_1_tx_enc_old <= {data_1[127:0],4'b0101};
						enable_ser <= 1;

						mem_0 [0] <= lane_0_tx;
						mem_1 [0] <= lane_1_tx;

					end else if (d_sel_reg == 8 && gen_speed==1) begin 
						lane_0_tx_enc_old <= {data_0[127:0],4'b1010};
						lane_1_tx_enc_old <= {data_1[127:0],4'b1010};
						enable_ser <= 1;

						mem_0 [0] <= lane_0_tx;
						mem_1 [0] <= lane_1_tx;

					end
				end




				0: begin 

					lane_0_tx_enc_old <= lane_0_tx;
					lane_1_tx_enc_old <= lane_1_tx;
					enable_ser <= 1;

					

				end




			endcase

		end 

	end
	
	
	always @(*) begin 
		if(d_sel == 'h9) begin
			new_sym <= enc_clk;
		end else if(gen_speed == 'h2) begin
			if(d_sel == 'h3)
			  new_sym <= (byte_numb == 8);
			else
			  new_sym <= (byte_numb == 7);
		end else if(gen_speed == 'h1) begin
			if(d_sel == 'h3)
			  new_sym <= (byte_numb == 16);
			else
			  new_sym <= (byte_numb == 15);
		end else begin
			new_sym <= enc_clk;
		end
	end

endmodule
