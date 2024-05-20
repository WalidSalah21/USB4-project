
class phase5 extends primary_steps ;

  // Constructor
function new(mailbox #(config_transaction) config_ag_Rx, mailbox #(elec_layer_tr) elec_ag_Rx
                    , mailbox #(elec_layer_tr) elec_ag_Tx , mailbox #(upper_layer_tr) trans_ag_Rx , mailbox #(upper_layer_tr) trans_ag_Tx );
this.config_ag_Rx = config_ag_Rx;
this.elec_ag_Tx = elec_ag_Tx;
this.elec_ag_Rx = elec_ag_Rx;
this.trans_ag_Rx = trans_ag_Rx ;
this.trans_ag_Tx  = trans_ag_Tx ;
endfunction


task elec_to_trans ;
    if (E_transaction.phase == 5) begin
        // get the data from electrical agent
        elec_ag_Rx.get (E_transaction); 
        //$display ("in phase5 E_transaction = %p",E_transaction);

        // send the data to transport agent
        T_transaction_Tx.T_Data = E_transaction.electrical_to_transport[7:0] ;
        //$display(" first T_transaction_Tx = %p" ,T_transaction_Tx);
        trans_ag_Tx.put(T_transaction_Tx);  
        T_transaction_Tx =new();      

        T_transaction_Tx.T_Data = E_transaction.electrical_to_transport[15:8] ;
        //$display(" second T_transaction_Tx = %p" ,T_transaction_Tx);
        trans_ag_Tx.put(T_transaction_Tx);  
        T_transaction_Tx =new();      
    end
    //////$display ("done elec_to_trans");
endtask //elec_to_trans

task trans_to_elec ;
if (E_transaction.phase == 5) begin

    // get the data from transport agent
    trans_ag_Rx.get(T_transaction_Rx);
    //$display ("in phase5 T_transaction_Rx = %p",T_transaction_Rx);

    // send the data to electrical agent
    E_transaction.transport_to_electrical = T_transaction_Rx.T_Data ;
    E_transaction.lane = lane_0 ;
    //$display(" first E_transaction = %p" ,E_transaction);
    elec_ag_Tx.put(E_transaction);
    E_transaction = new();

    E_transaction.transport_to_electrical = T_transaction_Rx.T_Data_1 ;
    E_transaction.lane = lane_1 ;
    //$display(" second E_transaction = %p" ,E_transaction);
    elec_ag_Tx.put(E_transaction);
    E_transaction = new();

end
//////$display ("done trans_  to_elec");

endtask //trans_to_elec



// Task to execute the phase
task run_phase5();
    begin 
    create_transactions();
    ////$display("create transactions done");

    // get the data from config agent
    config_ag_Rx.try_get(C_transaction);
    //$display ("in phase5 C_transaction = %p",C_transaction);
    
    // peel the data from electrical agent
    elec_ag_Rx.peek (E_transaction); 
    //$display ("in phase5 E_transaction = %p",E_transaction);
    

                       // ----------------------- handle actions ----------------------
            if(!E_transaction.sbrx)      
            begin
             // E_transaction.phase = 1;         //! should we go to phase 1 or 2 
                //$display ("we are in sbrx =0 case action");
              E_transaction.sbtx = 0;         
              elec_ag_Tx.put(E_transaction) ;
                    E_transaction = new();

            end
            else if (C_transaction.lane_disable && (E_transaction.phase == 5) ) 
            begin       
                //$display ("we are in disable case action");
               E_transaction.sbtx  = 0;
               elec_ag_Tx.put(E_transaction) ;
                                   E_transaction = new();

             end
             else if (E_transaction.transaction_type==3'b001 && E_transaction.phase == 5)    // L_T fall  come
             begin
                //$display ("we are in LT_fall case action");
                E_transaction.sbtx = 1;         
                elec_ag_Tx.put(E_transaction) ;
                E_transaction = new();

             end
         
         
                // ----------------------- run main task ----------------------

    else
    fork
        elec_to_trans ();
        trans_to_elec ();
    join_any

 end
endtask   //get_data


endclass //phase5
