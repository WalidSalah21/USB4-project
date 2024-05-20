	class elec_layer_agent;

		

		// virtual interface definition
		virtual electrical_layer_if v_if;

		//Agent Components
		elec_layer_monitor elec_mon;
		elec_layer_driver elec_drv;


		// Mailboxes

		mailbox #(elec_layer_tr) elec_mon_scr; // connects monitor to the scoreboard
		mailbox #(elec_layer_tr) elec_gen_drv; // connects Stimulus generator to the driver inside the agent
		//mailbox #(elec_layer_tr) os_received_mon_gen; // connects monitor to the stimulus generator to indicated received ordered sets


		//Event Signals
		event elec_gen_drv_done;
		/*
		event sbtx_high_recieved; // to identify phase 2 completion (sbtx high received)
		event elec_AT_cmd_received; // to Trigger the appropriate AT response when AT CMD is received
		*/

		// NEW Function
		function new(input virtual electrical_layer_if v_if, mailbox #(elec_layer_tr) elec_gen_drv, mailbox #(elec_layer_tr) elec_mon_scr, event elec_gen_drv_done);

			//Interface Connections
			this.v_if = v_if;

			
			// Mailbox connections between The Agent and Environment
			this.elec_gen_drv = elec_gen_drv; 
			this.elec_mon_scr = elec_mon_scr;
			//this.os_received_mon_gen = os_received_mon_gen;

			//Events
			this.elec_gen_drv_done = elec_gen_drv_done;
			/*
			this.sbtx_high_recieved = sbtx_high_recieved;
			this.elec_AT_cmd_received = elec_AT_cmd_received;
			*/

			// Agent's Component Handles
			elec_mon = new(v_if, elec_mon_scr);
			elec_drv = new(v_if, elec_gen_drv, elec_gen_drv_done);
		
		endfunction : new



		task run;
			fork
				//elec_gen.run();
				elec_mon.run();
				elec_drv.run();
			join


		endtask : run



	endclass : elec_layer_agent

