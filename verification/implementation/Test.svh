
class Test;

	//interfaces
	virtual upper_layer_if upp_v_if;
	virtual electrical_layer_if elec_v_if;
	virtual config_space_if config_v_if;

	string scenario;

	function new(input virtual upper_layer_if upp_v_if, input virtual electrical_layer_if elec_v_if, input virtual config_space_if config_v_if);
		
		this.upp_v_if = upp_v_if;
		this.elec_v_if = elec_v_if;
		this.config_v_if = config_v_if;

	endfunction : new


	task run (input string scenario);

		Environment t_env;

		t_env = new(upp_v_if, elec_v_if, config_v_if, scenario);
		
		t_env.build();

		t_env.run();


	endtask : run




endclass : Test
