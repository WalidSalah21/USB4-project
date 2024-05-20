	class config_space_scoreboard;

		mailbox #(config_transaction) mb_model, mb_mon;
		config_transaction transaction_model, transaction_mon;

		//Events
		event config_req_received;	// indicates capability and generation read request from DUT


		function new (mailbox #(config_transaction) mb_model, mb_mon, event config_req_received);

			this.mb_mon = mb_mon;
			this.mb_model = mb_model;
			this.config_req_received = config_req_received;
			transaction_model = new();
			transaction_mon = new();

		endfunction : new


		task run;

			forever
			begin

				transaction_model = new();
				transaction_mon = new();

				/*
				if (mb_model.try_get(transaction_model))
					begin
						$display("[CONFIG SCOREBOARD] MODEL Transaction: %p",transaction_model);
					end
				*/	

				//* Getting first from the model since model will block in case we aren't in phase 1 
				mb_model.get(transaction_model);
				$display("[CONFIG SCOREBOARD] MODEL Transaction: %p",transaction_model);
				//$display("[CONFIG SCOREBOARD] MODEL Transaction: %p at %t ",transaction_model ,$time);


				mb_mon.get(transaction_mon);
				event_trigger();
				$display("[CONFIG SCOREBOARD] DUT Transaction: %p",transaction_mon);
				//$display("[CONFIG SCOREBOARD] DUT Transaction: %p at %t",transaction_mon ,$time);


				
				Config_c_read: assert(transaction_model.c_read === transaction_mon.c_read) else $error("[CONFIG SCOREBOARD] c_read doesn't match the expected value");
				Config_c_write: assert(transaction_model.c_write === transaction_mon.c_write) else $error("[CONFIG SCOREBOARD] c_write doesn't match the expected value");
				Config_c_address: assert(transaction_model.c_address === transaction_mon.c_address) else $error("[CONFIG SCOREBOARD] c_address doesn't match the expected value");
				Config_c_data_out: assert(transaction_model.c_data_out === transaction_mon.c_data_out) else $error("[CONFIG SCOREBOARD] c_address doesn't match the expected value");

				config_transactions: assert(	(transaction_model.c_read === transaction_mon.c_read) 		&&
												(transaction_model.c_write === transaction_mon.c_write) 	&&
												(transaction_model.c_address === transaction_mon.c_address)	&&
												(transaction_model.c_data_out === transaction_mon.c_data_out)
												) $display("[CONFIG SCOREBOARD] CORRECT transaction received ");
			end

		endtask : run



		task event_trigger;

			if (transaction_mon.c_read)
			begin
				if (transaction_mon.c_address == 'd18 ) // CAPABILITY READ REQUEST
				begin
					-> config_req_received;
				end
			end

		endtask : event_trigger

	endclass : config_space_scoreboard

