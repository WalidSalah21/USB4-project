`default_nettype none
module encoding_block (
    input wire enc_clk,
    input wire rst,
    input wire enable,
    input wire [7:0] lane_0_tx,
    input wire [7:0] lane_1_tx,
    input wire [3:0] d_sel,
    input wire [1:0] gen_speed,
    output reg [131:0] lane_0_tx_enc_old,
    output reg [131:0] lane_1_tx_enc_old,
    output reg enable_ser,
    output reg new_sym
);

// Define arrays to store data from Lane 0 and Lane 1
reg [7:0] mem_0 [15:0];
reg [7:0] mem_1 [15:0];

// Define data registers
wire [127:0] data_0;
wire [127:0] data_1;

// Index of the current memory location
	reg [4:0] mem_index;
reg [3:0] d_sel_reg; // to save values when mem_index not 1
integer i;

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
    if (~rst) begin
        // Reset condition: rst = 0
        lane_0_tx_enc_old <= 0;
        lane_1_tx_enc_old <= 0;
        enable_ser <= 0;
	    d_sel_reg=0;
        // Reset mem_0 and mem_1
        for ( i = 0; i < 16; i = i + 1) begin
            mem_0[i] <= 0;
            mem_1[i] <= 0;
        end
        // Reset mem_index
        mem_index <= 0;
    end else if (~enable) begin
        // Enable condition: enable = 0
        lane_0_tx_enc_old <= 0;
        lane_1_tx_enc_old <= 0;
        enable_ser <= 0;
	    d_sel_reg=0;
     
    end else begin
        // Main logic based on gen_speed and d_sel
        case (gen_speed)
          
            0: begin //gen 4 as rx as byte
                
				lane_0_tx_enc_old <= lane_0_tx;
				lane_1_tx_enc_old <= lane_1_tx;
				enable_ser <= 1;

			end
            
            1: begin
            
            // gen_speed = 3
                if (mem_index <= 15) begin
                  d_sel_reg <= (mem_index== 1)? d_sel : d_sel_reg;
                    mem_0[mem_index] <= lane_0_tx;
                    mem_1[mem_index] <= lane_1_tx;
                end else if (d_sel_reg != 8  && gen_speed==1 ) begin
                        // ordered sets data
                        lane_0_tx_enc_old <= {data_0[127:0],4'b0101};
                        lane_1_tx_enc_old <= {data_1[127:0],4'b0101};
                        enable_ser <= 1;
                         // Store lane_0_tx and lane_1_tx in mem_0[0] and mem_1[0]
                    mem_0[0] <= lane_0_tx;
                    mem_1[0] <= lane_1_tx;
			end else if (d_sel_reg == 8 && gen_speed==1)begin
                        // Encoding transport data 
                        lane_0_tx_enc_old <= {data_0[127:0],4'b1010};
                        lane_1_tx_enc_old <= {data_1[127:0],4'b1010};

                    enable_ser <= 1;
                    // Store lane_0_tx and lane_1_tx in mem_0[0] and mem_1[0]
                    mem_0[0] <= lane_0_tx;
                    mem_1[0] <= lane_1_tx;
                end
            end
     
            2: begin // gen_speed = 2
                if (mem_index <= 7) begin
                    d_sel_reg <= (mem_index == 1)? d_sel : d_sel_reg;
                    mem_0[mem_index] <= lane_0_tx;
                    mem_1[mem_index] <= lane_1_tx;
                  
		end else if (d_sel_reg != 8 && gen_speed==2) begin
                  //ordered set
                        lane_0_tx_enc_old <= {data_0[63:0],2'b01};
						            lane_1_tx_enc_old <= {data_1[63:0],2'b01};
						             enable_ser <= 1;
						             mem_0 [0] <= lane_0_tx;
					              	mem_1 [0] <= lane_1_tx;
						             end
                  
                    
		    else if (d_sel_reg  == 8&& gen_speed==2) begin
                        // Transport layer data
                        lane_0_tx_enc_old <= {data_0[63:0],2'b10};
					         	   lane_1_tx_enc_old <= {data_1[63:0],2'b10};
						           enable_ser <= 1;

						mem_0 [0] <= lane_0_tx;
						mem_1 [0] <= lane_1_tx;
                end
            end
            
        endcase
    end
end

// Update mem_index based on conditions
always @(posedge enc_clk or negedge rst) begin
    if (~rst) begin
        mem_index <= 0;
    end
	else if(~enable ) begin 
        mem_index <=0;
    end
	else if ( (gen_speed == 2 && mem_index < 8 && d_sel != 9) || (gen_speed == 1 && mem_index < 16 && d_sel != 9)) begin
	mem_index <= mem_index + 1;
		end else if (d_sel != 9) begin
        mem_index <= 1;
    end else begin
        mem_index <= 0;
    end
end

// Continuous assignment of new_sym
always @(*) begin
	if(d_sel == 'h9) begin
		new_sym <= enc_clk;
	end else if (gen_speed == 'h2) begin
		if(d_sel == 'h3)
			new_sym <= (mem_index == 8);
			else
				new_sym <= (mem_index== 7);
		
	end else if (gen_speed == 'h1) begin
		if(d_sel == 'h3)
			new_sym <= (mem_index == 16);
			else
				new_sym <= (mem_index== 15);
    end else begin
        new_sym <= enc_clk;
    end
end

endmodule
`resetall	

