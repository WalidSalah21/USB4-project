class TEST;
    // Declare the components
    env environment;
    virtual electrical_layer_if ELEC_vif;
    virtual config_space_if CFG_if;
    virtual upper_layer_if UP_if;

    // Declare the constructor
    function new(virtual electrical_layer_if ELEC_vif,virtual config_space_if cfg_if,virtual upper_layer_if up_if);
        this.ELEC_vif = ELEC_vif;
        this.CFG_if = cfg_if;
        this.UP_if = up_if;

        // Initialize the environment
        this.environment = new(ELEC_vif, cfg_if, up_if);
    endfunction

    task run(input GEN speed);
        // Call the run task on the environment
        environment.run(speed);
    endtask
endclass

