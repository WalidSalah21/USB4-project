// ?  try to add include here 
import ref_model_pkg::*;
import elec_layer_tr_pkg::*;
import upper_layer_tr_pkg::*;
import config_space_pkg::*;

module testbench ();
    
parameter clk_cycle = 10 ;

    /*// clock genrator 
    initial begin
    clk = 0 ;

    forever begin
        #(clk_cycle/2) clk = ~clk;
    end
end*/
int i ;

// create the objects
config_transaction              C_transaction ;
elec_layer_tr                       E_transaction ;
upper_layer_tr                    T_transaction_Tx ;
upper_layer_tr                    T_transaction_Rx ;
ref_model                           ref_model_inst    ;


// create the mailboxes
mailbox  #(elec_layer_tr) elec_ag_Tx ;
mailbox  #(upper_layer_tr) trans_ag_Tx ;
mailbox  #(upper_layer_tr) trans_ag_Rx ;
mailbox  #(elec_layer_tr) elec_ag_Rx ;
mailbox  #(config_transaction) config_ag_Rx ;
mailbox  #(config_transaction) config_ag_Tx ;


// create rondom variables 
initial begin

    $dumpfile("testbench.vcd");
    $dumpvars(0,testbench);

    elec_ag_Tx    = new();
    trans_ag_Rx  = new();
    elec_ag_Rx   = new();  
    elec_ag_Rx    = new();
    config_ag_Rx = new();
    config_ag_Tx = new();

    ref_model_inst = new(config_ag_Rx , config_ag_Tx , elec_ag_Rx , elec_ag_Tx , trans_ag_Rx,trans_ag_Tx );

    C_transaction = new();
    C_transaction = new();
    E_transaction = new();
    T_transaction_Rx = new();
    T_transaction_Tx = new();


    $display("Start of Test");
   for ( i=0 ;i<2 ; i++) 
 begin   

     $display("\n \n _____________ start putting from ref_model_inst -------------- \n \n ");
            // randomize the transaction
            assert (C_transaction.randomize())  ;
            assert (E_transaction.randomize())  ;
            assert (T_transaction_Rx.randomize())  ;
           //* if((i%4)>0) $cast (E_transaction.o_sets,(TS1_gen4+(i%4 )-1) );        for phase 4
           //*  else if (i>0) E_transaction.o_sets=TS4 ;   fot phase 4  
            E_transaction.phase = 5 ;//i%5 +1;        // to make sure that the phase is [1->5]
            E_transaction.sbrx = 1 ;
            $display("C_transaction = %p",C_transaction);
            $display("E_transaction = %p",E_transaction);
            $display("T_transaction_Rx = %p",T_transaction_Rx);


            // ------------------------send the transaction to the reference model
            if (E_transaction.phase == 1) begin
                elec_ag_Rx.put(E_transaction);
                config_ag_Rx.put(C_transaction);
                #clk_cycle;
            end
            else if (E_transaction.phase == 2) begin
                $display("we are in phase 2 in testbech");
                elec_ag_Rx.put(E_transaction);
                #clk_cycle;
            end
            else if (E_transaction.phase == 3) begin
                elec_ag_Rx.put(E_transaction);
                config_ag_Rx.put(C_transaction);
                #clk_cycle;
            end
            else if (E_transaction.phase == 4) begin  
                elec_ag_Rx.put(E_transaction);
                config_ag_Rx.put(C_transaction);
                E_transaction = new();    // for not make all handels point to one object
                #clk_cycle;
            end
            else if (E_transaction.phase == 5) begin  
                config_ag_Rx.put(C_transaction);
                elec_ag_Rx.put(E_transaction);
                trans_ag_Rx.put(T_transaction_Rx);
                #clk_cycle;
            end
            
            #clk_cycle;
            
            
            
            
            
            
            $display(" _______________ Get from ref_model  -------------- ");
            // ------------------------get the transaction from the reference model
            if (E_transaction.phase == 1) begin
                elec_ag_Tx.get(E_transaction);
                $display("E_transaction = %p",E_transaction);         // get value of  sptx = 0 . before phase 1
                //elec_ag_Tx.get(E_transaction);
                config_ag_Tx.get(C_transaction);
                $display("C_transaction = %p",C_transaction);
                //$display("E_transaction = %p",E_transaction);         // get value of  sptx in phase 1 
            end
            
            else if (E_transaction.phase == 2) begin
                elec_ag_Tx.get(E_transaction);
                $display("E_transaction = %p",E_transaction);  
            end
            
            else if (E_transaction.phase == 3) begin
                $display("we are in phase 3 in testbech");
                elec_ag_Tx.get(E_transaction);  
                $display("E_transaction = %p",E_transaction);  
            end

            else if (E_transaction.phase == 4) begin
                elec_ag_Tx.get(E_transaction);
                $display("E_transaction = %p",E_transaction);  
            end

            else if (E_transaction.phase == 5) begin
                elec_ag_Tx.get(E_transaction);
                $display("E_transaction = %p",E_transaction);  
                trans_ag_Tx.try_get(T_transaction_Tx);
                $display(" T_transaction_Tx = %p",T_transaction_Tx);
            end

        
            #clk_cycle;

            $display(" \n \n//////////////////////////////////////");
            $display("//////////////////////////////////////");
            $display("//////////////////////////////////////");
            $display("  ⁂⁂⁂⁂⁂⁂ ------ rep %0d done ---- ⁂⁂⁂⁂⁂⁂  ",i+1) ;
            $display("//////////////////////////////////////");
            $display("//////////////////////////////////////\n \n");
            
    end

   
    #(50*clk_cycle);
    $stop;
end

initial begin
    

        ref_model_inst.run_phase();     // run the phase
    end


endmodule 



2 3 5