
class primary_steps;
    mailbox  #(elec_layer_tr) elec_ag_Tx ;
    mailbox  #(upper_layer_tr) trans_ag_Tx ;
    mailbox  #(upper_layer_tr) trans_ag_Rx ;
    mailbox  #(elec_layer_tr) elec_ag_Rx ;
    mailbox  #(config_transaction) config_ag_Rx ;
    mailbox  #(config_transaction) config_ag_Tx ;

    mailbox #(mem)    mem_ag ;      // internal memory agent
    mailbox #(int_packet) int_ag ;   // internal int_packet agent


   


 
   config_transaction              C_transaction ;
   elec_layer_tr                       E_transaction ;
   upper_layer_tr                    T_transaction_Tx ;
   upper_layer_tr                    T_transaction_Rx ;
   extentions                          extention ; 

       // task to create new transactions
 virtual  task  create_transactions();
   C_transaction     = new();
   E_transaction      = new();
   T_transaction_Rx = new();
   T_transaction_Tx = new();

   //extention = new();
 endtask
endclass //primary_steps

