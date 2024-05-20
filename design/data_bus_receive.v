//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Block: data bus reciever
//Author: Seif Hamdy Fadda
//
//Description: the data bus reciever is used in detecting the different ordered sets of gen3 and gen4 and sending the control fsm 
// a signal indicating the type of the ordered set, it also forowards the transport layer data to the transport layer.
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module data_bus_receive #(parameter SEED = 11'b00000000001)(

    input            rst, fsm_clk, data_os,
    input      [7:0] lane_0_rx,
    input      [7:0] lane_1_rx,
	input      [3:0] d_sel,
	input            lane_rx_on,
	output reg [7:0] transport_layer_data_out,
	output reg [3:0] os_in_l0,
	output reg [3:0] os_in_l1
	
);  
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    reg        lane_0_rx_ser;
    reg        lane_1_rx_ser;
    reg [10:0] temp_prbs_slos1,temp_prbs_slos1_l1,temp_prbs_slos2,temp_prbs_slos2_l1; 
	reg [10:0] temp_prbs_ts1;      //prbs11 temps                           
	reg [10:0] temp_prbs_ts1_l1;   //prbs11 temps                           
	reg [63:0] temp_pipo_64;
	reg [63:0] temp_pipo_64_lane1;
    reg [31:0] temp_pipo_32;	
    reg [31:0] temp_pipo_32_l1;	
    reg [7:0]  temp_piso;   // parallel in series out 
    reg [7:0]  temp_piso_lane1;   // parallel in series out 
    reg        piso_busy;	
	reg [11:0] count_prbs_slos1,count_prbs_slos1_l1,count_prbs_slos2,count_prbs_slos2_l1; //counters for prbs
	reg [11:0] count_prbs_ts1;    // prbs11 counters
	reg [11:0] count_prbs_ts1_l1; // prbs11 counters
	reg [3:0]  count_piso;
	reg [63:0] ts1_lane0 = 64'h01000000040098F2;  //00000001 00000000 00000000 00000000 00000100 00000000 10011000 11110010   
	reg [63:0] ts2_lane0 = 64'h01000000040064F2;  //00000001 00000000 00000000 00000000 00000100 00000000 01100100 11110010
	reg [63:0] ts1_lane1 = 64'h01010000040098F2;  //00000001 00000001 00000000 00000000 00000100 00000000 10011000 11110010   
	reg [63:0] ts2_lane1 = 64'h01010000040064F2;  //00000001 00000001 00000000 00000000 00000100 00000000 01100100 11110010 
	reg [27:0] ts1_head = 28'h7E02D0F;
    reg [31:0] ts2_head = 32'h7E04B0F0;
    reg [31:0] ts3_head = 32'h7E0690F0;
    reg [31:0] ts4_head = 32'h7E0F0F00;
	reg        detect_en;
	reg        start_detect;
	reg        start_detect_lane1;
	parameter  SEED_GEN4 = 11'b11111111111;
	parameter  SEED_GEN4_LANE1 = 11'b11101110000;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
    always @ (posedge fsm_clk or negedge rst) begin     // reseting values to default values
        if (!rst) begin
            temp_prbs_slos1 <= SEED; temp_prbs_slos1_l1 <= SEED; temp_prbs_slos2 <= SEED; temp_prbs_slos2_l1 <= SEED; 
			temp_prbs_ts1 <= SEED_GEN4;
			temp_prbs_ts1_l1 <= SEED_GEN4_LANE1;
		    temp_pipo_64 <= 64'b0;
		    temp_pipo_64_lane1 <= 64'b0;
		    temp_pipo_32 <= 32'b0;
		    temp_pipo_32_l1 <= 32'b0;
			temp_piso <= 8'b00000000;
			temp_piso_lane1 <= 8'b00000000;
			count_prbs_slos1 <= 'b0; count_prbs_slos1_l1 <= 'b0; count_prbs_slos2 <= 'b0; count_prbs_slos2_l1 <= 'b0; 
			count_prbs_ts1 <= 'b0;
			count_prbs_ts1_l1 <= 'b0;
			count_piso <= 'b0;
			os_in_l0 <= 4'h9;
			os_in_l1 <= 4'h9;
			lane_0_rx_ser <= 1'b0;
			lane_1_rx_ser <= 1'b0;
			piso_busy <= 1'b0;
			transport_layer_data_out <= 8'b0;
			detect_en <= 1'b0;
			start_detect <= 1'b0;
			start_detect_lane1 <= 1'b0;
        end
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        else if ( data_os == 1'b1 & d_sel == 4'h8 & lane_rx_on == 1'b1 ) begin // transport layer data forowarding
		    transport_layer_data_out <= lane_0_rx;
			os_in_l0 <= 4'h8;
		end	
		    
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////		
	    else begin //ordered sets detecting
		    if (lane_rx_on == 1'b1) begin
		        lane_0_rx_ser <= temp_piso[7];                          //serializer
		        lane_1_rx_ser <= temp_piso_lane1[7];                          //serializer
                temp_piso <= (piso_busy)? {temp_piso[6:0],1'b0} : lane_0_rx;
                temp_piso_lane1 <= (piso_busy)? {temp_piso_lane1[6:0],1'b0} : lane_1_rx;
                piso_busy = (!(count_piso == 7));
			    count_piso <= (piso_busy)? count_piso+1 : 1'b0;
			end	
			////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			if((lane_0_rx == 8'h7E | lane_0_rx == 8'h01 | lane_0_rx == 8'h40 | lane_0_rx == 8'hBF) &  (count_piso == 1)) begin
			    start_detect <= 1'b1;
			end	
			if((lane_1_rx == 8'h7E | lane_1_rx == 8'h01 | lane_1_rx == 8'h40 | lane_1_rx == 8'hBF) &  (count_piso == 1)) begin
			    start_detect_lane1 <= 1'b1;
			end	
			if (lane_rx_on == 1'b1 & count_piso == 1) begin
			   detect_en <= 1'b1;
			end   
			else begin
			    if(lane_rx_on == 1'b0 & count_piso == 2) begin
			        detect_en <= 1'b0;
				end	
			end	
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
            if (detect_en == 1'b1) begin

		        if (d_sel == 4'h2) begin
				    if(start_detect == 1) begin
			            temp_pipo_64 <= {temp_pipo_64[62:0],lane_0_rx_ser};            //deserializer to detect gen3 ts1 			
                        if (temp_pipo_64 == ts1_lane0 ) begin
				            os_in_l0 <= 4'h2;
						    if (lane_0_rx != 8'h01) begin
						        start_detect <= 1'b0;
						    end
		                end		
		                else begin 
                            os_in_l0  <= 4'h9;					
		                end
		            end
					else begin
					    os_in_l0  <= 4'h9;
					end	
				    if(start_detect_lane1 == 1) begin
			            temp_pipo_64_lane1 <= {temp_pipo_64_lane1[62:0],lane_1_rx_ser};            //deserializer to detect gen3 ts1 lane1 			
                        if (temp_pipo_64_lane1 == ts1_lane1 ) begin
				            os_in_l1 <= 4'h2;
						    if (lane_1_rx != 8'h01) begin
						        start_detect_lane1 <= 1'b0;
						    end
		                end		
		                else begin 
                            os_in_l1  <= 4'h9;					
		                end
		            end
                    else begin
					    os_in_l1  <= 4'h9;
					end	
				end
//////////////////////////////////////////////////////////////////////////////////////////
                else if (d_sel == 4'h3) begin
				    if(start_detect == 1) begin
			            temp_pipo_64 <= {temp_pipo_64[62:0],lane_0_rx_ser};            //deserializer to detect gen3 ts2 			
                        if (temp_pipo_64 == ts2_lane0 ) begin
				            os_in_l0 <= 4'h3;
						    if (lane_0_rx != 8'h01) begin
						        start_detect <= 1'b0;
						    end
		                end		
		                else begin 
                            os_in_l0  <= 4'h9;					
		                end
		            end
					else begin
					    os_in_l0  <= 4'h9;
					end	
				    if(start_detect_lane1 == 1) begin
			            temp_pipo_64_lane1 <= {temp_pipo_64_lane1[62:0],lane_1_rx_ser};            //deserializer to detect gen3 ts2 lane1 			
                        if (temp_pipo_64_lane1 == ts2_lane1 ) begin
				            os_in_l1 <= 4'h3;
						    if (lane_1_rx != 8'h01) begin
						        start_detect_lane1 <= 1'b0;
						    end
		                end		
		                else begin 
                            os_in_l1  <= 4'h9;					
		                end
		            end
                    else begin
					    os_in_l1  <= 4'h9;
					end	
				end	
//////////////////////////////////////////////////////////////////////////////////////////
		        else if (d_sel == 4'h0) begin
                    if (start_detect == 1'b1) begin				
                        if (count_prbs_slos1 != 2048 ) begin                                               // detecting slos1
			                if (count_prbs_slos1 == 1'b0) begin
				                if(lane_0_rx_ser == 0) begin
						            count_prbs_slos1 <= count_prbs_slos1 +1; 
						            os_in_l0 <= 4'h9;	
					            end
					            else begin
						            count_prbs_slos1 <= 'b0;
						            os_in_l0 <= 4'h9;
					            end
				            end	
			                else if(lane_0_rx_ser == temp_prbs_slos1[0])begin
					            temp_prbs_slos1 <= {temp_prbs_slos1[9:0],temp_prbs_slos1[10]^temp_prbs_slos1[8]};
				                count_prbs_slos1 <= count_prbs_slos1 +1;
					            if (count_prbs_slos1 == 2047) begin
				                    os_in_l0 <=4'h0;
								    if (lane_0_rx != 8'h40) begin 	
								        start_detect <= 1'b0;
									end
					                count_prbs_slos1 <= 'b0;
									temp_prbs_slos1 <= SEED;
				                end
                                else begin
						            os_in_l0 <= 4'h9;
                                end	
				            end		
				            else begin
					            count_prbs_slos1 <= 'b0;
					            temp_prbs_slos1 <= SEED;
				                os_in_l0 <= 4'h9;
							    if (lane_0_rx != 8'h40) begin 	
								        start_detect <= 1'b0;
								end
 			                end
			            end
		            end
                    else begin
					    count_prbs_slos1 <= 'b0;
					    temp_prbs_slos1 <= SEED;
                        os_in_l0 <= 4'h9;
					end	
					if (start_detect_lane1 == 1'b1) begin				
                        if (count_prbs_slos1_l1 != 2048 ) begin                                               // detecting slos1
			                if (count_prbs_slos1_l1 == 1'b0) begin
				                if(lane_1_rx_ser == 0) begin
						            count_prbs_slos1_l1 <= count_prbs_slos1_l1 +1; 
						            os_in_l1 <= 4'h9;	
					            end
					            else begin
						            count_prbs_slos1_l1 <= 'b0;
						            os_in_l1 <= 4'h9;
					            end
				            end	
			                else if(lane_1_rx_ser == temp_prbs_slos1_l1[0])begin
					            temp_prbs_slos1_l1 <= {temp_prbs_slos1_l1[9:0],temp_prbs_slos1_l1[10]^temp_prbs_slos1_l1[8]};
				                count_prbs_slos1_l1 <= count_prbs_slos1_l1 +1;
					            if (count_prbs_slos1_l1 == 2047) begin
				                    os_in_l1 <=4'h0;
									if (lane_1_rx != 8'h40) begin
								        start_detect_lane1 <= 1'b0;
									end
					                count_prbs_slos1_l1 <= 'b0;
									temp_prbs_slos1_l1 <= SEED;
				                end
                                else begin
						            os_in_l1 <= 4'h9;
                                end	
				            end		
				            else begin
					            count_prbs_slos1_l1 <= 'b0;
					            temp_prbs_slos1_l1 <= SEED;
				                os_in_l1 <= 4'h9;
							    if (lane_1_rx != 8'h40) begin
								    start_detect_lane1 <= 1'b0;
								end
 			                end
			            end
		            end
                    else begin
					    count_prbs_slos1_l1 <= 'b0;
					    temp_prbs_slos1_l1 <= SEED;
                        os_in_l1 <= 4'h9;
					end
				end	
///////////////////////////////////////////////////////////////////////////////////////////////////////
		        else if (d_sel == 4'h1) begin
                    if (start_detect == 1'b1) begin				
                        if (count_prbs_slos2 != 2048 ) begin                                               // detecting slos1
			                if (count_prbs_slos2 == 1'b0) begin
				                if(lane_0_rx_ser == 1) begin
						            count_prbs_slos2 <= count_prbs_slos2 +1; 
						            os_in_l0 <= 4'h9;	
					            end
					            else begin
						            count_prbs_slos2 <= 'b0;
						            os_in_l0 <= 4'h9;
					            end
				            end	
			                else if(lane_0_rx_ser == ~temp_prbs_slos2[0])begin
					            temp_prbs_slos2 <= {temp_prbs_slos2[9:0],temp_prbs_slos2[10]^temp_prbs_slos2[8]};
				                count_prbs_slos2 <= count_prbs_slos2 +1;
					            if (count_prbs_slos2 == 2047) begin
				                    os_in_l0 <=4'h1;
								    if (lane_0_rx != 8'hBF) begin
								        start_detect <= 1'b0;
									end
					                count_prbs_slos2 <= 'b0;
									temp_prbs_slos2 <= SEED;
				                end
                                else begin
						            os_in_l0 <= 4'h9;
                                end	
				            end		
				            else begin
					            count_prbs_slos2 <= 'b0;
					            temp_prbs_slos2 <= SEED;
				                os_in_l0 <= 4'h9;
							    if (lane_0_rx != 8'hBF) begin
								    start_detect <= 1'b0;
							    end
 			                end
			            end
		            end
                    else begin
					    count_prbs_slos2 <= 'b0;
					    temp_prbs_slos2 <= SEED;
                        os_in_l0 <= 4'h9;
					end	
					if (start_detect_lane1 == 1'b1) begin				
                        if (count_prbs_slos2_l1 != 2048 ) begin                                               // detecting slos1 lane1
			                if (count_prbs_slos2_l1 == 1'b0) begin
				                if(lane_1_rx_ser == 1) begin
						            count_prbs_slos2_l1 <= count_prbs_slos2_l1 +1; 
						            os_in_l1 <= 4'h9;	
					            end
					            else begin
						            count_prbs_slos2_l1 <= 'b0;
						            os_in_l1 <= 4'h9;
					            end
				            end	
			                else if(lane_1_rx_ser == ~temp_prbs_slos2_l1[0])begin
					            temp_prbs_slos2_l1 <= {temp_prbs_slos2_l1[9:0],temp_prbs_slos2_l1[10]^temp_prbs_slos2_l1[8]};
				                count_prbs_slos2_l1 <= count_prbs_slos2_l1 +1;
					            if (count_prbs_slos2_l1 == 2047) begin
				                    os_in_l1 <=4'h1;
								    if (lane_1_rx != 8'hBF) begin
								        start_detect_lane1 <= 1'b0;
									end
					                count_prbs_slos2_l1 <= 'b0;
									temp_prbs_slos2 <= SEED;
				                end
                                else begin
						            os_in_l1 <= 4'h9;
                                end	
				            end		
				            else begin
					            count_prbs_slos2_l1 <= 'b0;
					            temp_prbs_slos2_l1 <= SEED;
				                os_in_l1 <= 4'h9;
							    if (lane_1_rx != 8'hBF) begin
								    start_detect_lane1 <= 1'b0;
								end
 			                end
			            end
		            end
                    else begin
					    count_prbs_slos2_l1 <= 'b0;
					    temp_prbs_slos2_l1 <= SEED;
                        os_in_l1 <= 4'h9;
					end
				end
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                else if (d_sel == 4'h4) begin
				    if (start_detect == 1'b1) begin
                        if (count_prbs_ts1 != 448) begin //detect ts1
			                if (count_prbs_ts1 < 28) begin
				                if(lane_0_rx_ser == ts1_head[27-count_prbs_ts1]) begin
					                temp_prbs_ts1 <= {temp_prbs_ts1[9:0],temp_prbs_ts1[10]^temp_prbs_ts1[8]};
						            count_prbs_ts1 <= count_prbs_ts1 +1;
				                    os_in_l0 <= 4'h9;
					            end
					            else begin
						            temp_prbs_ts1 <= SEED_GEN4;
				                    os_in_l0 <= 4'h9;
									count_prbs_ts1 <= 'b0;
					                if (lane_0_rx != 8'h7E) begin
								        start_detect <= 1'b0;
								    end
					            end
				            end	
			                else if(lane_0_rx_ser == temp_prbs_ts1[10])begin
					            temp_prbs_ts1 <= {temp_prbs_ts1[9:0],temp_prbs_ts1[10]^temp_prbs_ts1[8]};
				                count_prbs_ts1 <= count_prbs_ts1 +1;
                                if (count_prbs_ts1 == 447) begin
				                    os_in_l0 <=4'h4;
								    if (lane_0_rx != 8'h7E) begin
								        start_detect <= 1'b0;
								    end
					                count_prbs_ts1 <= 'b0;
								    temp_prbs_ts1 <= SEED_GEN4;
				                end					
				            end		
				            else begin
					            count_prbs_ts1 <= 'b0;
					            temp_prbs_ts1 <= SEED_GEN4;
				                os_in_l0 <= 4'h9;
							    if (lane_0_rx != 8'h7E) begin
								        start_detect <= 1'b0;
								end
 			                end
			            end
		            end
					else begin
					    count_prbs_ts1 <= 'b0;
						temp_prbs_ts1 <= SEED_GEN4;
				        os_in_l0 <= 4'h9;
					end     
                    if (start_detect_lane1 == 1'b1) begin
                        if (count_prbs_ts1_l1 != 448) begin //detect ts1 lane1
			                if (count_prbs_ts1_l1 < 28) begin
				                if(lane_1_rx_ser == ts1_head[27-count_prbs_ts1_l1]) begin
					                temp_prbs_ts1_l1 <= {temp_prbs_ts1_l1[9:0],temp_prbs_ts1_l1[10]^temp_prbs_ts1_l1[8]};
						            count_prbs_ts1_l1 <= count_prbs_ts1_l1 +1;
				                    os_in_l1 <= 4'h9;
					            end
					            else begin
						            count_prbs_ts1_l1 <= 'b0;
						            temp_prbs_ts1_l1 <= SEED_GEN4_LANE1;
				                    os_in_l1 <= 4'h9;
					                if (lane_1_rx != 8'h7E) begin
								        start_detect_lane1 <= 1'b0;
								    end
					            end
				            end	
			                else if(lane_1_rx_ser == temp_prbs_ts1_l1[10])begin
					            temp_prbs_ts1_l1 <= {temp_prbs_ts1_l1[9:0],temp_prbs_ts1_l1[10]^temp_prbs_ts1_l1[8]};
				                count_prbs_ts1_l1 <= count_prbs_ts1_l1 +1;
                                if (count_prbs_ts1_l1 == 447) begin
				                    os_in_l1 <=4'h4;
								    if (lane_1_rx != 8'h7E) begin
								        start_detect_lane1 <= 1'b0;
								    end
					                count_prbs_ts1_l1 <= 'b0;
								    temp_prbs_ts1_l1 <= SEED_GEN4_LANE1;
				                end					
				            end		
				            else begin
					            count_prbs_ts1_l1 <= 'b0;
					            temp_prbs_ts1_l1 <= SEED_GEN4_LANE1;
				                os_in_l1 <= 4'h9;
							    if (lane_1_rx != 8'h7E) begin
								    start_detect_lane1 <= 1'b0;
								end
 			                end
			            end
					end	
					else begin
					    count_prbs_ts1_l1 <= 'b0;
						temp_prbs_ts1_l1 <= SEED_GEN4_LANE1;
				        os_in_l1 <= 4'h9;
					end
		        end					
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                else if (d_sel == 4'h5) begin
                    if (start_detect == 1'b1) begin
                        temp_pipo_32 <= {temp_pipo_32[30:0],lane_0_rx_ser};            //deserializer to detect gen4 ts2			
				        if (temp_pipo_32 == ts2_head) begin
                            os_in_l0  <= 4'h5;
						    if(lane_0_rx != 8'h7E) begin 
						        start_detect <= 1'b0;
						    end
				        end				
				        else begin 
                            os_in_l0  <= 4'h9;					
				        end    
	                end
					else begin
					    os_in_l0 <= 4'h9;
					end
                    if (start_detect_lane1 == 1'b1) begin
                        temp_pipo_32_l1 <= {temp_pipo_32_l1[30:0],lane_1_rx_ser};            //deserializer to detect gen4 ts2 lane1 			
				        if (temp_pipo_32_l1 == ts2_head) begin
                            os_in_l1  <= 4'h5;
						    if(lane_1_rx != 8'h7E) begin 
						        start_detect_lane1 <= 1'b0;
						    end
				        end				
				        else begin 
                            os_in_l1  <= 4'h9;					
				        end    
	                end
					else begin
					    os_in_l1 <= 4'h9;
					end
				end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////				
		        else if (d_sel == 4'h6) begin
                    if (start_detect == 1'b1) begin
                        temp_pipo_32 <= {temp_pipo_32[30:0],lane_0_rx_ser};            //deserializer to detect gen4 ts3 			
				        if (temp_pipo_32 == ts3_head) begin
                            os_in_l0  <= 4'h6;
						    if(lane_0_rx != 8'h7E) begin 
						        start_detect <= 1'b0;
						    end
				        end				
				        else begin 
                            os_in_l0  <= 4'h9;					
				        end    
	                end
					else begin
					    os_in_l0 <= 4'h9;
					end
                    if (start_detect_lane1 == 1'b1) begin
                        temp_pipo_32_l1 <= {temp_pipo_32_l1[30:0],lane_1_rx_ser};            //deserializer to detect gen4 ts3 lane1			
				        if (temp_pipo_32_l1 == ts3_head) begin
                            os_in_l1  <= 4'h6;
						    if(lane_1_rx != 8'h7E) begin 
						        start_detect_lane1 <= 1'b0;
						    end
				        end				
				        else begin 
                            os_in_l1  <= 4'h9;					
				        end    
	                end
					else begin
					    os_in_l1 <= 4'h9;
					end
				end
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////				
		        else if (d_sel == 4'h7) begin
                    if (start_detect == 1'b1) begin
                        temp_pipo_32 <= {temp_pipo_32[30:0],lane_0_rx_ser};            //deserializer to detect gen4 ts4 			
				        if (temp_pipo_32 == ts4_head) begin
                            os_in_l0  <= 4'h7;
						    if(lane_0_rx != 8'h7E) begin 
						        start_detect <= 1'b0;
						    end
				        end				
				        else begin 
                            os_in_l0  <= 4'h9;					
				        end    
	                end
					else begin
					    os_in_l0 <= 4'h9;
					end
                    if (start_detect_lane1 == 1'b1) begin
                        temp_pipo_32_l1 <= {temp_pipo_32_l1[30:0],lane_1_rx_ser};            //deserializer to detect gen4 ts4 lane1 			
				        if (temp_pipo_32_l1 == ts4_head) begin
                            os_in_l1  <= 4'h7;
						    if(lane_1_rx != 8'h7E) begin 
						        start_detect_lane1 <= 1'b0;
						    end
				        end				
				        else begin 
                            os_in_l1  <= 4'h9;					
				        end    
	                end
					else begin
					    os_in_l1 <= 4'h9;
					end
				end
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////				
		        else begin
		            temp_prbs_slos1 <= SEED; 
		            temp_prbs_slos1_l1 <= SEED; 
					temp_prbs_slos2 <= SEED; 
					temp_prbs_slos2_l1 <= SEED; 
			        temp_prbs_ts1 <= SEED_GEN4;
			        temp_prbs_ts1_l1 <= SEED_GEN4_LANE1;
		            temp_pipo_64 <= 64'b0;
		            temp_pipo_64_lane1 <= 64'b0;
		            temp_pipo_32 <= 32'b0;
		            temp_pipo_32_l1 <= 32'b0;
			        count_prbs_slos1 <= 'b0; 
			        count_prbs_slos1_l1 <= 'b0; 
					count_prbs_slos2 <= 'b0; 
					count_prbs_slos2_l1 <= 'b0; 
					count_prbs_ts1 <= 'b0;
					count_prbs_ts1_l1 <= 'b0;
			        os_in_l0 <= 4'h9;
			        os_in_l1 <= 4'h9;
					start_detect <= 1'b0;
					start_detect_lane1 <= 1'b0;
		        end	
		
			
            end
            else begin
                temp_prbs_slos1 <= SEED; 
                temp_prbs_slos1_l1 <= SEED; 
				temp_prbs_slos2 <= SEED; 
				temp_prbs_slos2_l1 <= SEED; 
			    temp_prbs_ts1 <= SEED_GEN4;
			    temp_prbs_ts1_l1 <= SEED_GEN4_LANE1;
		        temp_pipo_64 <= 64'b0;
		        temp_pipo_64_lane1 <= 64'b0;
		        temp_pipo_32 <= 32'b0;
		        temp_pipo_32_l1 <= 32'b0;
			    count_prbs_slos1 <= 'b0; 
			    count_prbs_slos1_l1 <= 'b0; 
				count_prbs_slos2 <= 'b0; 
				count_prbs_slos2_l1 <= 'b0; 
				count_prbs_ts1 <= 'b0;
				count_prbs_ts1_l1 <= 'b0;
				os_in_l0 <= 4'h9;
				os_in_l1 <= 4'h9;
	        end			
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////				 
        end
	end
endmodule
`default_nettype none
`resetall	
