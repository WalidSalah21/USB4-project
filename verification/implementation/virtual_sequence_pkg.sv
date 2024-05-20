	class virtual_sequence;

		// Virtual Stimulus generators
		config_space_stimulus_generator v_config_space_stim;
		elec_layer_generator v_elec_layer_generator;
		upper_layer_generator v_upper_layer_generator;


		//Basic Flow 1 for gen 4
		task run;

			//Phase 1
			v_elec_layer_generator.phase_force(1);
			
			v_config_space_stim.execute;

			//Phase 2
			v_elec_layer_generator.sbrx_high("Host");

			//$stop;

			// Phase 3
			v_elec_layer_generator.phase_force(3);

			v_elec_layer_generator.send_transaction(AT_rsp,3,0,8'd78,7'd3,24'h053303);  
			

			v_elec_layer_generator.send_transaction(AT_cmd,3,0,8'd78,7'd3,24'h000000); 

			
			
			// v_elec_layer_generator.send_transaction(LT_fall);  // Testing LT Fall 

			
			// // Phase 4


			v_elec_layer_generator.phase_force(4, gen4);
			v_upper_layer_generator.generation_assignment(gen4);

			//v_elec_layer_generator.phase_force(4);
			v_elec_layer_generator.send_ordered_sets(TS1_gen4,gen4);

			v_elec_layer_generator.send_ordered_sets(TS2_gen4,gen4);
			
			v_elec_layer_generator.send_ordered_sets(TS3,gen4);
			//#(tTrainingError); //To test tTrainingError
			v_elec_layer_generator.send_ordered_sets(TS4,gen4);

			
		
	
			
			// Phase 5
		

			fork 
				begin
					repeat (5)
						v_upper_layer_generator.send_transport_data(gen4);
				end

				begin
					//repeat (5)
					//#((10**15)/freq_40);
						v_elec_layer_generator.elec_phase_5_read_control (gen4, "enable");		
				end

			join

			v_elec_layer_generator.elec_phase_5_read_control (gen4, "disable");		



			fork
				begin
					repeat(10)
						v_elec_layer_generator.send_to_transport_layer(gen4);
					$display("[Virtual Sequence] Elec done: %t", $time);

				end

				begin
					v_upper_layer_generator.start_receiving(gen4);
				end

			join

			v_upper_layer_generator.disable_monitor(gen4);
				$display("[Virtual Sequence] Monitor disabled: %t", $time);



		
			$stop();

		endtask : run


		//Basic Flow 1 for gen 3
		task normal_scenario_gen_3;
			
			//Phase 1
			v_elec_layer_generator.phase_force(1);
			
			v_config_space_stim.execute;

			//Phase 2
			v_elec_layer_generator.sbrx_high("Host");


			// Phase 3
			v_elec_layer_generator.phase_force(3);

			v_elec_layer_generator.send_transaction(AT_rsp,3,0,8'd78,7'd3,24'h013303);  
			

			v_elec_layer_generator.send_transaction(AT_cmd,3,0,8'd78,7'd3,24'h000000); 

			
			// v_elec_layer_generator.send_transaction(LT_fall);  // Testing LT Fall 

			
			// // Phase 4

			v_elec_layer_generator.phase_force(4, gen3);

			v_upper_layer_generator.generation_assignment(gen3);

			
			v_elec_layer_generator.send_ordered_sets(SLOS1,gen3);

			v_elec_layer_generator.send_ordered_sets(SLOS2,gen3);
			

			v_elec_layer_generator.send_ordered_sets(TS1_gen2_3,gen3);

			fork
				begin
					v_elec_layer_generator.send_ordered_sets(TS2_gen2_3,gen3);
				end


				begin
					
					v_upper_layer_generator.wait_phase_5(gen3);

					fork 
						begin
							repeat (16)
								v_upper_layer_generator.send_transport_data(gen3);
						end

						begin
							//repeat (5)
								v_elec_layer_generator.elec_phase_5_read_control (gen3, "enable");		
						end

					join
				end

			join

			//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
			v_elec_layer_generator.elec_phase_5_read_control (gen3, "disable");		
			//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

	
			
			// Phase 5
			
			
			
			fork
				begin
					repeat(32)
						v_elec_layer_generator.send_to_transport_layer(gen3);

				end

				begin
					v_upper_layer_generator.start_receiving(gen3);
				end

			join

			v_upper_layer_generator.disable_monitor(gen3);



			$stop();

		endtask : normal_scenario_gen_3





		task normal_scenario_gen_2;

			//Phase 1
			v_elec_layer_generator.phase_force(1);
			
			v_config_space_stim.execute;

			//Phase 2
			v_elec_layer_generator.sbrx_high("Host");


			// Phase 3
			v_elec_layer_generator.phase_force(3);

			v_elec_layer_generator.send_transaction(AT_rsp,3,0,8'd78,7'd3,24'h011303);  
			

			v_elec_layer_generator.send_transaction(AT_cmd,3,0,8'd78,7'd3,24'h000000); 

			
			// v_elec_layer_generator.send_transaction(LT_fall);  // Testing LT Fall 

			
			// // Phase 4
			v_elec_layer_generator.phase_force(4, gen2);

			v_upper_layer_generator.generation_assignment(gen2);

			
			v_elec_layer_generator.send_ordered_sets(SLOS1,gen2);

			v_elec_layer_generator.send_ordered_sets(SLOS2,gen2);
			

			v_elec_layer_generator.send_ordered_sets(TS1_gen2_3,gen2);

			fork
				begin
					v_elec_layer_generator.send_ordered_sets(TS2_gen2_3,gen2);
				end


				begin
					
					v_upper_layer_generator.wait_phase_5(gen2);

					fork 
						begin
							repeat (16)
								v_upper_layer_generator.send_transport_data(gen2);
						end

						begin
							//repeat (5)
								v_elec_layer_generator.elec_phase_5_read_control (gen2, "enable");		
						end

					join
				end

			join

			//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
			v_elec_layer_generator.elec_phase_5_read_control (gen2, "disable");		
			//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

		
			// Phase 5
			
			
			
			fork
				begin
					repeat(16)
						v_elec_layer_generator.send_to_transport_layer(gen2);

				end

				begin
					v_upper_layer_generator.start_receiving(gen2);
				end

			join

			v_upper_layer_generator.disable_monitor(gen2);


			
			//disable
			$stop();

		endtask : normal_scenario_gen_2


	endclass : virtual_sequence
