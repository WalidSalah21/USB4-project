interface upper_layer_if(input clk,
	
	input gen2_fsm_clk, 
	input gen3_fsm_clk,
	input gen4_fsm_clk,
 	input logic reset);

	//upper layer inputs signals
	logic [7:0] transport_layer_data_in;
	logic cl0_s;
	
	//upper layer Output signals
	logic [7:0] transport_layer_data_out;
	logic transport_data_flag;

	GEN generation_speed;
	logic [2:0] phase; 

	bit enable_monitor; // signal sent by the driver to enable the monitor to receive data from transport_layer_data_out
	bit wait_cl0_s;


	bit [1:0] clk_cycles_counter;


	initial
	begin
		clk_cycles_counter = 2; 

		wait(cl0_s == 1);
		//@(negedge gen4_fsm_clk);
		clk_cycles_counter = 0;

		forever
		begin
			wait_negedge(generation_speed);
			//@(negedge gen4_fsm_clk);
			clk_cycles_counter++;
		end
		
	end

	task wait_negedge (input GEN generation);
			if (generation == gen2)
			begin
				@(negedge gen2_fsm_clk);
			end
			else if (generation == gen3)
			begin
				@(negedge gen3_fsm_clk);
			end
			else if (generation == gen4)
			begin
				@(negedge gen4_fsm_clk);
			end
			else
			begin
				$error("Unsupported Gen in upper_layer_if");
			end
		endtask


endinterface: upper_layer_if


