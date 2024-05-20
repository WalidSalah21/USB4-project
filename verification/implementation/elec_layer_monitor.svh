
	class elec_layer_monitor;

		//Transaction
		elec_layer_tr elec_tr;
		elec_layer_tr elec_tr_lane0;
		elec_layer_tr elec_tr_lane1;
		
		// Interface
		virtual electrical_layer_if v_if;

		// Mailboxes
		mailbox #(elec_layer_tr) elec_mon_scr; // connects monitor to the scoreboard
		//mailbox #(elec_layer_tr) os_received_mon_gen; // connects monitor to the stimulus generator to indicated received ordered sets

		/*
		//Events
		event sbtx_high_recieved;
		event elec_AT_cmd_received; // to Trigger the appropriate AT response when AT CMD is received
		*/

		logic [65:0] expected;
		// Flags
		logic sbtx_high_flag; // to indicate that sbtx high was received
		logic sent_to_scr; // to indicate that the transaction was already sent to the scoreboard 

		//TS and payload gen2/3 Size Parameters
		int TS_SIZE;
		int PAYLOAD_SIZE;

		// Queues to save DUT signals
		bit SB_data_received [$];

		bit lane_0_gen4_received [$];
		bit lane_1_gen4_received [$];
		bit lane_0_gen23_SLOS_received [$];
		bit lane_1_gen23_SLOS_received [$];
		bit lane_0_gen23_TS_received [$];
		bit lane_1_gen23_TS_received [$];

		logic lane_0_UL_received [$];
		logic lane_1_UL_received [$];


		// ordered SETS QUEUES
		bit [1:0] PRTS7_lane0 [$];
		bit [1:0] PRTS7_lane1 [$];
		bit PRTS7_lane0_1bit [$];
		bit PRTS7_lane1_1bit [$];


		bit PRBS11_lane0 [$];
		bit PRBS11_lane1 [$]; 
	

		// variable RESPONSE DATA 
		bit [29:0] Rsp_Data;
		bit[19:0] Tmp_Data; // to help detect LT_FALL, AT_CMND, AT_RSP
		bit [79:0] tmp_AT_cmnd;

		// SYMBOL GENERATION CLASS
		TS_Symbols TS;

		// Symbols received and stored to be used in comparisons
		logic [7:0] LSE_received, CLSE_received;
		logic [7:0] ETX_received;
		logic [19:0] DLE_ETX_received;


		bit [419:0] TS234_DATA;

		// NEW Function
		function new(input virtual electrical_layer_if v_if, mailbox #(elec_layer_tr) elec_mon_scr);

			//Interface Connections
			this.v_if = v_if;

			// Mailbox connections 
			this.elec_mon_scr = elec_mon_scr; //between (monitor) and (Agent)
			//this.os_received_mon_gen = os_received_mon_gen;

			/*
			//Event Connections
			this.sbtx_high_recieved = sbtx_high_recieved;
			this.elec_AT_cmd_received = elec_AT_cmd_received;
			*/

			elec_tr = new();
			elec_tr_lane1 = new();
			elec_tr_lane0 = new();


		endfunction : new

		task run;
			
			TS = new();
			TS.calculate_TS();
			TS.SLOS_encoder();

			sent_to_scr = 1'b0;

			forever begin
				
				//elec_tr =new();
				
				//////////////////////////////////////////////////
				///////GETTING INTERFACE ITEMS TO BE TESTED///////
				//////////////////////////////////////////////////

				//@(negedge v_if.clk);
				//wait_negedge (v_if.generation_speed);
				

				fork
					begin 

						///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
						///////////////////////////////////////              SIDEBAND RECEIVER                /////////////////////////////////////////
						///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

						//wait( v_if.SB_clock == 0);
						@(negedge v_if.SB_clock);
						#1 // needed to detect changes correctly

						SB_data_received.push_back(v_if.sbtx); // sbrx for debugging
						
						// MONITOR DISPLAY FUNCTION FOR DEBUGGING
						//$display("[%0t] SB_data_received outside:[%0p]",$time(),SB_data_received);

						// Detecting Transaction types from the first 2 symbols (AT COMMAND/ AT RESPONSE / LT FALL)
						if (SB_data_received.size() == TR_HEADER_SIZE) // can remove the if condition 
							begin
								detect_transaction_type();
								//v_if.generation_speed = gen4; // ALIIIIIIIIIIIIIIIII (TO keep up with DUT (DUT to be changed))
							end
		
						// CONFIRMING THE RECEPTION OF THE FULL TRANSACTION to be sent to the SCOREBOARD
						if (SB_data_received.size() >= MIN_TR_SIZE)
							begin
								receive_transaction_data();
							end
		
					end
					
					begin 

						// LANES RECEIVER CLOCK
						#1
						wait_negedge (v_if.generation_speed);
						//#1


						//$display("[%0t] lane_0_gen4_received outside:[%0b]",$time(),v_if.lane_0_rx);

						if (v_if.phase_5_read_enable)
						begin
							//$stop;

							//wait_negedge (v_if.generation_speed);

							/*if(v_if.generation_speed == gen2)
							begin
								PAYLOAD_SIZE = PAYLOAD_GEN_2_SIZE;
							end
							else if (v_if.generation_speed == gen3)
							begin
								PAYLOAD_SIZE = PAYLOAD_GEN_3_SIZE;
							end*/

							lane_0_UL_received.push_back(v_if.lane_0_tx); //v_if.lane_0_rx for debugging
							lane_1_UL_received.push_back(v_if.lane_1_tx); //v_if.lane_1_rx for debugging

							case (v_if.generation_speed)

								gen2: begin

									fork
										begin
											if (lane_0_UL_received.size() == PAYLOAD_GEN_2_SIZE)
											begin
												
												if ( !( { >> {lane_0_UL_received [0:1]} } == 2'b01) )
												begin
													$error("[ELEC MONITOR] Wrong Sync bits received on Lane 0 in gen2 during phase 5");
													lane_0_UL_received = {};
												end
												else
												begin
													//To remove the sync bits after being checked
													repeat(2)
														void'(lane_0_UL_received.pop_front());
		
													
		
													for (int i = 0; i < 64; i = i + 8)
													begin
														elec_tr_lane0.transport_to_electrical = { << {lane_0_UL_received [i: i+7]} };
														$display("[ELEC MONITOR] Data Received on Lane 0 from UL: %h", elec_tr_lane0.transport_to_electrical);
														elec_tr_lane0.lane = lane_0;
														elec_tr_lane0.phase = 5;
														elec_tr_lane0.sbtx = v_if.sbtx;
														elec_mon_scr.put(elec_tr_lane0);

														elec_tr_lane0 = new();
														#0;
													end

													lane_0_UL_received = {};
													
												end
													
												
											end
										end

										begin
											if (lane_1_UL_received.size() == PAYLOAD_GEN_2_SIZE)
											begin
												if ( !( { >> {lane_1_UL_received [0:1]} } == 2'b01) )
												begin
													$error("[ELEC MONITOR] Wrong Sync bits received on Lane 1 in gen2 during phase 5");
													lane_1_UL_received = {};
												end
												else
												begin
													//To remove the sync bits after being checked
													repeat(2)
														void'(lane_1_UL_received.pop_front());
		
													
		
													for (int i = 0; i < 64; i = i + 8)
													begin
														elec_tr_lane1.transport_to_electrical = { << {lane_1_UL_received [i: i+7]} };
														$display("[ELEC MONITOR] Data Received on Lane 1 from UL: %h", elec_tr_lane1.transport_to_electrical);
														elec_tr_lane1.lane = lane_1;
														elec_tr_lane1.phase = 5;
														elec_tr_lane1.sbtx = v_if.sbtx;
														elec_mon_scr.put(elec_tr_lane1);

														elec_tr_lane1 = new();
														#0;
													end
													
													lane_1_UL_received = {};

												end

													
											end
										end

									join

									

								end

								gen3: begin

									fork
										begin
											if (lane_0_UL_received.size() == PAYLOAD_GEN_3_SIZE)
											begin
												
												if ( !( { >> {lane_0_UL_received [0:3]} } == 4'b0101) )
												begin
													$error("[ELEC MONITOR] Wrong Sync bits received on Lane 0 in gen3 during phase 5");
													lane_0_UL_received = {};
												end
												else
												begin
													//To remove the sync bits after being checked
													repeat(4)
														void'(lane_0_UL_received.pop_front());
		
													for (int i = 0; i < 128; i = i + 8)
													begin
														elec_tr_lane0.transport_to_electrical = { << {lane_0_UL_received [i: i+7]} };
														$display("[ELEC MONITOR] Data Received on Lane 0 from UL: %h", elec_tr_lane0.transport_to_electrical);
														//$display("[ELEC MONITOR] Data Received on Lane 0 from UL: %h at time: %0t", elec_tr_lane0.transport_to_electrical, $time);
														
														elec_tr_lane0.lane = lane_0;
														elec_tr_lane0.phase = 5;
														elec_tr_lane0.sbtx = v_if.sbtx;
														elec_mon_scr.put(elec_tr_lane0);
														
														elec_tr_lane0 = new();
														#0;
													end
		
													lane_0_UL_received = {};
		
												end
												
											end
										end

										begin
											if ( (lane_1_UL_received.size() == PAYLOAD_GEN_3_SIZE) )
											begin
												if ( !( { >> {lane_1_UL_received [0:3]} } == 4'b0101) )
												begin
													$error("[ELEC MONITOR] Wrong Sync bits received on Lane 1 in gen3 during phase 5");
													lane_1_UL_received = {};
												end
												else
												begin
													//To remove the sync bits after being checked
													repeat(4)
														void'(lane_1_UL_received.pop_front());
		
													
		
													for (int i = 0; i < 128; i = i + 8)
													begin
														elec_tr_lane1.transport_to_electrical = { << {lane_1_UL_received [i: i+7]} };
														
														$display("[ELEC MONITOR] Data Received on Lane 1 from UL: %h", elec_tr_lane1.transport_to_electrical);
														
														elec_tr_lane1.lane = lane_1;
														elec_tr_lane1.phase = 5;
														elec_tr_lane1.sbtx = v_if.sbtx;
														elec_mon_scr.put(elec_tr_lane1);
		
														elec_tr_lane1 = new();
														#0;
													end
		
													lane_1_UL_received = {};
													
												end
											end
										end
									join


									

									

								end

								gen4: begin

									if (lane_0_UL_received.size() == 8)
									begin
										elec_tr_lane0.lane = lane_0;
										elec_tr_lane0.phase = 5;
										elec_tr_lane0.sbtx = v_if.sbtx;
										elec_tr_lane0.transport_to_electrical = { >> {lane_0_UL_received} };
										$display("[ELEC MONITOR] Data Received on Lane 0 from UL: %h", elec_tr_lane0.transport_to_electrical);
										lane_0_UL_received = {};
										elec_mon_scr.put(elec_tr_lane0);
										elec_tr_lane0 = new();
									end

									if (lane_1_UL_received.size() == 8)
									begin
										elec_tr_lane1.lane = lane_1;
										elec_tr_lane1.phase = 5;
										elec_tr_lane1.sbtx = v_if.sbtx;
										elec_tr_lane1.transport_to_electrical = { >> {lane_1_UL_received} };
										$display("[ELEC MONITOR] Data Received on Lane 1 from UL: %h", elec_tr_lane1.transport_to_electrical);
										lane_1_UL_received = {};
										elec_mon_scr.put(elec_tr_lane1);
										elec_tr_lane1 = new();
									end


								end

							endcase // v_if.generation_speed

							/*
							if (lane_0_UL_received.size() == 8)
							begin
								elec_tr_lane0.lane = lane_0;
								elec_tr_lane0.phase = 5;
								elec_tr_lane0.sbtx = v_if.sbtx;
								elec_tr_lane0.transport_to_electrical = { >> {lane_0_UL_received} };
								$display("[ELEC MONITOR] Data Received on Lane 0 from UL: %h", elec_tr_lane0.transport_to_electrical);
								lane_0_UL_received = {};
								elec_mon_scr.put(elec_tr_lane0);
								elec_tr_lane0 = new();
							end

							if (lane_1_UL_received.size() == 8)
							begin
								elec_tr_lane1.lane = lane_1;
								elec_tr_lane1.phase = 5;
								elec_tr_lane1.sbtx = v_if.sbtx;
								elec_tr_lane1.transport_to_electrical = { >> {lane_1_UL_received} };
								$display("[ELEC MONITOR] Data Received on Lane 1 from UL: %h", elec_tr_lane1.transport_to_electrical);
								lane_1_UL_received = {};
								elec_mon_scr.put(elec_tr_lane1);
								elec_tr_lane1 = new();
							end
							*/

							/*
							if ( (lane_0_UL_received.size() == 8) || (lane_1_UL_received.size() == 8) )
							begin
								v_if.phase_5_read_enable = 0;
							end
							*/
							
						end

						else
						begin
							// $display("in lane 0: %p", lane_0_UL_received);
							// $display("in lane 1: %p", lane_1_UL_received);

							// Reading SBTX, lane 0  and lane 1, and storing the read values in queues
							case  (v_if.generation_speed)
								gen2, gen3:
								begin
									lane_0_gen23_SLOS_received.push_back(v_if.lane_0_tx); // lane_0_rx for debugging
									lane_1_gen23_SLOS_received.push_back(v_if.lane_1_tx); // lane_1_rx for debugging
									lane_0_gen23_TS_received.push_back(v_if.lane_0_tx); // lane_0_rx for debugging
									lane_1_gen23_TS_received.push_back(v_if.lane_1_tx); // lane_1_rx for debugging

									//$display("[%0t] lane_0_gen23_received outside:[%0p]",$time(),lane_0_gen23_SLOS_received);
									//$display("[%0t] lane_0_gen23_received outside:[%0p]",$time(),lane_0_gen23_TS_received);


									if(v_if.generation_speed == gen2)
									begin
										TS_SIZE = TS_GEN_2_SIZE;
									end
									else if (v_if.generation_speed == gen3)
									begin
										TS_SIZE = TS_GEN_3_SIZE;
									end

									///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
									/////////////////////////////////          LANE 0 RECEIVER (gen2/3) (SLOS1/SLOS2)               ///////////////////////////////
									///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
					

									if (lane_0_gen23_SLOS_received.size() == SLOS_SIZE)
									begin

										gen_23_SLOS_detection(elec_tr_lane0, lane_0_gen23_SLOS_received, lane_0);

									end

									///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
									/////////////////////////////////          LANE 1 RECEIVER (gen2/3) (SLOS1/SLOS2)               ///////////////////////////////
									///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

									if (lane_1_gen23_SLOS_received.size() == SLOS_SIZE)
									begin

										gen_23_SLOS_detection(elec_tr_lane1, lane_1_gen23_SLOS_received, lane_1);

									end

									///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
									/////////////////////////////////          LANE 0 RECEIVER (gen2/3) (TS1/TS2)               ///////////////////////////////////
									///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

									if (lane_0_gen23_TS_received.size() == TS_SIZE)
									begin

										gen_23_TS_detection(elec_tr_lane0,lane_0_gen23_TS_received,lane_0);

									end

									///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
									/////////////////////////////////          LANE 1 RECEIVER (gen2/3) (TS1/TS2)               ///////////////////////////////////
									///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

									if (lane_1_gen23_TS_received.size() == TS_SIZE)
									begin

										gen_23_TS_detection(elec_tr_lane1,lane_1_gen23_TS_received,lane_1);
										
									end


								end


								gen4:
								begin
									lane_0_gen4_received.push_back(v_if.lane_0_tx); // lane_0_rx for debugging
									lane_1_gen4_received.push_back(v_if.lane_1_tx); // lane_1_rx for debugging

									// MONITOR DISPLAY FUNCTIONS FOR DEBUGGING
									//$display("[%0t] lane_0_gen4_received outside:[%0p]",$time(),lane_0_gen4_received);
									//$display("[%0t] lane_1_gen4_received outside:[%0p]",$time(),lane_1_gen4_received);

									//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
									/////////////////////////////////                LANE 0 RECEIVER (gen4)               /////////////////////////////////////////
									///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

															//////////////////////////////////////////////////
															//////  GENERATION 4 HEADER DETECTOR  // /////////
															//////////////////////////////////////////////////

									if (lane_0_gen4_received.size() > (TS_GEN_4_HEADER_SIZE - 1) )
									begin
										//$display("[%0t] lane_0_gen4_received outside:[%0p]",$time(),lane_0_gen4_received);
										//$display("[%0t] expected ts1 header[%b]",$time(),{CURSOR, 4'h2, ~(4'h2), 8'h0F});
										

										gen_4_header_detection(elec_tr_lane0, lane_0_gen4_received, lane_0);


																		////////////////////////////////////////////////////////////
																		//////  GENERATION 4 ORDERED SET PAYLOAD DETECTOR  /////////
																		////////////////////////////////////////////////////////////				
										case (elec_tr_lane0.o_sets)
											TS1_gen4:
											begin
												if (lane_0_gen4_received.size() == PRBS11_SYMBOL_SIZE)
												begin
													//$display("Size of queue %0d", lane_0_gen4_received.size());
													//$display("Size of TS1 %0d", $size(TS.TS1_lane_0[0]));
													//$display("[%0t] lane_0_gen4_received outside:[%0p]",$time(),lane_0_gen4_received);
													
													TS1_gen4_order_detection(elec_tr_lane0, lane_0_gen4_received, TS.TS1_lane_0, lane_0);
													
												end
											end

											TS2_gen4,TS3, TS4:
											begin



												lane_0_gen4_received = {};
												TS234_gen4_detected(elec_tr_lane0, 0, lane_0);
												//lane_0_gen4_received = {};



												// $display("ABLLL EL LENGTHHHHH: %d",lane_0_gen4_received.size());
												// $stop();
												
												// if (lane_0_gen4_received.size() == PRTS7_SYMBOL_SIZE) // should be == (since there is no payload (DUT limitation) we had to change it to >)
												// begin
												// 	//lane_0_gen4_received.reverse();
												// 	//$display("lane_0_gen4_received %p",lane_0_gen4_received);
												// 	//$display("[ELEC MONITOR] TASK PRTS7:%b ",TS.TS_234_lane_0[0]);
												// 	$display("PRTS7 LENGTH RECEIVED!!!!!!!!");
												// 	$stop();
												// 	TS234_DATA = {<< 2{ {<<{lane_0_gen4_received}} } }; //1st: reverse the whole symbol,  2nd: each 2 bits (starting from right) are written from left to right 

												// 	//TS234_DATA = TS234_DATA.reverse();
												// 	//$display("TS234_DATA: %b",TS234_DATA);

												
												// 	TS_234_gen4_order_detection(elec_tr_lane0, TS234_DATA, TS.TS_234_lane_0, lane_0);
													
												// end
											end

											
										endcase

									end

									///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
									/////////////////////////////////                LANE 1 RECEIVER  (GEN4)              /////////////////////////////////////////
									///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

																			//////////////////////////////////////////////////
																			//////  GENERATION 4 HEADER DETECTOR  // /////////
																			//////////////////////////////////////////////////

									if (lane_1_gen4_received.size() > (TS_GEN_4_HEADER_SIZE - 1) )
									begin
										//$display("[%0t] lane_0_gen4_received outside:[%0p]",$time(),lane_0_gen4_received);
										//$display("[%0t] expected ts1 header[%b]",$time(),{CURSOR, 4'h2, ~(4'h2), 8'h0F});
										

										gen_4_header_detection(elec_tr_lane1, lane_1_gen4_received, lane_1);


																		////////////////////////////////////////////////////////////
																		//////  GENERATION 4 ORDERED SET PAYLOAD DETECTOR  /////////
																		////////////////////////////////////////////////////////////	

										case (elec_tr_lane1.o_sets)

											TS1_gen4:
											begin

												if (lane_1_gen4_received.size() == PRBS11_SYMBOL_SIZE)
												begin
													//$display("Size of queue %0d", lane_1_gen4_received.size());
													//$display("Size of TS1 %0d", $size(TS.TS1_lane_1[0]));
													//$display("[%0t] lane_1_gen4_received outside:[%0p]",$time(),lane_1_gen4_received);
													//PRBS11 (420, 11'b11111111111, PRBS11_lane0);
													
													TS1_gen4_order_detection(elec_tr_lane1, lane_1_gen4_received, TS.TS1_lane_1, lane_1);


												end

											end

											TS2_gen4, TS3, TS4:
											begin


												lane_1_gen4_received = {};
												TS234_gen4_detected(elec_tr_lane1, 0, lane_1);
												//lane_1_gen4_received = {};

												// if (lane_1_gen4_received.size() == PRTS7_SYMBOL_SIZE)
												// begin
												// 	//lane_1_gen4_received.reverse();
												// 	//$display("lane_1_gen4_received %p",lane_1_gen4_received);
												// 	//$display("[ELEC MONITOR] TASK PRTS7:%b ",TS.TS_234_lane_1[0]);


												// 	TS234_DATA = {<< 2{ {<<{lane_1_gen4_received}} } }; //1st: reverse the whole symbol,  2nd: each 2 bits (starting from right) are written from left to right 
												// 	//$display("TS234_DATA: %b",TS234_DATA);

												// 	TS_234_gen4_order_detection(elec_tr_lane1, TS234_DATA, TS.TS_234_lane_1, lane_1);

												// end

											end
							
										endcase
									end
								end
							endcase
						end

					end
					/*
					begin
						if (v_if.phase_5_read_enable)
						begin
							$stop;

							wait_negedge (v_if.generation_speed);

							lane_0_UL_received.push_back(v_if.lane_0_tx);
							lane_1_UL_received.push_back(v_if.lane_1_tx);

							if (lane_0_UL_received.size() == 8)
							begin
								elec_tr_lane1.lane = lane_1;
								elec_tr_lane1.phase = 5;
								elec_tr_lane0.transport_to_electrical = { >> {lane_0_UL_received} };
								$display("[ELEC MONITOR] Data Received on Lane 0 from UL: %b", elec_tr_lane0.transport_to_electrical);
								lane_0_UL_received = {};
								elec_mon_scr.put(elec_tr_lane0);
								elec_tr_lane0 = new();
							end

							if (lane_1_UL_received.size() == 8)
							begin
								elec_tr_lane1.lane = lane_1;
								elec_tr_lane1.phase = 5;
								elec_tr_lane1.transport_to_electrical = { >> {lane_1_UL_received} };
								$display("[ELEC MONITOR] Data Received on Lane 1 from UL: %b", elec_tr_lane1.transport_to_electrical);
								lane_1_UL_received = {};
								elec_mon_scr.put(elec_tr_lane1);
								elec_tr_lane1 = new();
							end

							if ( (lane_0_UL_received.size() == 8) || (lane_1_UL_received.size() == 8) )
							begin
								v_if.phase_5_read_enable = 0;
							end
							
						end

						else
						begin
							wait_negedge (v_if.generation_speed);
						end
					end
					*/
				
				
				join_any
				
				
				if (v_if.phase != 3'b010)
				begin
					sent_to_scr = 1'b0;
				end


				if (v_if.phase == 3'b010)
				begin
					case (host_device)

						0: begin // In case of host router
							if (v_if.sbtx && !sbtx_high_flag)
							begin
								sbtx_raised_time = $time;
								//$display("[ELEC MON] sbtx_raised_time:%t", sbtx_raised_time);
								sbtx_high_flag = 1;
							end

							if (!v_if.sbtx)
							begin
								sbtx_high_flag = 0;
							end

							if (sbtx_high_flag && ($time >= (sbtx_raised_time + tConnectRx) ) && !sent_to_scr ) // sbtx high from DUT
							begin
								//-> sbtx_high_recieved;
								//$display("[ELEC MON] sbtx_high_recieved:%t", $time);
								elec_tr.sbtx = 1; 
								elec_tr.phase = 3'b010;
								sent_to_scr = 1'b1;
								elec_mon_scr.put(elec_tr);
								elec_tr = new();

							end
						end

						1: begin // In case of device router
							if ($time < (sbrx_raised_time + tConnectRx) )
							begin
								assert(v_if.sbtx == 0);
								//$display("Current time: %0t", $time);
							end

							if (v_if.sbtx && ($time >= (sbrx_raised_time + tConnectRx) ) && !sent_to_scr) // sbtx high from DUT
							begin
								//-> sbtx_high_recieved;
								//$display("[ELEC MON] sbrx_raised_time:%t", sbrx_raised_time);
								//$display("[ELEC MON] sbtx_high_recieved:%t", $time);
								elec_tr.sbtx = 1;
								elec_tr.phase = 3'b010;
								sent_to_scr = 1'b1;
								elec_mon_scr.put(elec_tr);
								elec_tr = new();

							end
						end

					endcase
					
				end
				
		
				

			end
			

		endtask : run
































































								///////////////////////////////////////////////////////////////////////////////////////////
								///////////////////////////////////////////////////////////////////////////////////////////
								/////////////////////////////////         TASKS             ///////////////////////////////
								///////////////////////////////////////////////////////////////////////////////////////////
								///////////////////////////////////////////////////////////////////////////////////////////


		//This task is used to detect the transaction type, depending on the first 2 symbols (20 bits) received
		task detect_transaction_type;
			/*
			expected = {start_bit,reverse_data(DLE),stop_bit,start_bit,reverse_data(STX_rsp),stop_bit};
			received = {>>{SB_data_received}};
			$display("Expected: %0b", expected);
			$display("Received: %0b", received);
			*/
			case ({>>{SB_data_received}}) //(SB_data_received[0:19]) 
				{start_bit,reverse_data(DLE),stop_bit,start_bit,reverse_data(STX_cmd),stop_bit}: // AT command received
				begin
					$display("[ELEC MONITOR] AT_cmd DETECTED!!!!!!!!!!!!!!!");
					elec_tr.transaction_type = AT_cmd;
				end
				{start_bit,reverse_data(DLE),stop_bit,start_bit,reverse_data(STX_rsp),stop_bit}: // AT response Received
				begin
					$display("[ELEC MONITOR] Time: %0t   AT_RESPONSE DETECTED!!!!!!!!!!!!!!!", $time);
					elec_tr.transaction_type = AT_rsp;
				end
				
				{start_bit,reverse_data(DLE),stop_bit,start_bit,reverse_data(LSE_lane0),stop_bit} , 
				{start_bit,reverse_data(DLE),stop_bit,start_bit,reverse_data(LSE_lane1),stop_bit} : // LT_fall received
				begin
					$display("[ELEC MONITOR] LT_FALL DETECTED!!!!!!!!!!!!!!!");
					elec_tr.transaction_type = LT_fall; //LT_fall
				end

				default:
				begin
					//If no LT, AT_cmd or AT_rsp was detected, we pop the first element received
					void'(SB_data_received.pop_front());
				end
			endcase 

		endtask : detect_transaction_type


		//This task is used to get the needed data from the received transaction, after knowing its type
		task receive_transaction_data();

			case (elec_tr.transaction_type)

				LT_fall:
				begin
					if(SB_data_received.size() == LT_TR_SIZE) // FULL LT Transaction Received
					begin
						LSE_received = { << {SB_data_received [11:18] } };
						CLSE_received = { << {SB_data_received [21:28] } };

						if (CLSE_received != ~LSE_received)
						begin
							$error("Wrong LT_fall Received: CLSE is not the complement of LSE");
							$display("LT_FALL: LSE : %b",LSE_received);
						 	$display("LT_FALL: CLSE : %b", CLSE_received); 
						end
						else // case of Correct LT_Fall transaction, assign transaction compnents
						begin
							$display("[ELEC MONITOR] LT_FALL Transaction Confirmed ");
							elec_tr.phase = v_if.phase;
							elec_mon_scr.put(elec_tr); // send transaction to the scoreboard
							SB_data_received = {};
							
							elec_tr = new();
						end
					end
				end

				AT_cmd:
				begin
					// assume no Command_Data for now as no Write operations are to be tested (LIMITATION)
					if(SB_data_received.size() == 80) //  AT Transaction Received
					begin
						ETX_received = { << {SB_data_received[71:78]}};
						if(ETX_received != ETX) // STATIC TYPE CASTINGG
					 	begin
					 		$error("[ELEC MONITOR] Wrong AT Command Received");
					 		$display("EXPECTED ETX: %b, received ETX: %b",ETX,ETX_received);
					 	end
						 else // case of a correct AT command, assign transaction components
						begin
							$display("[ELEC MONITOR] Time: %0t  Correct AT Command Received", $time);
							elec_tr.transaction_type = AT_cmd;
							elec_tr.address = { << { SB_data_received[21:28] }}; 
							elec_tr.len =  { << { SB_data_received[31:37] }};
							elec_tr.read_write =  { << { SB_data_received[38] }} ;
							elec_tr.crc_received[7:0] =  { << { SB_data_received[41:48] }};
							elec_tr.crc_received[15:8] =  { << { SB_data_received[51:58] }};

							// elec_tr.phase = v_if.phase;  // Must be changed later !!!!!!!!!!!!!!
							elec_tr.phase = 3;
							elec_tr.sbtx = 1'b1;
							elec_mon_scr.put(elec_tr);

							SB_data_received = {};
							//-> elec_AT_cmd_received;

							elec_tr = new();
						end
					end
				end


				AT_rsp:
				begin
					if(SB_data_received.size() == 40)
					begin
						elec_tr.len = { << {SB_data_received[31:37]} };
					end

					if(SB_data_received.size() == (80+(elec_tr.len*10))) // FULL AT Response Received // limitation: can't check whether the AT rsp is correct or not due to variable length
					begin
						elec_tr.transaction_type = AT_rsp;
						elec_tr.address = { << {SB_data_received[21:28]} };
						elec_tr.len = { << {SB_data_received[31:37]} };
						elec_tr.read_write = { << {SB_data_received[38]} };

						repeat (40)
						begin
							void'(SB_data_received.pop_front()); // check weather front or back is needed
						end

						for(int i = 0; i<elec_tr.len*10;i++) 
						begin
							//$display("[MONITOR] Rsp_Data function called");
							Rsp_Data[i] = SB_data_received.pop_front();
						end

						//$display("[MONITOR] Rsp_Data [%0h]",Rsp_Data[23:0]);
						elec_tr.cmd_rsp_data[23:0] = {Rsp_Data[28:21],Rsp_Data[18:11],Rsp_Data[8:1]};
						elec_tr.crc_received [7:0] = { << {SB_data_received[1:8]} };
						elec_tr.crc_received [15:8] = { << {SB_data_received[11:18]} };

						repeat (20)
						begin
							void'(SB_data_received.pop_front()); // check weather front or back is needed
						end

						DLE_ETX_received = { >> {SB_data_received }};
						//DLE_ETX_received = { << {SB_data_received [1:8]}};

						if(DLE_ETX_received != { {start_bit, reverse_data(DLE), stop_bit}, {start_bit,reverse_data(ETX), stop_bit} } ) // STATIC TYPE CASTINGG
					 	begin
					 		$error("[ELEC MONITOR] Wrong AT Response Received");
					 		$display("EXPECTED DLE + ETX : %b, received DLE + ETX: %b",{ {start_bit, reverse_data(DLE), stop_bit}, {start_bit,reverse_data(ETX), stop_bit} } ,DLE_ETX_received);
					 	end
					 	else
					 	begin

					 		$display("[ELEC MONITOR] Time: %0t  Correct AT Response Received", $time);
					 		elec_tr.phase = v_if.phase;
					 		elec_tr.sbtx = 1'b1;
							elec_mon_scr.put(elec_tr);
							SB_data_received = {};
							elec_tr = new();

					 	end

					end
				end

			endcase

		endtask : receive_transaction_data

		

		//This task is used to detect the type of the received ordered set from its header (GEN2/3)
		task automatic gen_23_SLOS_detection;

			ref elec_layer_tr elec_tr_lane_x;
			ref bit lane_x_gen23_received [$];
			input LANE lane;

			case ({ >> {lane_x_gen23_received}})

				TS.SLOS1_64_enc_mon: begin

					$display("[ELEC MONITOR] SLOS 1 gen 2 RECEIVED CORRECTLY  ON [%p]",lane);
					gen23_transaction_assignment (elec_tr_lane_x,lane_x_gen23_received, None, SLOS1,ord_set,lane);

				end

				TS.SLOS2_64_enc_mon: begin

					$display("[ELEC MONITOR] SLOS 2 gen 2 RECEIVED CORRECTLY  ON [%p]",lane);
					gen23_transaction_assignment (elec_tr_lane_x,lane_x_gen23_received, None, SLOS2,ord_set,lane);

				end

				TS.SLOS1_128_enc_mon: begin

					$display("[ELEC MONITOR] SLOS 1 gen 3 RECEIVED CORRECTLY  ON [%p]",lane);
					gen23_transaction_assignment (elec_tr_lane_x,lane_x_gen23_received, None, SLOS1,ord_set,lane);

				end

				TS.SLOS2_128_enc_mon: begin

					$display("[ELEC MONITOR] SLOS 2 gen 3 RECEIVED CORRECTLY  ON [%p]",lane);
					gen23_transaction_assignment (elec_tr_lane_x,lane_x_gen23_received, None, SLOS2,ord_set,lane);

				end


				default:
				begin
					void'(lane_x_gen23_received.pop_front());
				end

			endcase

		endtask


		task automatic gen_23_TS_detection;

			ref elec_layer_tr elec_tr_lane_x;
			ref bit lane_x_gen23_received [$];
			input LANE lane;

			logic [7:0] lane_number;
			
			if (lane == lane_0)
				begin
					lane_number = lane_number_0;
				end
			else
				begin
					lane_number = lane_number_1;
				end
			// expected = {2'b10, {<<8{{<<{{5'b0, 3'b001, lane_number, 16'b0, 3'b0, 3'b001, 10'b0, TSID_TS1, SCR}}}}}};
			// $display("expected %b",expected);

			// if ({ >> {lane_x_gen23_received}} == {2'b10, {<<8{{<<{{5'b0, 3'b001, lane_number, 16'b0, 3'b0, 3'b001, 10'b0, TSID_TS1, SCR}}}}}})
			// begin
			// 		$display("[ELEC MONITOR] [INSIDE IF] TS1 gen 2 RECEIVED CORRECTLY  ON [%p]",lane);
			// 		gen23_transaction_assignment (elec_tr_lane_x,lane_x_gen23_received, None, TS1_gen2_3,ord_set,lane);
			// 		$stop();
			// end
			// else
			// begin
			// 	$display("NO");
			// end

			if(lane_x_gen23_received.size() == TS_GEN_2_SIZE)
			begin
				case ({ >> {lane_x_gen23_received}})

					{2'b10, {<<8{{<<{{5'b0, 3'b001, lane_number, 16'b0, 3'b0, 3'b001, 10'b0, TSID_TS1, SCR}}}}}}: 
					begin
	
						$display("[ELEC MONITOR] TS1 gen 2 RECEIVED CORRECTLY  ON [%p]",lane);
						gen23_transaction_assignment (elec_tr_lane_x,lane_x_gen23_received, None, TS1_gen2_3,ord_set,lane);
						
					end
	
					{2'b10, {<<8{{<<{{5'b0, 3'b001, lane_number, 16'b0, 3'b0, 3'b001, 10'b0, TSID_TS2, SCR}}}}}}: 
					begin
	
						$display("[ELEC MONITOR] TS2 gen 2 RECEIVED CORRECTLY  ON  [%p]",lane);
						gen23_transaction_assignment (elec_tr_lane_x,lane_x_gen23_received, None, TS2_gen2_3,ord_set,lane);
	
					end
	
					default:
					begin
						void'(lane_x_gen23_received.pop_front());	
					end

				endcase
			end

			else if(lane_x_gen23_received.size() == TS_GEN_3_SIZE)
			begin
				case ({ >> {lane_x_gen23_received}})

					{4'b1010, {<<8{{<<{{5'b0, 3'b001, lane_number, 16'b0, 3'b0, 3'b001, 10'b0, TSID_TS1, SCR}}}}}, 
							{<<8{{<<{{5'b0, 3'b001, lane_number, 16'b0, 3'b0, 3'b001, 10'b0, TSID_TS1, SCR}}}}}}: 
					begin
	
						$display("[ELEC MONITOR] TS1 gen 3 RECEIVED CORRECTLY  ON  [%p]",lane);
						gen23_transaction_assignment (elec_tr_lane_x,lane_x_gen23_received, None, TS1_gen2_3,ord_set,lane);
						//gen23_transaction_assignment (elec_tr_lane_x,lane_x_gen23_received, None, TS1_gen2_3,ord_set,lane);
						
					end
	
					{4'b1010, {<<8{{<<{{5'b0, 3'b001, lane_number, 16'b0, 3'b0, 3'b001, 10'b0, TSID_TS2, SCR}}}}},
							{<<8{{<<{{5'b0, 3'b001, lane_number, 16'b0, 3'b0, 3'b001, 10'b0, TSID_TS2, SCR}}}}}}: 
					begin
	
						$display("[ELEC MONITOR] TS2 gen 3 RECEIVED CORRECTLY  ON  [%p] at time: %0t",lane, $time);
						gen23_transaction_assignment (elec_tr_lane_x,lane_x_gen23_received, None, TS2_gen2_3,ord_set,lane);
						//gen23_transaction_assignment (elec_tr_lane_x,lane_x_gen23_received, None, TS2_gen2_3,ord_set,lane);
						
					end
	
					default:
					begin
						void'(lane_x_gen23_received.pop_front());	
					end
	
				endcase
			end
			
		endtask




		//This task is used to detect the type of the received ordered set from its header (GEN4)
		task automatic gen_4_header_detection;

			ref elec_layer_tr elec_tr_lane_x;
			ref bit lane_x_gen4_received [$];
			input LANE lane;

			casex ( { >> {lane_x_gen4_received[ $size(lane_x_gen4_received) - 28 :  $size(lane_x_gen4_received) - 1 ]} } ) // should be >>  that order (28      1)
				{CURSOR, 4'h2, ~(4'h2), 8'h0F}: // TS1 GEN4 DETECTED HEADER
				begin
					$display("%0t [ELEC MONITOR]*******TS1 GEN4 DETECTED ON %0d **********", $time, lane.name());
					
					elec_tr_lane_x.o_sets = TS1_gen4;
	
					lane_x_gen4_received = {};

				end

				{CURSOR, 4'h4, ~(4'h4), 8'h0F}: // TS2 GEN4 DETECTED HEADER
				begin
					$display("[ELEC MONITOR]*******TS2 GEN4 DETECTED ON %0d **********", lane.name());

					elec_tr_lane_x.o_sets = TS2_gen4;
					repeat(2) @(posedge v_if.gen4_lane_clk);
					@(negedge v_if.gen4_lane_clk);
					//lane_x_gen4_received = {}; // ALIIIIIIIIIIIIIIIIIIIIIIIIIII REMOVED AS THE PAYLOAD IS NO LONGER SENT BY DUT (limitation)

				end

				{CURSOR, 4'h6, ~(4'h6), 8'h0F}: // TS3 GEN4 DETECTED HEADER
				begin
					$display("[ELEC MONITOR]*******TS3 GEN4 DETECTED ON %0d **********", lane.name());

					elec_tr_lane_x.o_sets = TS3;
					repeat(2) @(posedge v_if.gen4_lane_clk);
					@(negedge v_if.gen4_lane_clk);
					lane_x_gen4_received = {};

				end

				{CURSOR, 8'hF0, 8'hx}: // TS4 GEN4 DETECTED HEADER
				begin
					$display("[ELEC MONITOR]*******TS4 GEN4 DETECTED ON %0d **********", lane.name());

					
					elec_tr_lane_x.o_sets = TS4;
					check_count_bitwise(lane_x_gen4_received, elec_tr_lane_x.lane, elec_tr_lane_x.order);
					repeat(2) @(posedge v_if.gen4_lane_clk);
					@(negedge v_if.gen4_lane_clk);
					lane_x_gen4_received = {};

					//$stop;
				end

				// default:
				// begin
				// 	void'(lane_0_gen4_received.pop_front());
				// end

					
			endcase 

		endtask : gen_4_header_detection

		

		//This task is used to check the count and bitwise count fields, to make sure that they are bitwise compliment to each other
		task check_count_bitwise;
			input bit received_os [$];
			input LANE lane;
			output logic [3:0] order;

			// Counter and bitwise counter fields in the header of TS4
			bit [3:0] bitwise;
			bit [3:0] count;

			//Checking that bits [3:0] are bitwise compliment of bits [7:4] (counter field)
			bitwise = { >> {received_os[ $size(received_os) - 4 :  $size(received_os) - 1 ]} };
			count = { >> {received_os[ $size(received_os) - 8 :  $size(received_os) - 5 ]} };
			if (bitwise == ~ count )
			begin
				order = count;
				//$display("[MONITOR] TS4 received with order: %0b", elec_tr_lane0.order);
			end
			
			else
			begin
				$error("[ELEC MONITOR] Counter field and bitwise counter field are not bitwise compliment to each other on %0d ", lane.name());
				$display ("[ELEC MONITOR] Bitwise compliment field: %b", bitwise);
				$display ("[ELEC MONITOR] Compliment field: %b", count );
			end

		endtask : check_count_bitwise




		//This task is used to detect the order of the TS1 GEN 4
		task automatic TS1_gen4_order_detection;

			ref elec_layer_tr elec_tr_lane_x;
			ref bit lane_x_gen4_received [$];
			input bit [419:0] TS1 [15:0];
			input LANE lane;

			bit [419:0] TS_received;
			bit TS_found; // To indicate that the order was found

			int i = 0;
			TS_received = {>>{lane_x_gen4_received}} ;
			//$display("PRBS PAYLOAD %h",TS_received);	
			while ( (TS_found == 0) && (i <= 15) )
			begin
				if (TS_received == TS1[i])
				begin
					TS1_gen4_detected(elec_tr_lane_x, i, lane);
					TS_found = 1;
					elec_tr_lane_x = new();

				end

				else
				begin
					i++;
				end
			end

			if (TS_found == 0) // If the order of TS1 was not found
			begin
				$error("[ELEC MONITOR] WRONG TS1 RECEIVED ON %0d !!", lane.name);
				$display("[%t] Expected: %b" ,$time(),TS1[0]);
				$display("[%t] Received: %b ",$time(), TS_received);
				//$stop();
				elec_tr_lane_x = new();
			end

		endtask : TS1_gen4_order_detection

		



		//This task is used to send a transaction to the scoreboard and stimulus generator after detecting the order of the received TS1 GEN 4
		task automatic TS1_gen4_detected;

			ref elec_layer_tr elec_tr_lane_x;
			input logic [3:0] order;
			input LANE lane;

			elec_tr_lane_x.o_sets = TS1_gen4;
			elec_tr_lane_x.order = order;
			elec_tr_lane_x.lane = lane;
			elec_tr_lane_x.tr_os = ord_set;
			elec_tr_lane_x.phase = 4;
			elec_tr_lane_x.sbtx = v_if.sbtx;

			
			elec_mon_scr.put(elec_tr_lane_x);

			//os_received_mon_gen.put(elec_tr_lane_x);
			$display("[ELEC MONITOR] TS1 Gen 4 with order [%0d] RECEIVED CORRECTLY ON %0d", order, elec_tr_lane_x.lane.name());
			
		endtask : TS1_gen4_detected		




		//This task is used to detect the order of the received TS2/3/4 GEN 4
		task automatic TS_234_gen4_order_detection;

			ref elec_layer_tr elec_tr_lane_x;
			input bit [419:0] TS_received;
			input bit [419:0] TS234 [15:0];
			input LANE lane;

			bit TS_found = 0; // To indicate that the order was found

			int i = 0;
			
				$stop();	
			while ( (TS_found == 0) && (i <= 15) )
			begin
				if (TS_received == TS234[i])
				begin
					TS234_gen4_detected(elec_tr_lane_x, i, lane);
					TS_found = 1;
					elec_tr_lane_x = new();
				end

				else
				begin
					i++;
				end
			end

			if (TS_found == 0) // If the order of TS2/3/4 was not found
			begin
				$error("[ELEC MONITOR] WRONG TS PRTS RECEIVED ON %0d !!", lane.name); //elec_tr_lane_x.o_sets should be added

				elec_tr_lane_x = new();
			end

		endtask : TS_234_gen4_order_detection	




		//This task is used to send a transaction to the scoreboard and stimulus generator after detecting the order and type of the received TS in GEN 4
		task automatic TS234_gen4_detected;

			ref elec_layer_tr elec_tr_lane_x;
			input logic [3:0] order;
			input LANE lane;

			int error_detected;

			elec_tr_lane_x.o_sets = elec_tr_lane_x.o_sets;
			
			// THIS BLOCK OF CODE IS COMMENTED (DUT LIMITATION: NO PAYLOAD)
			//error_detected = 0;
			// if (elec_tr_lane_x.o_sets == TS4)
			// begin
			// 	if (elec_tr_lane_x.order != order)
			// 	begin
			// 		$error("[MONITOR] Wrong TS4 received: Header order does not match the payload order");
			// 		error_detected = 1;
			// 	end
			// end

			// else
			// begin
			// 	elec_tr_lane_x.order = order;
			// end
			// if (error_detected == 0)
			// begin
			// 	$display("[ELEC MONITOR] [%p] with order [%0d] RECEIVED CORRECTLY ON %0d",elec_tr_lane_x.o_sets, elec_tr_lane_x.order,  lane.name());	
			// end

			elec_tr_lane_x.lane = lane;
			elec_tr_lane_x.tr_os = ord_set;
			elec_tr_lane_x.phase = 4;
			elec_tr_lane_x.sbtx = v_if.sbtx;

			elec_mon_scr.put(elec_tr_lane_x);
			
			//os_received_mon_gen.put(elec_tr_lane_x);
			
			$display("[ELEC MONITOR] [%p] with order [%0d] RECEIVED CORRECTLY ON %0d",elec_tr_lane_x.o_sets, elec_tr_lane_x.order,  lane.name());	
			
			elec_tr_lane_x = new();
		endtask : TS234_gen4_detected	


		// Assign data to transactions to be sent via mailboxes
		task automatic gen23_transaction_assignment;

			ref   elec_layer_tr elec_tr_lane_x;
			ref   bit lane_x_gen23_received [$];

			input tr_type transaction_type = None;
			input OS_type o_sets;
			input tr_os_type tr_os;
			input LANE lane;



			elec_tr_lane_x.transaction_type = transaction_type ;
			elec_tr_lane_x.o_sets = o_sets;
			elec_tr_lane_x.tr_os = tr_os;
			elec_tr_lane_x.lane = lane;
			elec_tr_lane_x.sbtx = v_if.sbtx;
			elec_tr_lane_x.phase = 4;
			lane_x_gen23_received = {};

			elec_mon_scr.put(elec_tr_lane_x);

			/*if ( ( (o_sets == TS1_gen2_3) || (o_sets == TS2_gen2_3) ) && (elec_tr_lane_x.gen_speed == gen3) ) 
			begin
				elec_mon_scr.put(elec_tr_lane_x); // send another transaction since 1 ordered symbol from gen 3 contains 2 ordered sets in case of TS1 and TS2
			end*/

			//os_received_mon_gen.put(elec_tr_lane_x);
			elec_tr_lane_x = new();

		endtask	



		function bit [7:0] reverse_data (input bit[7:0] data);
			bit [7:0] data_reversed; 
			foreach (data[i]) begin
				data_reversed[7-i] = data[i];
			end
			return data_reversed;
		endfunction

		function bit [19:0] reverse_data_20 (input bit[19:0] data);
			bit [19:0] data_reversed; 
			foreach (data[i]) begin
				data_reversed[19-i] = data[i];
			end
			return data_reversed;
		endfunction



		task wait_negedge (input GEN generation);

			if (generation == gen2)
			begin
				@(negedge v_if.gen2_lane_clk);
			end
			else if (generation == gen3)
			begin
				@(negedge v_if.gen3_lane_clk);
			end
			else if (generation == gen4)
			begin
				@(negedge v_if.gen4_lane_clk);
			end
			else 
			begin
				@(negedge v_if.SB_clock);
			end
		endtask


	endclass : elec_layer_monitor
