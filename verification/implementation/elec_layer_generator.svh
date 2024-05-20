
	class elec_layer_generator;

		//Counters to count the number of ordered sets received on each lane
		int counter_lane_0 = 0;
		int counter_lane_1 = 0;
		int counter = 0;

		// Event Signals
		event elec_gen_drv_done;
		event sbtx_high_received;
		event elec_AT_cmd_received; // to Trigger the appropriate AT response when AT CMD is received
		event elec_AT_rsp_received; // to make the sequence wait for the AT response to be received


		//Transaction
		elec_layer_tr transaction;
		elec_layer_tr tr_mon; //transaction received from the monitor 
		
		// Mailboxes
		mailbox #(elec_layer_tr) elec_gen_mod; // connects stimulus generator to the reference model
		mailbox #(elec_layer_tr) elec_gen_drv; // connects Stimulus generator to the driver inside the agent
		mailbox #(elec_layer_tr) os_received_mon_gen; // connects monitor to the stimulus generator to indicated received ordered sets

		function new( mailbox #(elec_layer_tr) elec_gen_mod, mailbox #(elec_layer_tr) elec_gen_drv, mailbox #(elec_layer_tr) os_received_mon_gen, event elec_gen_drv_done, sbtx_high_received, elec_AT_cmd_received, elec_AT_rsp_received);

			// Mailbox connections between generator and agent
			this.elec_gen_mod = elec_gen_mod;
			this.elec_gen_drv = elec_gen_drv;

			this.os_received_mon_gen = os_received_mon_gen;

			// Event Signals Connections
			this.elec_gen_drv_done = elec_gen_drv_done;
			this.sbtx_high_received = sbtx_high_received;
			this.elec_AT_cmd_received = elec_AT_cmd_received;
			this.elec_AT_rsp_received = elec_AT_rsp_received;
			

		endfunction : new
		

	
	task sbrx_high (input string router_type);

		transaction = new();

		case (router_type) // The behaviour of the host router is different than the device router in phase 2
			"Host": begin
				host_device = 0;
				transaction.phase = 3'b010; // phase 2
				transaction.sbrx = 1'b0;
				elec_gen_drv.put(transaction); // Sending transaction to the Driver
				elec_gen_mod.put(transaction); // Sending transaction to the Reference model

				$display("[ELEC GENERATOR] Waiting for SBTX high");
				@(sbtx_high_received);

				transaction.sbrx = 1'b1;
				transaction.electrical_to_transport = 0;
				transaction.phase = 3'b010; // phase 2
				elec_gen_drv.put(transaction); // Sending transaction to the Driver
				//elec_gen_mod.put(transaction); // Sending transaction to the Reference model
				$display("[ELEC GENERATOR] SENDING phase 2 SBRX HIGH while the DUT is a HOST router");

				@(elec_gen_drv_done);


			end

			"Device": begin
				host_device = 1;
				transaction.sbrx = 1'b1;
				transaction.electrical_to_transport = 0;
				transaction.phase = 3'b010; // phase 2
				elec_gen_drv.put(transaction); // Sending transaction to the Driver
				elec_gen_mod.put(transaction); // Sending transaction to the Reference model
				$display("[ELEC GENERATOR] SENDING phase 2 SBRX HIGH while the DUT is a DEVICE router");
				@(elec_gen_drv_done); // wait for the driver to send SBRX high for tConnectRx 
				@(sbtx_high_received); // wait for the monitor to receive SBTX high for tConnectTx
				
			end

		endcase

		

	endtask : sbrx_high



	task send_transaction (input tr_type trans_type = None , input int phase = 3, read_write = 0, address = 0, len = 0, cmd_rsp_data = 0);

		// Logical layer transactions is sent by default in phase 3 (except LT fall: any phase)
		transaction = new();

		case (trans_type)
				
				LT_fall: begin //
					transaction.phase = phase;
					transaction.transaction_type = trans_type;
					transaction.tr_os = tr; 
					transaction.sbrx = 1; // for the model only
					$display("[ELEC GENERATOR] sending [LT_FALL] Transaction");
					elec_gen_drv.put(transaction); // Sending transaction to the Driver
					elec_gen_mod.put(transaction); // Sending transaction to the Reference model

					@(elec_gen_drv_done);
				end

				AT_cmd, AT_rsp : begin //AT_cmd, AT_rsp
					transaction.phase = phase;
					transaction.sbrx = 1; // for the model only
					transaction.transaction_type = trans_type;
					transaction.read_write = read_write;
					transaction.address = address;
					transaction.len = len;
					transaction.cmd_rsp_data = cmd_rsp_data;

					transaction.tr_os = tr; 
					if (trans_type == AT_rsp)
					begin
						@(elec_AT_cmd_received); //  wait for an AT command to respond to it
					end
						
					$display("[ELEC GENERATOR] Time:%0t sending [%0p] Transaction",$time, trans_type);
					elec_gen_drv.put(transaction); // Sending transaction to the Driver
					elec_gen_mod.put(transaction); // Sending transaction to the Reference model

					@(elec_gen_drv_done);
					
					if (trans_type == AT_cmd)
					begin
						@(elec_AT_rsp_received); //  wait for an AT response to be received
					end


				end


				/*
				default : begin
					//transaction.phase = phase;
					transaction.transaction_type = AT_cmd;
					transaction.read_write = read_write;
					transaction.address = 0;
					transaction.len = 0;
					transaction.cmd_rsp_data = 0;
					elec_gen_drv.put(transaction); // Sending transaction to the Driver
					//@(EVENT from ()!!!!!!!!!!!!!);
				end
				*/
			endcase

			$display("\n");

			// transaction.tr_os = tr; 

			// elec_gen_drv.put(transaction); // Sending transaction to the Driver
			// elec_gen_mod.put(transaction); // Sending transaction to the Reference model

			// @(elec_gen_drv_done);	// To wait for the driver to finish driving the data

	endtask : send_transaction



	task send_ordered_sets(input OS_type OS, input GEN generation);

		// according to the phase, the task determines when to send the ordered set 
		//(each generation needs to receive certain amount of ordered sets before sending the next ordered set)

		int counter_lane_0 = 0;
		int counter_lane_1 = 0;
		OS_type ordered_set;
		int limit;
		int num; // number of ordered sets to be sent in case of TS2

		transaction = new();
		tr_mon = new();

		
		transaction.phase = 4;
		transaction.o_sets = OS; //type of the ordered set
		transaction.tr_os = ord_set; // indicates whether the driver will send transaction or ordered set // ALIIIIIIIIIII
		transaction.gen_speed = generation; // to indicate the generation
		transaction.sbrx = 1;

		fork 
			begin
				case (OS)
				
				SLOS1, SLOS2, TS1_gen2_3, TS2_gen2_3 : 
				begin
					repeat (2) begin //should be 2
					//elec_gen_drv.put(transaction); // Sending transaction to the Driver
					elec_gen_mod.put(transaction); // Sending transaction to the Reference model

					// $display("[ELEC GENERATOR] SENDING [%0p]",OS);
					// @(elec_gen_drv_done);	// To wait for the driver to finish driving the data		
					// $display("[ELEC GENERATOR] [%0p] SENT SUCCESSFULLY ",OS);
					
					end
				end

				TS1_gen4, TS2_gen4, TS3, TS4: 
				begin
					
					//elec_gen_drv.put(transaction); // Sending transaction to the Driver (17-4-2024)!!!!!!!!! no longer needed as we wait for the DUT to send the ordered set first then we begin sending the ordered set
					elec_gen_mod.put(transaction); // Sending transaction to the Reference model
					$display("[ELEC GENERATOR] SENDING [%0p]",OS);
					@(elec_gen_drv_done);	// To wait for the driver to finish driving the data
					$display("[ELEC GENERATOR] [%0p] SENT SUCCESSFULLY ",OS);

				end

				default : 
				begin
					
				end

				endcase
			end

			begin // a mailbox from the monitor will signal that an ordered set has been received
				
				case (OS)
				
					SLOS1, SLOS2: begin
						while ( (counter_lane_0 < 2) || (counter_lane_1 < 2) )  // should be (counter < 2)
						begin // 1000 -> should be changed (timing parameters)
							// I think ordered_set should be reset each cycle: ordered_set = None (none should be added to the transaction) 

							if((counter_lane_0 == 1) && (counter_lane_1 == 1)) // ALIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII (15-4-2024)
								begin
									transaction.o_sets = OS;
									repeat (2)
									begin
										elec_gen_drv.put(transaction);
										$display("[ELEC GENERATOR] SENDING [%0p]",OS);
										@(elec_gen_drv_done);	// To wait for the driver to finish driving the data		
										$display("[ELEC GENERATOR] [%0p] SENT SUCCESSFULLY ",OS);
									end
									
								end

							os_received_mon_gen.get(tr_mon);
							if (tr_mon.o_sets == OS)
							begin
								if (tr_mon.lane == lane_0)
									begin
										counter_lane_0 = counter_lane_0 + 1;
										$display("[ELEC GENERATOR] Received [%0p] [%0d] times on lane 0. ",tr_mon.o_sets, counter_lane_0);	
									end
								else if (tr_mon.lane == lane_1)
									begin
										counter_lane_1 = counter_lane_1 + 1;
										$display("[ELEC GENERATOR] Received [%0p] [%0d] times on lane 1. ",tr_mon.o_sets, counter_lane_1);	
									end
								
							end

							else 
							begin
								if (tr_mon.lane == lane_0)
									begin
										counter_lane_0 = 0;
									end

								else if (tr_mon.lane == lane_1)
									begin
										counter_lane_1 = 0;
									end
							end

							//Storing the time when first SLOS1 was sent to calculate tTrainingError
							if (OS == SLOS1)
							begin
								if (counter_lane_0 == 1)
								begin
									lane_0_tTrainingError_time = $time;
								end

								if (counter_lane_1 == 1)
								begin
									lane_1_tTrainingError_time = $time;
									
								end
							end

						end
						
					end

					TS1_gen2_3: begin

						if(generation == gen3) 
							limit = 8; // should be 16 !!!!
						else if (generation == gen2)
							limit = 32;

						while ((counter_lane_0 < limit) || (counter_lane_1 < limit)) // should be (counter != limit)
						begin // 1000 -> should be changed (timing parameters)
							// I think ordered_set should be reset each cycle: ordered_set = None (none should be added to the transaction)

							if((counter_lane_0 == 1) && (counter_lane_1 == 1)) // ALIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII (15-4-2024)
								begin
									transaction.o_sets = OS;
									
									if (generation == gen3)
									begin
										num = 1; // since the driver already sends 2 TS2 in case of gen 3 for the 128/132 encoding
									end

									else
									begin
										num = 2;
									end

									repeat (num) // was repeat (2) originally
									begin
										elec_gen_drv.put(transaction);
										$display("[ELEC GENERATOR] SENDING [%0p]",OS);
										@(elec_gen_drv_done);	// To wait for the driver to finish driving the data		
										$display("[ELEC GENERATOR] [%0p] SENT SUCCESSFULLY ",OS);
									end
									
								end

							os_received_mon_gen.get(tr_mon);
							if (tr_mon.o_sets == OS)
							begin
								if (tr_mon.lane == lane_0)
									begin
										counter_lane_0 = counter_lane_0 + 1;
										$display("[ELEC GENERATOR] Received [%0p] [%0d] times on lane 0. ",tr_mon.o_sets, counter_lane_0);	
									end
								else if (tr_mon.lane == lane_1)
									begin
										counter_lane_1 = counter_lane_1 + 1;
										$display("[ELEC GENERATOR] Received [%0p] [%0d] times on lane 1. ",tr_mon.o_sets, counter_lane_1);	
									end
								
							end

							else 
							begin
								if (tr_mon.lane == lane_0)
									begin
										counter_lane_0 = 0;
									end

								else if (tr_mon.lane == lane_1)
									begin
										counter_lane_1 = 0;
									end
							end

						end
					
								
					end

					TS2_gen2_3: begin
						
						if(generation == gen3) 
							limit = 4; // should be 8 !!!!!
						else if (generation == gen2)
							limit = 16;
						
						while ((counter_lane_0 < limit) || (counter_lane_1 < limit)) // should be (counter != limit)
						begin 
							// I think ordered_set should be reset each cycle: ordered_set = None (none should be added to the transaction) 
							
							if((counter_lane_0 == 1) && (counter_lane_1 == 1)) // should be &&
								begin
									
									transaction.o_sets = OS;
									
									if (generation == gen3)
									begin
										num = 1; // since the driver already sends 2 TS2 in case of gen 3 for the 128/132 encoding
									end

									else
									begin
										num = 2;
									end

									repeat (num) // was repeat (2) originally
									begin
										elec_gen_drv.put(transaction);
										$display("[ELEC GENERATOR] SENDING [%0p]",OS);
										@(elec_gen_drv_done);	// To wait for the driver to finish driving the data		
										$display("[ELEC GENERATOR] [%0p] SENT SUCCESSFULLY at time: %t",OS, $time);
									end
									
								end

							os_received_mon_gen.get(tr_mon);
							if (tr_mon.o_sets == OS)
							begin
								if (tr_mon.lane == lane_0)
									begin
										counter_lane_0 = counter_lane_0 + 1;
										$display("[ELEC GENERATOR] Received [%0p] [%0d] times on lane 0. ",tr_mon.o_sets, counter_lane_0);	
									end
								else if (tr_mon.lane == lane_1)
									begin
										counter_lane_1 = counter_lane_1 + 1;
										$display("[ELEC GENERATOR] Received [%0p] [%0d] times on lane 1. ",tr_mon.o_sets, counter_lane_1);	
									end
								
							end

							else 
							begin
								if (tr_mon.lane == lane_0)
									begin
										counter_lane_0 = 0;
									end

								else if (tr_mon.lane == lane_1)
									begin
										counter_lane_1 = 0;
									end
							end


							//Checking that the training duration is less than tTrainingError (500us)
							if (counter_lane_0 == limit) //should be == limit
							begin
								assert($time <= (lane_0_tTrainingError_time + tTrainingError) );
							end

							if (counter_lane_1 == limit) //should be == limit
							begin
								assert($time <= (lane_1_tTrainingError_time + tTrainingError) );
							end
							

						end
					end

					TS1_gen4, TS2_gen4, TS3: 
					begin
						while ((counter_lane_0 < 16) || (counter_lane_1 < 16))  // should be 16
							begin // 1000 -> should be changed (timing parameters)
							// I think ordered_set should be reset each cycle: ordered_set = None (none should be added to the transaction) 
							if((counter_lane_0 == 1) && (counter_lane_1 == 1)) // ALIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII (15-4-2024)
								begin
									transaction.o_sets = OS;
									elec_gen_drv.put(transaction);
								end
							os_received_mon_gen.get(tr_mon);
							if (tr_mon.o_sets == OS)
							begin
								if (tr_mon.lane == lane_0)
								begin
									counter_lane_0 = counter_lane_0 + 1;
									$display("[ELEC GENERATOR] Received [%0p] [%0d] times on lane 0. ",tr_mon.o_sets, counter_lane_0);
									
								end
								else if (tr_mon.lane == lane_1)
								begin
									counter_lane_1 = counter_lane_1 + 1;
									$display("[ELEC GENERATOR] Received [%0p] [%0d] times on lane 1. ",tr_mon.o_sets, counter_lane_1);	
								end
								
							end

							else 
							begin
								if (tr_mon.lane == lane_0)
								begin
									counter_lane_0 = 0;
								end

								else if (tr_mon.lane == lane_1)
								begin
									counter_lane_1 = 0;
								end
							end

							//Storing the time when first TS1 gen4 was sent to calculate tTrainingError
							if (OS == TS1_gen4)
							begin
								if (counter_lane_0 == 1) //First TS1
								begin
									lane_0_tTrainingError_time = $time;
									lane_0_tGen4TS1  = $time;
								end

								if (counter_lane_1 == 1) //First TS1
								begin
									lane_1_tTrainingError_time = $time;
									lane_1_tGen4TS1  = $time;
									
								end
							end


							//Checking that the duration of the transition from first TS1 to TS2 is less than tGen4TS1 (400ms)
							if (OS == TS2_gen4)
							begin
								if (counter_lane_0 == 1) //First TS2
								begin
									assert($time <= (lane_0_tGen4TS1 + tGen4TS1) );

									//Storing the time when first TS2 gen4 was sent to calculate tGen4TS1
									lane_0_tGen4TS2  = $time;

								end

								if (counter_lane_1 == 1) //First TS2
								begin
									assert($time <= (lane_1_tGen4TS1 + tGen4TS1) );
									
									//Storing the time when first TS2 gen4 was sent to calculate tGen4TS1
									lane_1_tGen4TS2  = $time;

								end
							end

							//Checking that the duration of the transition from first TS2 to TS3 is less than tGen4TS2 (200ms)
							if (OS == TS3)
							begin
								if (counter_lane_0 == 1) //First TS3
								begin
									assert($time <= (lane_0_tGen4TS2 + tGen4TS2) );
								end

								if (counter_lane_1 == 1) //First TS3
								begin
									assert($time <= (lane_1_tGen4TS2 + tGen4TS2) );
								end
							end

						end
					end

					TS4: 
					begin
						while ((counter_lane_0 < 16) || (counter_lane_1 < 16))  //should be 16
						begin // 1000 -> should be changed (timing parameters)
							// I think ordered_set should be reset each cycle: ordered_set = None (none should be added to the transaction) 
							if((counter_lane_0 == 1) && (counter_lane_1 == 1)) // ALIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII (15-4-2024)
								begin
									transaction.o_sets = OS;
									elec_gen_drv.put(transaction);
								end	
							os_received_mon_gen.get(tr_mon);
							if (tr_mon.o_sets == OS)
							begin
								if (tr_mon.lane == lane_0)
									begin
										counter_lane_0 = counter_lane_0 + 1;
										$display("[ELEC GENERATOR] Received [%0p] [%0d] times on lane 0. ",tr_mon.o_sets, counter_lane_0);	
									end
								else if (tr_mon.lane == lane_1)
									begin
										counter_lane_1 = counter_lane_1 + 1;
										$display("Time: %0t, [ELEC GENERATOR] Received [%0p] [%0d] times on lane 1. ",$time, tr_mon.o_sets, counter_lane_1);	
									end
								
							end

							else 
							begin
								if (tr_mon.lane == lane_0)
									begin
										counter_lane_0 = 0;
									end

								else if (tr_mon.lane == lane_1)
									begin
										counter_lane_1 = 0;
									end
							end

							//Checking that the training duration is less than tTrainingError (500us)
							if (counter_lane_0 == 16) //should be == 16 (or 15????????????)
							begin
								assert($time <= (lane_0_tTrainingError_time + tTrainingError) );
							end

							if (counter_lane_1 == 16) //should be == 16 (or 15????????????)
							begin
								assert($time <= (lane_1_tTrainingError_time + tTrainingError) );
							end

						end
					end


					default : begin
						
					end

				endcase 
				

			end

		join

		$display("\n");


	endtask : send_ordered_sets


	task elec_phase_5_read_control (input GEN speed = gen4, input string control = "enable");

		transaction = new(); 
		transaction.phase = 5 ; 
		transaction.gen_speed = speed;
		transaction.send_to_UL = 0;
		
		if (control == "enable")
		begin
			transaction.phase_5_read_disable = 0;		
		end

		else if (control == "disable")
		begin
			transaction.phase_5_read_disable = 1;		
			
		end

		elec_gen_drv.put(transaction);

		@(elec_gen_drv_done);


	endtask : elec_phase_5_read_control


	task send_to_transport_layer(input GEN speed = gen4);
		
		transaction = new();

		assert (transaction.randomize); // to randomize electrical_to_transport 
		transaction.phase = 5;
		transaction.sbrx = 1;
		transaction.gen_speed = speed;
		transaction.send_to_UL = 1;
		transaction.tr_os = none;
		
		elec_gen_drv.put(transaction); // Sending transaction to the Driver
		elec_gen_mod.put(transaction); // Sending transaction to the Reference model 


		@(elec_gen_drv_done);

	endtask : send_to_transport_layer

	
 	task phase_force (input int num, input GEN speed = gen4);

		transaction = new(); 
		transaction.phase = num ; 
		transaction.sbrx = 1; 
		transaction.gen_speed = speed;
		
		elec_gen_mod.put(transaction); // Sending transaction to the Reference model 

		if (num != 3)
			elec_gen_drv.put(transaction);
		
	endtask //phase_force

	

	endclass : elec_layer_generator
