	class upper_layer_driver;

		// Event Signals
		event UL_gen_drv_done;

		//Transaction
		upper_layer_tr UL_tr;

		// Virtual Interface
		virtual upper_layer_if v_if;

		// Mailboxes
		mailbox #(upper_layer_tr) UL_gen_drv; // connects Stimulus generator to the driver inside the agent


		function new(input virtual upper_layer_if v_if, mailbox #(upper_layer_tr) UL_gen_drv, event UL_gen_drv_done);

			//Interface Connections
			this.v_if = v_if;

			// Mailbox connections between (Driver) and (UL Agent)
			this.UL_gen_drv = UL_gen_drv;
			
			// Event Signals Connections
			this.UL_gen_drv_done = UL_gen_drv_done;
				
		endfunction : new

		task run;
			//parameter [63:0] freq_40 = 40 * 10 ** 9;			//40 GHz
			forever begin

				//////////////////////////////////////////////////
				/////RECEIVING TEST STIMULUS FROM generator //////
				//////////////////////////////////////////////////

				UL_tr = new();
				UL_gen_drv.get(UL_tr);
				v_if.phase = UL_tr.phase;
				v_if.generation_speed = UL_tr.gen_speed;

				//////////////////////////////////////////////////
				//////////////PIN LEVEL ASSIGNMENT ///////////////
				//////////////////////////////////////////////////



				// case (UL_tr.gen_speed)

				// 	gen2:
				// 	begin
				// 		Send_gen2_encoded();
				// 	end

				// 	gen3:
				// 	begin
				// 		Send_gen3_encoded();
				// 	end

				// 	gen4:
				// 	begin
				// 		Send_gen4_encoded();
				// 	end


				// endcase
				

				
				//wait_negedge(UL_tr.gen_speed); 
				

				//wait_negedge(UL_tr.gen_speed); 

				if (UL_tr.enable_receive)
				begin
					//repeat (20) //should be 24 !!!!!!!!!!!!!!!!!!
						//wait_negedge(UL_tr.gen_speed); 
					wait_negedge(UL_tr.gen_speed); 
					v_if.enable_monitor = 1;
					


				end

				else if (UL_tr.send_to_elec_enable)
				begin
					//wait_negedge(UL_tr.gen_speed); 
					
					v_if.wait_cl0_s = 0;
					
					wait(v_if.clk_cycles_counter == 1);
					//wait_negedge(UL_tr.gen_speed); 

					v_if.transport_layer_data_in = UL_tr.T_Data;
					$display("Time: %t [UL DRIVER] Data sent to electrical layer: %h", $time, UL_tr.T_Data);

					repeat (2)
						wait_negedge(UL_tr.gen_speed); //because (counter == 1) is read twice without this delay 

					wait(v_if.clk_cycles_counter == 1);

					v_if.transport_layer_data_in = UL_tr.T_Data_1;
					$display("Time: %t [UL DRIVER] Data sent to electrical layer: %h", $time, UL_tr.T_Data_1);
					wait_negedge(UL_tr.gen_speed);

						


					//repeat (2)
					//begin
						//assert(UL_tr.randomize);
						/*
						v_if.transport_layer_data_in = UL_tr.T_Data;
						$display("Time: %t [UL DRIVER] Data sent to electrical layer: %h", $time, UL_tr.T_Data);

						repeat (4)
							wait_negedge(UL_tr.gen_speed); 

						v_if.transport_layer_data_in = UL_tr.T_Data_1;
						$display("Time: %t [UL DRIVER] Data sent to electrical layer: %h", $time, UL_tr.T_Data_1);

						repeat (4-1) // only 3 because there is an extra wait_negedge() before the next data
							wait_negedge(UL_tr.gen_speed); 
						*/

					//end

					/*
					v_if.transport_layer_data_in = UL_tr.T_Data;
					$display("[UL DRIVER] Data sent to electrical layer: %b", UL_tr.T_Data);
					
					repeat (8)
						wait_negedge(UL_tr.gen_speed); 
					*/


					//#(8 * (10**15)/(2*freq_40));
					//-> UL_gen_drv_done; // Triggering Event to notify stimulus generator
				end

				/*else if (UL_tr.x)
				begin
					v_if.generation_speed = UL_tr.gen_speed;
					$display("@@@@@@@ X = 1 @@@@@@@@@@"); 

				end*/

				else if (UL_tr.wait_for_cl0s)
				begin
					v_if.wait_cl0_s = 1;
					wait_negedge(UL_tr.gen_speed); 
				end

				else 
				begin
					//To disable the monitor
					//v_if.enable_monitor = 1;
					v_if.wait_cl0_s = 0;

					//$display("%%%%%%%%%%%%%%Disabling the monitor:%%%%%%%%%%%%%%%%%% \n time: %t", $time);

					disable_monitor(UL_tr.gen_speed); 
					//v_if.generation_speed = UL_tr.gen_speed; 

						wait_negedge(UL_tr.gen_speed); 
					//v_if.enable_monitor = 1;
					v_if.enable_monitor = 0;

				end
				
			-> UL_gen_drv_done; // Triggering Event to notify stimulus generator


			end
			

		endtask : run

		task wait_negedge (input GEN generation);
			if (generation == gen2)
			begin
				@(negedge v_if.gen2_fsm_clk);
			end
			else if (generation == gen3)
			begin
				@(negedge v_if.gen3_fsm_clk);
			end
			else if (generation == gen4)
			begin
				@(negedge v_if.gen4_fsm_clk);
			end
		endtask


		

		task Send_gen2_encoded(); // 128/132 encoding

			wait_negedge(UL_tr.gen_speed);
			v_if.transport_layer_data_in = {4'b0101,UL_tr.T_Data[3:0]};
			UL_tr.T_Data = UL_tr.T_Data >> 4;
			repeat(7)
			begin
				wait_negedge(UL_tr.gen_speed);	
			end

			for (int i = 0 ; i<16; i++)
				begin
					wait_negedge(UL_tr.gen_speed);
					v_if.transport_layer_data_in = UL_tr.T_Data[7:0];
					UL_tr.T_Data = UL_tr.T_Data >> 8;

					repeat(7)
					begin
						wait_negedge(UL_tr.gen_speed);	
					end
				end
		endtask

		task Send_gen3_encoded(); // 64/66 encoding

			wait_negedge(UL_tr.gen_speed);
			v_if.transport_layer_data_in = {2'b01,UL_tr.T_Data[5:0]};
			UL_tr.T_Data = UL_tr.T_Data >> 6;
			repeat(7)
			begin
				wait_negedge(UL_tr.gen_speed);	
			end

			for (int i = 0 ; i<16; i++)
				begin
					wait_negedge(UL_tr.gen_speed);
					v_if.transport_layer_data_in = UL_tr.T_Data[7:0];
					UL_tr.T_Data = UL_tr.T_Data >> 8;

					repeat(7)
					begin
						wait_negedge(UL_tr.gen_speed);	
					end
				end
		endtask

		task Send_gen4_encoded(); // 8/11 encoding

			
			wait_negedge(UL_tr.gen_speed);
			v_if.transport_layer_data_in = {4'b0101,UL_tr.T_Data[3:0]};
			UL_tr.T_Data = UL_tr.T_Data >> 4;
			repeat(7)
			begin
				wait_negedge(UL_tr.gen_speed);	
			end

			for (int i = 0 ; i<16; i++)
				begin
					wait_negedge(UL_tr.gen_speed);
					v_if.transport_layer_data_in = UL_tr.T_Data[7:0];
					UL_tr.T_Data = UL_tr.T_Data >> 8;

					repeat(7)
					begin
						wait_negedge(UL_tr.gen_speed);	
					end
				end
		endtask

		task disable_monitor(input GEN generation);

			if (generation == gen2)
			begin
				repeat (75)
					@(negedge v_if.gen2_fsm_clk);
			end
			else if (generation == gen3)
			begin
				repeat (140)
					@(negedge v_if.gen3_fsm_clk);
			end
			else if (generation == gen4)
			begin
				repeat (24) // To give time (24 clk cycles) for the last byte to be recieved from the DUT
					@(negedge v_if.gen4_fsm_clk);
			end
		endtask : disable_monitor
		
endclass : upper_layer_driver
