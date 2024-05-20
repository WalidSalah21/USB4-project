//% this code generated by Ai "github cobilot" ^-^
class up_transport_generator;
    // Mailboxes for module and driver
    mailbox #(upper_layer_tr) ub_gen_mod;
    mailbox #(upper_layer_tr) ub_gen_drv;

    // Interface to the upper layer
    virtual upper_layer_if vif;

    // Event to signal when driving is done
    event drive_done;

    // Transaction object
    upper_layer_tr tr;

    // Constructor
    function new(mailbox mod, mailbox drv, event done ,virtual upper_layer_if vif);
        // Assign arguments to class members
        this.ub_gen_mod = mod;
        this.ub_gen_drv = drv;
        this.drive_done = done;
        this.vif = vif;
    endfunction

    // Task to generate stimuli
    task run( input int num);
        repeat (num) begin
            
            // Create a new transaction object
            tr = new();
            
            // Generate random variables for tr
            // Check if randomization was successful
            tr.randomize(T_Data) ;
            tr.randomize(T_Data_1) ;
            
            
            $display("[UPPER GENERATOR] data sent to lane 0: %0d", tr.T_Data);
            $display("[UPPER GENERATOR] data sent to lane 1: %0d", tr.T_Data_1);
            // Put the transaction into the mailboxes
            ub_gen_mod.put(tr);
            ub_gen_drv.put(tr);

            vif.enable_sending = 1'b1;

            // Wait for drive_done event to be triggered
            wait (drive_done.triggered);
        end

                // Disable sending
            vif.enable_sending = 1'b0;
    endtask


endclass