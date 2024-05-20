	class config_space_monitor;

		config_transaction transaction_mon;
		mailbox #(config_transaction) mb_mon;
		virtual config_space_if config_vif;

		/*
		//Events
		event config_cap_req_received; // indicates capability read request from monitor
		event config_gen_req_received; // indicates generation read request from monitor
		*/

		function new (mailbox #(config_transaction) mb_mon);

			this.mb_mon = mb_mon;
			/*
			this.config_cap_req_received = config_cap_req_received;
			this.config_gen_req_received = config_gen_req_received;
			*/
			transaction_mon = new();

		endfunction : new


		task run;
			
			forever
			begin
				
				@(negedge config_vif.gen4_fsm_clk);

				// Obtaining Requests from the DUT
				transaction_mon.c_read = config_vif.c_read;
				transaction_mon.c_write = config_vif.c_write;
				transaction_mon.c_address = config_vif.c_address;
				transaction_mon.c_data_out = config_vif.c_data_out;
			

				//transaction_mon.c_read = 1; // SHOULD BE REMOVEDDDDDD
				//transaction_mon.c_address = 4; // SHOULD BE REMOVEDDDDDD

				if (transaction_mon.c_read || transaction_mon.c_write)
					begin
						mb_mon.put(transaction_mon);
						//$display("[Config monitor] received at time (%0t) data of ", $time);
					end
				

				/* //Now placed in the scoreboard
				if (transaction_mon.c_read)
					begin
						if (transaction_mon.c_address == 'd18 ) // CAPABILITY READ REQUEST
							begin
								-> config_cap_req_received;
							end
					end
				*/

				/*	
				if (transaction_mon.c_read)
					begin
						if (transaction_mon.c_address == 'd1 ) // CAPABILITY READ REQUEST
							begin
								-> config_cap_req_received;
							end

						else if (transaction_mon.c_address == 'h12 )  // GENERATION READ REQUEST
							begin
								-> config_gen_req_received;
								//-> config_req_req_received; // correct one to be used

							end

					end
				*/

			end

		endtask : run



	endclass : config_space_monitor

