`default_nettype none

module data_bus_receive (
    input wire clk,                         // Clock input
    input wire  rst,                         // Reset input
    input wire  data_os,                     // Data or ordered sets
    input wire  lane_rx_on,                  // data bus receive enable input
    input wire  [3:0] d_sel,                 // Data selection input 
    input wire  [7:0] lane_0_rx,             // Lane 0 reception input 
    input wire  [7:0] lane_1_rx,             // Lane 1 reception input 
    output reg [3:0] os_in_l0,         // Ordered set in lane 0
    output reg [3:0] os_in_l1,         // Ordered set in lane 1
    output reg [7:0] transport_layer_data_out // Transport layer data output 
);

    // Internal variables
    reg [63:0] ordered_set0, ordered_set1;    
    reg [2:0]  byte_counter;   
    reg        os_in_l0_sent, os_in_l1_sent;  
    reg        enable_ser_l0, enable_ser_l1;  
    reg        ser_out_l0, ser_out_l1;	
    reg        enable_slos1_det, enable_slos2_det;    
    reg        slos1_rec_l0, slos1_rec_l1;    
    reg        slos2_rec_l0, slos2_rec_l1;    
    reg        enable_g4_prb_det_l0, enable_g4_prb_det_l1;    
    reg        g4_ts1_header_rec_l0, g4_ts1_header_rec_l1;    
    reg        prb_rec_l0, prb_rec_l1;        
    reg        flag1, flag2;        
   
    
    localparam GEN4_TS1    = 28'b011111100000_0010_1101_00001111,
               GEN4_TS2    = 32'b011111100000_0100_1011_00001111_0000,
               GEN4_TS3    = 32'b011111100000_0110_1001_00001111_0000,
               GEN4_TS4    = 32'b011111100000_11110000_1111_0000_0000,
               GEN3_TS1_L0 = 64'b00000_001_00000000_0000000000000000_000_001_0000000000_100110_0011110010,
               GEN3_TS1_L1 = 64'b00000_001_00000001_0000000000000000_000_001_0000000000_100110_0011110010,
               GEN3_TS2_L0 = 64'b00000_001_00000000_0000000000000000_000_001_0000000000_011001_0011110010,
               GEN3_TS2_L1 = 64'b00000_001_00000001_0000000000000000_000_001_0000000000_011001_0011110010;
			   
			   
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            // Reset logic
            ordered_set0 <= 0;
            ordered_set1 <= 0;
            byte_counter <= 0;
        end else begin
            if (byte_counter == 7) begin
			    ordered_set0 <= {ordered_set0[56:0], lane_0_rx};
                ordered_set1 <= {ordered_set1[56:0], lane_1_rx};
				byte_counter <= 0;
			end else begin
			    byte_counter <= byte_counter + 1;
			end
        end
    end

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
		    os_in_l0 <= 'h9;
		    os_in_l1 <= 'h9;
		    enable_ser_l0 <= 0;
		    enable_ser_l1 <= 0;
		    enable_slos1_det <= 0;
		    enable_slos2_det <= 0;
		    enable_g4_prb_det_l0 <= 0;
		    enable_g4_prb_det_l1 <= 0;
		    g4_ts1_header_rec_l0 <= 0;
		    g4_ts1_header_rec_l1 <= 0;
		    flag1 <= 0;
		    flag2 <= 0;
			transport_layer_data_out <= 0;
        end else if (!lane_rx_on) begin
		    os_in_l0 <= 'h9;
		    os_in_l1 <= 'h9;
		    enable_ser_l0 <= 0;
		    enable_ser_l1 <= 0;
		    enable_slos1_det <= 0;
		    enable_slos2_det <= 0;
		    enable_g4_prb_det_l0 <= 0;
		    enable_g4_prb_det_l1 <= 0;
		    g4_ts1_header_rec_l0 <= 0;
		    g4_ts1_header_rec_l1 <= 0;
		    flag1 <= 0;
		    flag2 <= 0;
			transport_layer_data_out <= 0;
		end else begin
			os_in_l0 <= 'h9;
			os_in_l1 <= 'h9;
			os_in_l0_sent <= 0;
			os_in_l1_sent <= 0;
		    enable_ser_l0 <= 0;
		    enable_ser_l1 <= 0;
		    enable_slos1_det <= 0;
		    enable_slos2_det <= 0;
		    enable_g4_prb_det_l0 <= 0;
		    enable_g4_prb_det_l1 <= 0;
		    g4_ts1_header_rec_l0 <= 0;
		    g4_ts1_header_rec_l1 <= 0;
		    flag1 <= 0;
		    flag2 <= 0;
			transport_layer_data_out <= 0;
			case (d_sel)
                'h0: begin
                    if (lane_0_rx == 'h40) begin
		    		    enable_ser_l0 <= 1;
		    		    enable_ser_l1 <= 1;
						enable_slos1_det <= 1;
					end else begin
		    		    enable_ser_l0 <= enable_ser_l0;
		    		    enable_ser_l1 <= enable_ser_l1;
						enable_slos1_det <= enable_slos1_det;
					end 
					os_in_l0 <= (slos1_rec_l0)? 'h0 : 'h9;
					os_in_l1 <= (slos1_rec_l1)? 'h0 : 'h9;
                end 
                'h1: begin
                    if (lane_0_rx == 'hbf) begin
		    		    enable_ser_l0 <= 1;
		    		    enable_ser_l1 <= 1;
						enable_slos2_det <= 1;
					end else begin
		    		    enable_ser_l0 <= enable_ser_l0;
		    		    enable_ser_l1 <= enable_ser_l1;
						enable_slos2_det <= enable_slos2_det;
					end 
					os_in_l0 <= (slos2_rec_l0)? 'h1 : 'h9;
					os_in_l1 <= (slos2_rec_l1)? 'h1 : 'h9;
                end
                'h2: begin
                    if (ordered_set0 == GEN3_TS1_L0) begin
		    		    os_in_l0 <= (os_in_l0_sent)? 'h9 : 'h2;
						os_in_l0_sent <= 1;
					end
                    if (ordered_set1 == GEN3_TS1_L1) begin 
		    		    os_in_l1 <= (os_in_l1_sent)? 'h9 : 'h2;
						os_in_l1_sent <= 1;
					end
                end
                'h3: begin
                    if (ordered_set0 == GEN3_TS2_L0) begin
		    		    os_in_l0 <= (os_in_l0_sent)? 'h9 : 'h3;
						os_in_l0_sent <= 1;
					end
                    if (ordered_set1 == GEN3_TS2_L1) begin
		    		    os_in_l1 <= (os_in_l1_sent)? 'h9 : 'h3;
						os_in_l1_sent <= 1;
					end
                end 
                'h4: begin
					if (ordered_set0[23:0] == GEN4_TS1[27:4]) begin
					    g4_ts1_header_rec_l0 <= 1;
					end else if (prb_rec_l0) begin
					    g4_ts1_header_rec_l0 <= 0;
					end else begin
					    g4_ts1_header_rec_l0 <= g4_ts1_header_rec_l0;
					end
					if (ordered_set1[23:0] == GEN4_TS1[27:4]) begin
					    g4_ts1_header_rec_l1 <= 1;
					end else if (prb_rec_l1) begin
					    g4_ts1_header_rec_l1 <= 0;
					end else begin
					    g4_ts1_header_rec_l1 <= g4_ts1_header_rec_l1;
					end
					if (lane_0_rx == 'h7e) begin
					    enable_g4_prb_det_l0 <= 1;
						enable_ser_l0 <= 1;
					end else begin
					    enable_g4_prb_det_l0 <= enable_g4_prb_det_l0;
						enable_ser_l0 <= enable_ser_l0;
					end
					if (lane_1_rx == 'h7e) begin
					    enable_g4_prb_det_l1 <= 1;
						enable_ser_l1 <= 1;
					end else begin
					    enable_g4_prb_det_l1 <= enable_g4_prb_det_l1;
						enable_ser_l1 <= enable_ser_l1;
					end
					os_in_l0 <= (prb_rec_l0 && g4_ts1_header_rec_l0)? 'h4 : 'h9;
					os_in_l1 <= (prb_rec_l1 && g4_ts1_header_rec_l1)? 'h4 : 'h9;
                end
                'h5: begin
                    if (ordered_set0[31:0] == GEN4_TS2) begin
		    		    os_in_l0 <= (os_in_l0_sent)? 'h9 : 'h5;
						os_in_l0_sent <= 1;
					end
                    if (ordered_set1[31:0] == GEN4_TS2) begin
		    		    os_in_l1 <= (os_in_l1_sent)? 'h9 : 'h5;
						os_in_l1_sent <= 1;
					end
                end
                'h6: begin
                    if (ordered_set0[31:0] == GEN4_TS3) begin
		    		    os_in_l0 <= (os_in_l0_sent)? 'h9 : 'h6;
						os_in_l0_sent <= 1;
					end
                    if (ordered_set1[31:0] == GEN4_TS3) begin
		    		    os_in_l1 <= (os_in_l1_sent)? 'h9 : 'h6;
						os_in_l1_sent <= 1;
					end
                end
                'h7: begin
                    if (ordered_set0[31:0] == GEN4_TS4) begin
		    		    os_in_l0 <= (os_in_l0_sent)? 'h9 : 'h7;
						os_in_l0_sent <= 1;
					end
                    if (ordered_set1[31:0] == GEN4_TS4) begin
		    		    os_in_l1 <= (os_in_l1_sent)? 'h9 : 'h7;
						os_in_l1_sent <= 1;
					end
                end
                'h8: begin
                    if (data_os) begin
		    		    transport_layer_data_out <= lane_0_rx;
					end
                end
            endcase
		end
    end


    bus_serializer #(.DATA_WIDTH(8)) ser_l0
	(
        .clk(clk),                  
        .rst(rst),              
        .enable(enable_ser_l0),     
        .parallel_data(lane_0_rx),
		.serial_out(ser_out_l0)
    );
	
    bus_serializer #(.DATA_WIDTH(8)) ser_l1
	(
        .clk(clk),                  
        .rst(rst),              
        .enable(enable_ser_l1),     
        .parallel_data(lane_1_rx),
		.serial_out(ser_out_l1)
    );

    prbs11_rec #(.SEED('h400)) slos1_prb_l0
	(
        .clk(clk),
        .reset(rst),
        .enable(enable_slos1_det),
        .slos1_slos2(1'b0),
        .data_in(ser_out_l0),
        .slos_rec(slos1_rec_l0)
    );

    prbs11_rec #(.SEED('h400)) slos1_prb_l1
	(
        .clk(clk),
        .reset(rst),
        .enable(enable_slos1_det),
        .slos1_slos2(1'b0),
        .data_in(ser_out_l1),
        .slos_rec(slos1_rec_l1)
    );

    prbs11_rec #(.SEED('h400)) slos2_prb_l0
    (
        .clk(clk),
        .reset(rst),
        .enable(enable_slos2_det),
        .slos1_slos2(1'b1),
        .data_in(ser_out_l0),
        .slos_rec(slos2_rec_l0)
    );
	
    prbs11_rec #(.SEED('h400)) slos2_prb_l1
    (
        .clk(clk),
        .reset(rst),
        .enable(enable_slos2_det),
        .slos1_slos2(1'b1),
        .data_in(ser_out_l1),
        .slos_rec(slos2_rec_l1)
    );
    
    prbs11_rec_g4 #(.lane0_lane1(1)) g4_prb_l0
    (
        .clk(clk),
        .reset(rst),
        .enable(enable_g4_prb_det_l0),
        .data_in(ser_out_l0),
        .os_rec(prb_rec_l0)
    );
	
    prbs11_rec_g4 #(.lane0_lane1(0)) g4_prb_l1
    (
        .clk(clk),
        .reset(rst),
        .enable(enable_g4_prb_det_l1),
        .data_in(ser_out_l1),
        .os_rec(prb_rec_l1)
    );
	
endmodule

`resetall
