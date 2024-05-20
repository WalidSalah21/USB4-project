class ref_model extends primary_steps;
        phase1    phase_1;
        phase2    phase_2;
        phase3    phase_3;
        phase4    phase_4;
        phase5    phase_5;

        elec_layer_tr               E_transaction;
       // upper_layer_tr              UL_transaction;


  // Constructor
    function new( mailbox  #(config_transaction) config_ag_Rx , mailbox  #(config_transaction) config_ag_Tx ,mailbox   #(elec_layer_tr) elec_ag_Rx  
                            ,mailbox   #(elec_layer_tr) elec_ag_Tx , mailbox  #(upper_layer_tr) trans_ag_Rx , mailbox  #(upper_layer_tr) trans_ag_Tx);
        begin
        this.config_ag_Rx   = config_ag_Rx;
        this.config_ag_Tx   = config_ag_Tx;
        this.elec_ag_Tx = elec_ag_Tx;
        this.elec_ag_Rx = elec_ag_Rx;
        this.trans_ag_Rx= trans_ag_Rx;
        this.trans_ag_Tx = trans_ag_Tx;
        
        // initilize the internal agents
        int_ag = new();
        mem_ag = new();

        phase_1   = new(config_ag_Rx, elec_ag_Rx , elec_ag_Tx , config_ag_Tx , mem_ag , int_ag);
        phase_2   = new (elec_ag_Tx , config_ag_Rx , elec_ag_Rx   );
        phase_3   = new (elec_ag_Tx , elec_ag_Rx , mem_ag , int_ag , config_ag_Rx);
        phase_4   = new(elec_ag_Rx , elec_ag_Tx , mem_ag , config_ag_Rx);
        phase_5   = new(config_ag_Rx, elec_ag_Rx, elec_ag_Tx , trans_ag_Rx , trans_ag_Tx);

        end
    endfunction

    task  run_phase ( );
        forever
        begin
        elec_ag_Rx.peek(E_transaction);          // to know which phase without delete the content of mailbox

        // if(UL_transaction.phase == 5)
        //     begin
        //         //$display("\n before run 5");
        //         phase_5.run_phase5();
        //         //$display("after run 5 \n");
        //     end
           
        ////$display ("Run ref_model with phase = %d",E_transaction.phase);
        case (E_transaction.phase)
            3'd1:begin
                //$display("\n before run 1");
                phase_1.run_phase1 ();
                //$display("after run 1 \n");
            end  
            
            3'd2:begin
                //$display("\n before run 2");
                phase_2.run_phase2();
                //$display("after run 2 \n");
            end  
            
            3'd3:begin
                //$display("\n before run 3");
                phase_3.run_phase3();
                //$display("after run 3 \n");
            end  


            3'd4:begin      
                //$display("\n before run 4");
                phase_4.run_phase4();
                //$display("after run 4 \n");
            end  


            3'd5:begin
                //$display("\n before run 5");
                phase_5.run_phase5();
                //$display("after run 5 \n");
            end  

            default: phase_1.run_phase1 (); 

         endcase
        end
    endtask
    
endclass //ref_model


