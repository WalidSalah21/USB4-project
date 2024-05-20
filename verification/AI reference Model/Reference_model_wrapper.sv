class reference_model_AI;

  // Instances of classes
  /*
  upper_layer_tr upper_layer_tr_inst;
  elec_layer_tr elec_layer_tr_inst;
  config_transaction config_transaction_inst;
  */

  // Mailboxes
  mailbox #(upper_layer_tr) upper_S;
  mailbox #(upper_layer_tr) upper_G;

  mailbox #(elec_layer_tr) elec_S;
  mailbox #(elec_layer_tr) elec_G;
  
  mailbox #(config_transaction) config_S;
  mailbox #(config_transaction) config_G;

  mailbox #(upper_layer_tr) upper_to_elec;
  mailbox #(elec_layer_tr) elec_to_upper;

  mailbox config_to_elec_disable;  
  mailbox config_to_upper_disable;      

  // Instances of upper_ref_AI and elec_ref_AI
  upper_ref_AI upper_ref_AI_inst;
  elec_ref_AI elec_ref_AI_inst;
  ConfigurationSpacesModel config_ref_AI_inst;

  // Constructor
  function new(mailbox #(upper_layer_tr) upper_S, mailbox #(upper_layer_tr) upper_G, mailbox #(elec_layer_tr) elec_S, mailbox #(elec_layer_tr) elec_G, mailbox #(config_transaction) config_S, mailbox #(config_transaction) config_G);

    this.upper_S = upper_S;
    this.upper_G = upper_G;

    this.elec_S = elec_S;
    this.elec_G = elec_G;
    
    this.config_S = config_S;
    this.config_G = config_G;

    // Create internal communication mailboxes
    upper_to_elec = new();
    elec_to_upper = new();

    // Create instances of upper_ref_AI and elec_ref_AI
    upper_ref_AI_inst = new(upper_S, upper_G, upper_to_elec, elec_to_upper);
    elec_ref_AI_inst = new(elec_S, elec_G, elec_to_upper, upper_to_elec);
    config_ref_AI_inst = new(config_G, config_S, config_to_elec_disable, config_to_upper_disable);

    //function new(mailbox #(config_transaction) stimulus_mb, mailbox #(config_transaction) scoreboard_mb, mailbox electrical_mb, mailbox upper_mb);



  endfunction

  // Task run
  task run;
    fork
      config_ref_AI_inst.run();
      upper_ref_AI_inst.run();
      elec_ref_AI_inst.run();
    join
  endtask

endclass