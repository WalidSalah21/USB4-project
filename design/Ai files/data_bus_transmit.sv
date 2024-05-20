`default_nettype none

module data_bus_transmit (
    input wire clk,                             // Clock input
    input wire  rst,                             // Reset input
    input wire  [3:0] d_sel,                     // Data selection input 
    input wire  [7:0] transport_layer_data_in,   // Transport layer data input 
    output reg [7:0] lane_0_tx,            // Lane 0 transmission output 
    output reg [7:0] lane_1_tx,            // Lane 1 transmission output 
    output reg tx_lanes_on,                // Transmission lanes enable output 
    output reg os_sent                     // Ordered set sent output 
);

    // Internal variables
    reg [63:0] ordered_set0, ordered_set1;    
    reg [2:0]  counter, byte_counter;    
    reg [3:0]  sym_counter;    
    reg [4:0]  ts1_counter;    
    reg [7:0]  deser_0_out, deser_1_out; 
    reg        deser_0_in, deser_1_in;  
    reg        enable_deser;    
    reg        slos1_out, slos2_out, g4_prb_0_out, g4_prb_1_out;    
    reg        g4_ts1_header;    
    reg        g4_ts1_header_sent;    
    reg        slos1_sent, slos2_sent, prb_0_sent, prb_1_sent;    
	reg		   delay;
    
    localparam GEN4_TS1    = 28'b011111100000_0010_1101_00001111,
               GEN4_TS2    = 64'b011111100000_0100_1011_00001111_0000_00000000000000000000000000000000,
               GEN4_TS3    = 64'b011111100000_0110_1001_00001111_0000_00000000000000000000000000000000,
               GEN4_TS4    = 64'b011111100000_11110000_0000_1111_0000_00000000000000000000000000000000, 
               GEN3_TS1_L0 = 64'h01000000040098F2,
               GEN3_TS1_L1 = 64'h01010000040098F2,
               GEN3_TS2_L0 = 64'b00000_001_00000000_0000000000000000_000_001_0000000000_011001_0011110010,
               GEN3_TS2_L1 = 64'b00000_001_00000001_0000000000000000_000_001_0000000000_011001_0011110010;

    always @(*) begin
        case (d_sel)
            'h2: begin
                ordered_set0 <= GEN3_TS1_L0;
                ordered_set1 <= GEN3_TS1_L1;
            end
            'h3: begin
                ordered_set0 <= GEN3_TS2_L0;
                ordered_set1 <= GEN3_TS2_L1;
            end
            'h5: begin
                ordered_set0 <= GEN4_TS2;
                ordered_set1 <= GEN4_TS2;
            end
            'h6: begin
                ordered_set0 <= GEN4_TS3;
                ordered_set1 <= GEN4_TS3;
            end
            'h7: begin
                ordered_set0 <= {GEN4_TS4[63:44], sym_counter, ~sym_counter, GEN4_TS4[35:0]};
                ordered_set1 <= {GEN4_TS4[63:44], sym_counter, ~sym_counter, GEN4_TS4[35:0]};
            end
            default: begin
                ordered_set0 <= 0;
                ordered_set1 <= 0;
            end
        endcase
    end
	
	always @(posedge clk or negedge rst) begin
        if (!rst) begin
            // Reset logic
            counter <= 0;
            byte_counter <= 0;
            sym_counter <= 0;
            os_sent <= 0;
            tx_lanes_on <= 0;
			enable_deser <= 0;
			delay <= 0;
        end else if (d_sel == 8) begin
            lane_0_tx <= transport_layer_data_in;
            lane_1_tx <= 0;
            counter <= 0;
            byte_counter <= 0;
            sym_counter <= 0;
			enable_deser <= 0;
        end else if (d_sel == 9) begin
            lane_0_tx <= 0;
            lane_1_tx <= 0;
            counter <= 0;
            byte_counter <= 0;
            sym_counter <= 0;
			enable_deser <= 0;
        end else if(d_sel==2 || d_sel==3 || d_sel==5 || d_sel==6 || d_sel==7) begin
            counter <= (counter == 7)? 0 : counter + 1;
            byte_counter <= (counter == 7) ? byte_counter + 1 : byte_counter;
			if ((byte_counter == 3 || byte_counter == 7) && counter == 7) begin
			    if (d_sel == 'h7 && sym_counter != 'hf) begin
				    sym_counter <= sym_counter + 1;
				end
            end
            enable_deser <= 0;
			os_sent <= 0;
            case (byte_counter)
                'h0: begin
					if (d_sel == 5 || d_sel == 6 || d_sel == 7 ||counter == 7 ) begin
                    lane_0_tx <= ordered_set0[63:56];
                    lane_1_tx <= ordered_set1[63:56];
					end
					else begin
					 lane_0_tx <= lane_0_tx;
                    lane_1_tx <= lane_1_tx;
					end
                end
                'h1: begin
					if (d_sel == 5 || d_sel == 6 || d_sel == 7 || counter == 7 ) begin
                    lane_0_tx <= ordered_set0[55:48];
                    lane_1_tx <= ordered_set1[55:48];
					delay <= 1;
					end
                end
                'h2: begin
					if (d_sel == 5 || d_sel == 6 || d_sel == 7 || counter == 7 ) begin
                    lane_0_tx <= ordered_set0[47:40];
                    lane_1_tx <= ordered_set1[47:40];
					end
                end
                'h3: begin
					if (d_sel == 5 || d_sel == 6 || d_sel == 7 || counter == 7 ) begin
                    lane_0_tx <= ordered_set0[39:32];
                    lane_1_tx <= ordered_set1[39:32];
					end
                    if(d_sel==5 || d_sel==6 || d_sel==7) begin
                        byte_counter <= (counter == 7)? 0 : 3;
                        os_sent <= (counter == 7)? 1 : 0;
                    end
                end
                'h4: begin
					if (d_sel == 5 || d_sel == 6 || d_sel == 7 || counter == 7 ) begin
                    lane_0_tx <= ordered_set0[31:24];
                    lane_1_tx <= ordered_set1[31:24];
					end
                end
                'h5: begin
					if (d_sel == 5 || d_sel == 6 || d_sel == 7 || counter == 7 ) begin
                    lane_0_tx <= ordered_set0[23:16];
                    lane_1_tx <= ordered_set1[23:16];
					end
                end
                'h6: begin
					if (d_sel == 5 || d_sel == 6 || d_sel == 7 || counter == 7 ) begin
                    lane_0_tx <= ordered_set0[15:8];
                    lane_1_tx <= ordered_set1[15:8];
					end
                end
                'h7: begin
					if (d_sel == 5 || d_sel == 6 || d_sel == 7 || counter == 7 ) begin
                    lane_0_tx <= ordered_set0[7:0];
                    lane_1_tx <= ordered_set1[7:0];
					end
                    os_sent <= (counter == 7)? 1 : 0;
                end
            endcase
        end else begin
            lane_0_tx <= deser_0_out;
            lane_1_tx <= deser_1_out;
            os_sent <= slos1_sent || slos2_sent || prb_0_sent;
            tx_lanes_on <= (sym_counter == 9)? 1 : tx_lanes_on;
            enable_deser <= 1;
            counter <= 0;
            byte_counter <= 0;
			if (sym_counter == 9) begin
			  sym_counter <= 0;
			end else if (tx_lanes_on) begin
			  sym_counter <= 0;
			end else begin
			  sym_counter <= sym_counter + 1;
			end
        end
    end
    
    always @ (posedge clk or negedge rst) begin
        if (!rst) begin
            ts1_counter <= 28;
            g4_ts1_header_sent <= 0;
            g4_ts1_header <= 0;
        end 
        else if(d_sel == 'h4) begin
            if(!g4_ts1_header_sent) begin
                g4_ts1_header <= GEN4_TS1[ts1_counter - 1];
                if(ts1_counter == 0) begin
                    ts1_counter <= 27;
                    g4_ts1_header_sent <= 1;
                end else begin
                    ts1_counter <= ts1_counter - 1;
                end
            end else begin
                if(prb_0_sent) begin
                    g4_ts1_header_sent <= 0;
                    g4_ts1_header <= 0;
                end
            end
        end else begin
            ts1_counter <= 28;
            g4_ts1_header_sent <= 0;
            g4_ts1_header <= 0;
        end
    end
	
    always @(*) begin
        if (d_sel == 'h0) begin
            deser_0_in = slos1_out;
            deser_1_in = slos1_out;
		end	
        if (d_sel == 'h1) begin
            deser_0_in = slos2_out;
            deser_1_in = slos2_out;
		end	
        if (d_sel == 'h4) begin
            deser_0_in = (g4_ts1_header_sent) ? g4_prb_0_out : g4_ts1_header;
            deser_1_in = (g4_ts1_header_sent) ? g4_prb_1_out : g4_ts1_header;
		end	
    end

    bus_deserializer #(.DATA_WIDTH(8)) deser_l0
	(
        .clk(clk),                  
        .rst(rst),              
        .enable(enable_deser),               
        .serial_in(deser_0_in),            
        .parallel_data(deser_0_out)  
    );
	
    bus_deserializer #(.DATA_WIDTH(8)) deser_l1
	(
        .clk(clk),                  
        .rst(rst),              
        .enable(enable_deser),               
        .serial_in(deser_1_in),            
        .parallel_data(deser_1_out)  
    );

    slos_send #(.SEED('h400)) slos1_prb
	(
        .clk(clk),
        .reset(rst),
        .enable(d_sel == 'h0),
        .slos1_slos2(1'b0),
        .data_out(slos1_out),
        .slos_sent(slos1_sent)
    );

    slos_send #(.SEED('h400)) slos2_prb
    (
        .clk(clk),
        .reset(rst),
        .enable(d_sel == 'h1),
        .slos1_slos2(1'b1),
        .data_out(slos2_out),
        .slos_sent(slos2_sent)
    );
    
    prbs11_g4_send #(.lane0_lane1(1)) g4_prb_l0
    (
        .clk(clk),
        .reset(rst),
        .enable(d_sel == 'h4),
        .data_out(g4_prb_0_out),
        .os_sent(prb_0_sent)
    );
	
    prbs11_g4_send #(.lane0_lane1(0)) g4_prb_l1
    (
        .clk(clk),
        .reset(rst),
        .enable(d_sel == 'h4),
        .data_out(g4_prb_1_out),
        .os_sent(prb_1_sent)
    );
	
endmodule

`resetall

