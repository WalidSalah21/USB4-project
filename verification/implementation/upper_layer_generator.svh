	class upper_layer_generator;


		// Event Signals
		event UL_gen_drv_done;
		event cl0_s_raised;

		//Transaction
		upper_layer_tr UL_tr;

		// Mailboxes
		mailbox #(upper_layer_tr) UL_gen_mod; // connects stimulus generator to the reference model
		mailbox #(upper_layer_tr) UL_gen_drv; // connects Stimulus generator to the driver inside the agent

		function new(mailbox #(upper_layer_tr) UL_gen_mod, mailbox #(upper_layer_tr) UL_gen_drv, event UL_gen_drv_done, cl0_s_raised);

			// Mailbox connections between generator and agent
			this.UL_gen_mod = UL_gen_mod;
			this.UL_gen_drv = UL_gen_drv;

			// Event Signals Connections
			this.UL_gen_drv_done = UL_gen_drv_done;
			this.cl0_s_raised = cl0_s_raised;

			//UL_tr handle
			UL_tr = new();
				
		endfunction : new
		

		task send_transport_data(input GEN gen_speed);
		
			//////////////////////////////////////////////////
			////////////////INPUT RANDOMIZATION //////////////
			//////////////////////////////////////////////////

			UL_tr = new() ;

			assert(UL_tr.randomize);
			UL_tr.gen_speed = gen_speed;
			UL_tr.phase = 5;
			UL_tr.send_to_elec_enable = 1;
			UL_tr.enable_receive = 0;


			//////////////////////////////////////////////////
			////////////////DRIVER ASSIGNMENT/////////////////
			//////////////////////////////////////////////////

			UL_gen_mod.put(UL_tr); // Sending transaction to the Reference Model
			UL_gen_drv.put(UL_tr); // Sending transaction to the Driver

			@ (UL_gen_drv_done); // waiting for event triggering from driver
			
			$display("[UL Generator] Transaction is sent successfully to the DUT");

			


		endtask : send_transport_data


		task start_receiving (input GEN gen_speed);

			UL_tr = new();

			UL_tr.enable_receive = 1;
			UL_tr.send_to_elec_enable = 0;
			UL_tr.gen_speed = gen_speed;
			UL_tr.phase = 5;


			UL_gen_drv.put(UL_tr); // Sending transaction to the Driver
			//UL_gen_mod.put(UL_tr); // Sending transaction to the Reference Model

			@ (UL_gen_drv_done); // waiting for event triggering from driver

			$display("[UL Generator] Monitor is enabled");

			

		endtask : start_receiving


		task disable_monitor(input GEN speed = gen4);
			
			UL_tr = new();

			UL_tr.enable_receive = 0;
			UL_tr.send_to_elec_enable = 0;
			UL_tr.phase = 5;
			UL_tr.gen_speed = speed; 



			UL_gen_drv.put(UL_tr); // Sending transaction to the Driver

			@ (UL_gen_drv_done); // waiting for event triggering from driver


		endtask : disable_monitor

		task generation_assignment (input GEN speed = gen4);

			UL_tr = new();

			UL_tr.enable_receive = 0;
			UL_tr.send_to_elec_enable = 0;
			UL_tr.phase = 5;
			//UL_tr.x = 1;

			UL_tr.gen_speed = speed ; 
			
			UL_gen_drv.put(UL_tr); // Sending transaction to the Driver 

			@ (UL_gen_drv_done); // waiting for event triggering from driver
			$display("[UL Generator] Generation assignment done");

		
	endtask //phase_force

	task wait_phase_5 (input GEN speed = gen4);
		
		UL_tr.enable_receive = 0;
		UL_tr.send_to_elec_enable = 0;
		UL_tr.wait_for_cl0s = 1;
		UL_tr.phase = 5;

		UL_tr.gen_speed = speed ; 

		UL_gen_drv.put(UL_tr); // Sending transaction to the Driver 

		@ (UL_gen_drv_done); // waiting for event triggering from driver

		$display("[UL Generator] Waiting for cl0_s to be raised");

		@(cl0_s_raised);

		$display("[UL Generator] Starting to send data on the transport layer at: %t", $time);


	endtask : wait_phase_5



		
	endclass : upper_layer_generator
