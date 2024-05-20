	class config_space_stimulus_generator;

		config_transaction transaction_stim;
		mailbox #(config_transaction) mb_stim_drv, mb_stim_mod;
		event config_gen_drv_done;

		bit is_done; // to notify the stimulus generator that the driver finished the request


		//Events
		event config_req_received;	// indicates capability and generation read request from DUT
		/*
		event config_cap_req_received; // indicates capability read request from monitor
		event config_gen_req_received; // indicates generation read request from monitor
		*/

		function new (mailbox #(config_transaction) mb_stim_drv, mb_stim_mod, event config_gen_drv_done, event config_req_received);

			this.mb_stim_drv = mb_stim_drv;
			this.mb_stim_mod = mb_stim_mod;
			this.config_gen_drv_done = config_gen_drv_done;
			this.config_req_received = config_req_received;
			/*
			this.config_cap_req_received = config_cap_req_received;
			this.config_gen_req_received = config_gen_req_received;
			*/
			transaction_stim = new();

		endfunction : new

		/*
		task execute(input string select);
			case (select)
				
				"capability": begin
					@(config_cap_req_received);

					transaction_stim.lane_disable = 1'b0;
					transaction_stim.c_data_in = 8'h42;
					//$display("Stim before put");
					$display("[CONFIG GENERATOR] SENDING USB4 capability info");
					mb_stim_drv.put(transaction_stim);
					mb_stim_mod.put(transaction_stim);
					//$display("ALIIIIII config: %d: %d",mb_stim_drv.num(), mb_stim_mod.num() );
					//$display("Stim after put");
					//@(config_cap_req_received);
				end

				"generation": begin
					@(config_gen_req_received);
					transaction_stim.lane_disable = 1'b0;
					transaction_stim.c_data_in = 8'h40;
					$display("[CONFIG GENERATOR] SENDING GENERATION SPEED info");
					mb_stim_drv.put(transaction_stim);
					mb_stim_mod.put(transaction_stim);
					//@(config_gen_req_received); // should be @(config_gen_req_received)
				end

			endcase // select

			
		endtask : execute

		*/

		task execute();
			
					@(config_req_received);

					transaction_stim.lane_disable = 1'b0;
					transaction_stim.c_data_in = 32'h00200040;
					//$display("Stim before put");
					$display("[CONFIG GENERATOR] SENDING USB4 info");
					mb_stim_drv.put(transaction_stim);
					mb_stim_mod.put(transaction_stim);

					@(config_gen_drv_done);
					
					//$display("ALIIIIII config: %d: %d",mb_stim_drv.num(), mb_stim_mod.num() );
					//$display("Stim after put");
					//@(config_cap_req_received);
				//end
				/*
				"generation": begin
					@(config_gen_req_received);
					transaction_stim.lane_disable = 1'b0;
					transaction_stim.c_data_in = 8'h40;
					$display("[CONFIG GENERATOR] SENDING GENERATION SPEED info");
					mb_stim_drv.put(transaction_stim);
					mb_stim_mod.put(transaction_stim);
					//@(config_gen_req_received); // should be @(config_gen_req_received)
				end
				*/
			//endcase // select

			
		endtask : execute


	endclass : config_space_stimulus_generator
