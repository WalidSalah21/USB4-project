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
reg [127:0] data_0;
reg [127:0] data_1;

// Index of the current memory location
reg [3:0] mem_index;
reg [3:0] d_sel_reg; // to save values when mem_index not 1
integer i;

always @(*) begin
    // Continuous assignment of mem_0 to data_0
    for ( i = 0; i < 16; i = i + 1) begin
        data_0[i*8 +: 8] = mem_0[i];
    end
    // Continuous assignment of mem_1 to data_1
    for ( i = 0; i < 16; i = i + 1) begin
        data_1[i*8 +: 8] = mem_1[i];
    end
end

always @(posedge enc_clk or negedge rst) begin
    if (~rst) begin
        // Reset condition: rst = 0
        lane_0_tx_enc_old <= 0;
        lane_1_tx_enc_old <= 0;
        enable_ser <= 0;
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
        // Reset mem_index
        mem_index <= 0;
    end else begin
        // Main logic based on gen_speed and d_sel
        case (gen_speed)
          
            0: begin //gen 4 as rx as byte
                new_sym <= enc_clk;
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
                end else begin
                    // Encoding
                    if (d_sel != 8) begin
                        // ordered sets data
                        lane_0_tx_enc_old <= {data_0[127:0],4'b0101};
                        lane_1_tx_enc_old <= {data_1[127:0],4'b0101};
                        enable_ser <= 1;
                         // Store lane_0_tx and lane_1_tx in mem_0[0] and mem_1[0]
                    mem_0[0] <= lane_0_tx;
                    mem_1[0] <= lane_1_tx;
                    end else if (d_sel == 8)begin
                        // Encoding transport data 
                        lane_0_tx_enc_old <= {data_0[127:0],4'b1010};
                        lane_1_tx_enc_old <= {data_1[127:0],4'b1010};
                    end
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
                  
                end else if (d_sel != 8) begin
                  //ordered set
                        lane_0_tx_enc_old <= {data_0[63:0],2'b01};
						            lane_1_tx_enc_old <= {data_1[63:0],2'b01};
						             enable_ser <= 1;
						             mem_0 [0] <= lane_0_tx;
					              	mem_1 [0] <= lane_1_tx;
						             end
                  
                    
                    else if (d_sel == 8) begin
                        // Transport layer data
                        lane_0_tx_enc_old <= {data_0[63:0],2'b10};
					         	   lane_1_tx_enc_old <= {data_1[63:0],2'b10};
						           enable_ser <= 1;

						mem_0 [0] <= lane_0_tx;
						mem_1 [0] <= lane_1_tx;
                end
            end
            default: begin
                // Other cases or default behavior
                // You can add more cases or define the default behavior as needed
            end
        endcase
    end
end

// Update mem_index based on conditions
always @(posedge enc_clk or negedge rst) begin
    if (~rst) begin
        mem_index <= 0;
    end else if (enable && ((gen_speed == 2 && mem_index <= 8 && d_sel != 9) || (gen_speed == 1 && mem_index <= 16 && d_sel != 9))) begin
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
		new_sym <= enc_clk; end
	if (gen_speed == 'h2 && mem_index == 7) begin
        new_sym <= 1'b1;
	end else if (gen_speed == 'h1 && mem_index == 15) begin
        new_sym <= 1'b1;
    end else begin
        new_sym <= enc_clk;
    end
end

endmodule
`resetall	
