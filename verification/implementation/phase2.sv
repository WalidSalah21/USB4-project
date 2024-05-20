  class phase2 extends primary_steps ;

  mem         m_transaction;


    function new(mailbox #(elec_layer_tr) elec_ag_Tx, mailbox #(config_transaction) config_ag_Rx
                         , mailbox  #(elec_layer_tr)  elec_ag_Rx );
      this.elec_ag_Tx = elec_ag_Tx;
      this.elec_ag_Rx = elec_ag_Rx;
      this.config_ag_Rx = config_ag_Rx;
    endfunction

    task  get_transactions();
    ////$display ("in phase2 get_transactions");
    elec_ag_Rx.get(E_transaction); 
    //$display ("in phase 2 E_transaction = %p",E_transaction);
        
endtask



    task run_phase2();
      begin
        create_transactions();
     
        get_transactions();
        
        
        E_transaction.sbtx = 1;     // we can go throuhg phase 1 
        

        elec_ag_Tx.put(E_transaction);
        //$display ("E_transaction in phase 2 sent to scoreboard = %p",E_transaction);
        E_transaction = new();

      end
    endtask

  endclass

