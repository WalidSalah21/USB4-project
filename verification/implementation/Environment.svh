	class Environment;
		//interfaces
		virtual upper_layer_if v_if;
		virtual electrical_layer_if elec_v_if;
		virtual config_space_if v_cif;

		//Reference Model
		ref_model ref_model;

		// Agents
		upper_layer_agent agent_UL;
		elec_layer_agent agent_elec;
		config_space_agent agent_config;

		//Sequences
		elec_layer_generator elec_gen;
		config_space_stimulus_generator config_gen;
		upper_layer_generator UL_gen;


		//Scoreboards
		upper_layer_scoreboard UL_sb;
		elec_layer_scoreboard elec_sb;
		config_space_scoreboard sb_config;

		//Virtual Sequence
		virtual_sequence vseq_config;

		//Scenario control
		string scenario;

		//Event Signals
		event elec_gen_drv_done;
		event sbtx_high_received; // to identify phase 2 completion (sbtx high received)
		event elec_AT_cmd_received; // to Trigger the appropriate AT response when AT CMD is received
		event elec_AT_rsp_received; // to make the sequence wait for the AT response to be received
		
		event UL_gen_drv_done;
		event cl0_s_raised;

		
		event config_gen_drv_done;
		event config_req_received;	// indicates capability and generation read request from DUT

		/*
		event config_cap_req_received; // indicates capability read request from monitor
		event config_gen_req_received; // indicates generation read request from monitor
		*/

		// Mailboxes 
		mailbox #(upper_layer_tr) UL_gen_drv; // connects Stimulus generator to the driver inside the agent
		mailbox #(upper_layer_tr) UL_gen_mod; // connects stimulus generator to the reference model
		mailbox #(upper_layer_tr) UL_mon_scr; // connects monitor to the scoreboard
		mailbox #(upper_layer_tr) UL_mod_scr; // connects reference model to the scoreboard

		mailbox #(elec_layer_tr) elec_gen_drv; // connects sequence to the driver
		mailbox #(elec_layer_tr) os_received_mon_gen; // connects monitor to the stimulus generator to indicate received ordered sets
		mailbox #(elec_layer_tr) elec_mon_scr; // connects monitor to the scoreboard
		mailbox #(elec_layer_tr) elec_mod_scr; // connects reference model to the scoreboard
		mailbox #(elec_layer_tr) elec_gen_mod; // connects stimulus generator to the reference model

		mailbox #(config_transaction) mb_stim_drv; // connects sequence to the driver
		mailbox #(config_transaction) config_mon_scr ; // connects monitor to the scoreboard
		mailbox #(config_transaction) config_model_scr; // connects reference model to the scoreboard
		mailbox #(config_transaction) config_stim_model; // connects stimulus generator to the reference model



		// NEW Function
		function new(input virtual upper_layer_if v_if, input virtual electrical_layer_if elec_v_if, input virtual config_space_if v_cif, input string scenario);
			this.v_if = v_if;
			this.elec_v_if = elec_v_if;
			this.v_cif = v_cif;
			this.scenario = scenario;
		endfunction : new


		// Build phase
		function void build();

			// mailbox Handles
			UL_gen_drv = new();
			UL_mon_scr = new();
			UL_mod_scr = new();
			UL_gen_mod = new();


			elec_gen_drv = new();
			elec_mon_scr = new();
			elec_mod_scr = new();
			elec_gen_mod = new();
			os_received_mon_gen = new();

			mb_stim_drv = new();
			config_mon_scr = new();
			config_model_scr = new();
			config_stim_model = new();

			// Reference model
			ref_model = new(config_stim_model, config_model_scr, elec_gen_mod, elec_mod_scr, UL_gen_mod, UL_mod_scr );

			// Agents
			agent_UL = new (v_if, UL_gen_drv, UL_mon_scr, UL_gen_drv_done);
			agent_elec = new (elec_v_if, elec_gen_drv, elec_mon_scr, elec_gen_drv_done);
			agent_config = new (v_cif, mb_stim_drv, config_mon_scr, config_gen_drv_done);
			agent_config.build();

			//Sequences
			elec_gen = new( elec_gen_mod, elec_gen_drv, os_received_mon_gen, elec_gen_drv_done, sbtx_high_received, elec_AT_cmd_received, elec_AT_rsp_received);
			config_gen = new (mb_stim_drv, config_stim_model, config_gen_drv_done, config_req_received);
			UL_gen = new(UL_gen_mod, UL_gen_drv, UL_gen_drv_done, cl0_s_raised);
			

			// Scoreboards
			UL_sb = new(UL_mon_scr, UL_mod_scr, cl0_s_raised);
			elec_sb = new(elec_mon_scr, elec_mod_scr, os_received_mon_gen, sbtx_high_received, elec_AT_cmd_received, elec_AT_rsp_received);
			sb_config = new(config_model_scr, config_mon_scr, config_req_received);

			// Virtual Sequence connections
			vseq_config = new();

			
			vseq_config.v_config_space_stim = config_gen; // configuration space Stimulus generator connection
			vseq_config.v_upper_layer_generator = UL_gen; // upper layer stimulus generator connection
			vseq_config.v_elec_layer_generator = elec_gen; // electrical layer stimulus generator connection

		endfunction : build

		// Agents' Run phase
		task run();
			fork



				// Upper layer run phase
				agent_UL.run();
				UL_sb.run();

				// Electrical layer run phase
				agent_elec.run();
				elec_sb.run();

				// configuration space run phase
				agent_config.run();
				sb_config.run();

				// Virtual Sequence run phase
				case (scenario)

					"normal_scenario_gen_4": vseq_config.run();
					"normal_scenario_gen_3": vseq_config.normal_scenario_gen_3();
					"normal_scenario_gen_2": vseq_config.normal_scenario_gen_2();


				endcase // scenario
				

				////////////////////////////////////////////////////////////////////////////////////////////////////////////
				// Reference model
				ref_model.run_phase();
				////////////////////////////////////////////////////////////////////////////////////////////////////////////
				


			join
		endtask : run

	endclass : Environment
