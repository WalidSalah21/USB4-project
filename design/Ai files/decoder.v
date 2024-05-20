`default_nettype none
module decoding_block (
    input wire enc_clk,
    input wire rst,
    input wire enable_dec,
    input wire [131:0] lane_0_rx_enc,
    input wire [131:0] lane_1_rx_enc,
    input wire [1:0] gen_speed,
    input wire [3:0] d_sel,
    output reg [7:0] lane_0_rx,
    output reg [7:0] lane_1_rx,
    output reg       data_os,
    output reg enable_deskew
);

// Define arrays to store decoded data
reg [7:0] mem_0 [16:0];
reg [7:0] mem_1 [16:0];

// Index of the current memory location
reg [3:0] mem_index;
//reg [3:0] d_sel_reg; // to save values when mem_index not 1
reg flag;
reg [3:0] max_byte_num;

integer i;

localparam GEN4 = 'b00,
               GEN3 = 'b01,
		       GEN2 = 'b10;



always @(*) begin
    case (gen_speed)
        GEN4: max_byte_num = 0;
        GEN2: max_byte_num = 7;
        GEN3: max_byte_num = 15;
        default: max_byte_num = 1;
    endcase
end


always @(posedge enc_clk or negedge rst) begin
    if (~rst) begin
        // Reset condition: rst = 0
        lane_0_rx <= 0;
        lane_1_rx <= 0;
        enable_deskew <= 0;
        data_os <= 0;
        // Reset mem_index
        mem_index <= 0;
        flag <= 0;
        
    end else if(~enable_dec&& mem_index == 0) begin

			enable_deskew <= 0;
			flag <= 0;
			lane_0_rx <= mem_0[mem_index];
			lane_1_rx <= mem_1[mem_index];

		end else begin
		
			lane_0_rx <= mem_0[mem_index];
			lane_1_rx <= mem_1[mem_index];
			
			if (mem_index == 0) begin
            flag <= 1;
        if (gen_speed == 0) begin
            enable_deskew <= flag;
        end else begin
            enable_deskew <= 1;
        end
			end

			
        case (gen_speed)
            GEN4: begin // gen_speed = 4
            // Save lane_0_rx_enc as bytes in mem_0 locations from 0 to 15
            if (mem_index==0) begin
                    for (i = 0; i < 16; i = i + 1) begin
                        mem_0[i] <= lane_0_rx_enc[i*8 +: 8];
                         mem_1[i] <= lane_0_rx_enc[i*8 +: 8];
                    end
                  end
                
                if (d_sel == 8 ) begin
                    data_os <= 1;
                  end
                  else begin
                    data_os <= 0;
                  end
                    
                end

            GEN3: begin // gen_speed = 1
                if (mem_index == 15) begin
                    // Save lane_0_rx_enc as bytes in mem_0 locations from 0 to 15
                                mem_0 [0] <= lane_0_rx_enc[11 : 4];
				mem_0 [1] <= lane_0_rx_enc[19 : 12];
				mem_0 [2] <= lane_0_rx_enc[27 : 20];
				mem_0 [3] <= lane_0_rx_enc[35 : 28];
				mem_0 [4] <= lane_0_rx_enc[43 : 36];
				mem_0 [5] <= lane_0_rx_enc[51 : 44];
				mem_0 [6] <= lane_0_rx_enc[59 : 52];
				mem_0 [7] <= lane_0_rx_enc[67 : 60];
				mem_0 [8] <= lane_0_rx_enc[75 : 68];
				mem_0 [9] <= lane_0_rx_enc[83 : 76];
				mem_0 [10] <= lane_0_rx_enc[91 : 84];
				mem_0 [11] <= lane_0_rx_enc[99 : 92];
				mem_0 [12] <= lane_0_rx_enc[107 : 100];
				mem_0 [13] <= lane_0_rx_enc[115 : 108];
				mem_0 [14] <= lane_0_rx_enc[123 : 116];
				mem_0 [15] <= lane_0_rx_enc[131 : 124];
				mem_0 [16] <= lane_0_rx_enc[3 : 0];


			  	mem_1 [0] <= lane_1_rx_enc[11 : 4];
				mem_1 [1] <= lane_1_rx_enc[19 : 12];
				mem_1 [2] <= lane_1_rx_enc[27 : 20];
				mem_1 [3] <= lane_1_rx_enc[35 : 28];
				mem_1 [4] <= lane_1_rx_enc[43 : 36];
				mem_1 [5] <= lane_1_rx_enc[51 : 44];
				mem_1 [6] <= lane_1_rx_enc[59 : 52];
				mem_1 [7] <= lane_1_rx_enc[67 : 60];
				mem_1 [8] <= lane_1_rx_enc[75 : 68];
				mem_1 [9] <= lane_1_rx_enc[83 : 76];
				mem_1 [10] <= lane_1_rx_enc[91 : 84];
				mem_1 [11] <= lane_1_rx_enc[99 : 92];
				mem_1 [12] <= lane_1_rx_enc[107 : 100];
				mem_1 [13] <= lane_1_rx_enc[115 : 108];
				mem_1 [14] <= lane_1_rx_enc[123 : 116];
				mem_1 [15] <= lane_1_rx_enc[131 : 124];
				mem_1 [16] <= lane_1_rx_enc[3 : 0];
                end
                    
		    if (mem_0[16][3:0] == 4'b0101) begin
                        // Ordered sets
                        data_os <= 0;
		    end else if (mem_0[16][3:0] == 4'b1010) begin
                        // Transport layer data
                        data_os <= 1;
                end
            end
       
            
           GEN2: begin // gen_speed = 2
                if (mem_index == 7) begin
                    // Save lane_0_rx_enc as bytes in mem_0 locations from 0 to 7
                mem_0 [0] <= lane_0_rx_enc[9 : 2];
                mem_0 [1] <= lane_0_rx_enc[17 : 10];
                mem_0 [2] <= lane_0_rx_enc[25 : 18];
                mem_0 [3] <= lane_0_rx_enc[33 : 26];
                mem_0 [4] <= lane_0_rx_enc[41 : 34];
                mem_0 [5] <= lane_0_rx_enc[49 : 42];
                mem_0 [6] <= lane_0_rx_enc[57 : 50];
                mem_0 [7] <= lane_0_rx_enc[65 : 58];
                mem_0 [16] <= lane_0_rx_enc[1 : 0];
                
                
                mem_1 [0] <= lane_0_rx_enc[9 : 2];
                mem_1 [1] <= lane_0_rx_enc[17 : 10];
                mem_1 [2] <= lane_0_rx_enc[25 : 18];
                mem_1 [3] <= lane_0_rx_enc[33 : 26];
                mem_1 [4] <= lane_0_rx_enc[41 : 34];
                mem_1 [5] <= lane_0_rx_enc[49 : 42];
                mem_1 [6] <= lane_0_rx_enc[57 : 50];
                mem_1 [7] <= lane_0_rx_enc[65 : 58];
                mem_1 [16] <= lane_1_rx_enc[1 : 0];

end 	
		   if (mem_0[16][1:0]== 2'b01) begin
                        // Ordered sets
                        data_os <= 0;
		   end else if (mem_0[16][1:0] == 2'b10) begin
                        // Transport layer data
                        data_os <= 1;
                end
                
                end
                endcase
            end
            end
    
 
// Update mem_index and d_sel based on conditions
always @(posedge enc_clk or negedge rst) begin
    if (~rst) begin
        mem_index <= max_byte_num;
    end else if (~enable_dec )   begin  
       mem_index <= max_byte_num;
   end else if (mem_index != max_byte_num) begin
			mem_index <= mem_index + 1;
		end else begin
			mem_index <= 0;
		end
	end

endmodule
`resetall	
