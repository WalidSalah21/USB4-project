class upper_ref_AI;

  // Instances of the classes
  elec_layer_tr elec_layer_tr_inst;
  upper_layer_tr upper_layer_tr_inst;

  // Mailboxes
  mailbox #(upper_layer_tr) upper_S;
  mailbox #(upper_layer_tr) upper_G;
  mailbox #(upper_layer_tr) upper_to_elec;
  mailbox #(elec_layer_tr) elec_to_upper;

  // Constructor
  function new(mailbox #(upper_layer_tr) upper_S, mailbox #(upper_layer_tr) upper_G, mailbox #(upper_layer_tr) upper_to_elec, mailbox #(elec_layer_tr) elec_to_upper);
    this.upper_S = upper_S;
    this.upper_G = upper_G;
    this.upper_to_elec = upper_to_elec;
    this.elec_to_upper = elec_to_upper;
  endfunction

  // Task run
  task run;
        fork
        // Thread 1
        
            begin : thread1
                forever 
                begin
                    upper_layer_tr_inst = new(); // New instance at the beginning of each loop
                    upper_G.get(upper_layer_tr_inst); // Get operation before the if condition
                    //$display("DATA OBTAINED from transport layer");
                    //$display("T_DATA = %0D, phase = %0D",upper_layer_tr_inst.T_Data, upper_layer_tr_inst.phase);
                    if (upper_layer_tr_inst.phase == 5) 
                    begin
                        upper_to_elec.put(upper_layer_tr_inst); // Put operation inside the if condition
                    end
                end
            end

        // Thread 2
            
            begin : thread2
                forever 
                begin
                    elec_layer_tr_inst = new(); // New instance at the beginning of each loop
                    upper_layer_tr_inst = new(); // New instance of upper_layer_tr at the beginning of each loop
                    elec_to_upper.get(elec_layer_tr_inst); // Get operation before the if condition
                    if (elec_layer_tr_inst.phase == 5) 
                    begin
                        upper_layer_tr_inst.T_Data = elec_layer_tr_inst.electrical_to_transport;
                        upper_S.put(upper_layer_tr_inst); // Put operation inside the if condition
                    end
                end
            end
        join_any
  endtask

endclass