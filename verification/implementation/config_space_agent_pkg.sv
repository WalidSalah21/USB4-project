	class config_space_agent;

		mailbox #(config_transaction) mb_stim_drv;
		mailbox #(config_transaction) mb_mon_scr;
		

		config_space_driver driver;
		config_space_monitor monitor;

		virtual config_space_if v_config_if;

		//Events
		event config_gen_drv_done;

		/*
		event config_cap_req_received; // indicates capability read request from monitor
		event config_gen_req_received; // indicates generation read request from monitor
		*/

		function new (virtual config_space_if v_config_if, mailbox #(config_transaction) mb_stim_drv, mailbox #(config_transaction) mb_mon_scr, event config_gen_drv_done);
			
			this.v_config_if = v_config_if;
			this.mb_stim_drv = mb_stim_drv;
			this.mb_mon_scr = mb_mon_scr;
			this.config_gen_drv_done = config_gen_drv_done;
			/*
			this.config_cap_req_received = config_cap_req_received;
			this.config_gen_req_received = config_gen_req_received;
			*/

		endfunction


		function void build();

			driver = new (mb_stim_drv, config_gen_drv_done);
			monitor = new (mb_mon_scr);

			driver.config_vif = v_config_if;
			monitor.config_vif = v_config_if;
			//$display("Agent build");

		endfunction : build


		task run();

			fork
				//$display("Agent run");
				//stimulus_gen.run();
				driver.run();
				monitor.run();

			join_none

		endtask


	endclass : config_space_agent

