class electrical_layer_generator;

    // Declare events
    event elec_gen_driver_done;
    event correct_OS;       // New event

    // Declare transactions
    elec_layer_tr transaction;

    env_cfg_class env_cfg_mem;

    // Declare mailboxes of type elec_layer_tr
    mailbox #(elec_layer_tr) elec_gen_drv,
                             elec_gen_mod,
                             elec_gen_2_scoreboard; 

    // Constructor
    function new(event elec_gen_driver_done, correct_OS,mailbox #(elec_layer_tr) elec_gen_drv,elec_gen_mod ,elec_gen_2_scoreboard,env_cfg_class env_cfg_mem);
      //this.sbrx_transition_high = sbrx_transition_high;
      this.elec_gen_driver_done = elec_gen_driver_done;
      //this.sbtx_transition_high = sbtx_transition_high;
      this.correct_OS = correct_OS; // Assign the correct_OS event
      this.elec_gen_drv = elec_gen_drv;
      this.elec_gen_mod = elec_gen_mod;
      this.env_cfg_mem  = env_cfg_mem;
      this.elec_gen_2_scoreboard = elec_gen_2_scoreboard; // Assign the elec_gen_2_scoreboard mailbox
    endfunction

    // Declare the task as extern
    extern task sbrx_after_sbtx_high();
    extern task send_transaction_2_driver(input tr_type trans_type = None, input bit read_write = 0,input bit [7:0] address = 0,
                                          input bit [6:0] len = 0, input bit [23:0] cmd_rsp_data = 0,input GEN generation = gen4);
    extern task Send_OS(input OS_type OS, input GEN generation);
    extern task send_data(input logic [7:0] data, input GEN gen_speed,input LANE lane);
    extern task wake_up(input bit [2:0] phase, input GEN speed = gen4);
    extern task Disconnect();



    //--------for test model only -----------//
    
    // Declare the task as extern
    extern task sbrx_after_sbtx_high_m();
    extern task send_transaction_2_driver_m(input tr_type trans_type = None, input bit read_write = 0,input bit [7:0] address = 0,
                                          input bit [6:0] len = 0, input bit [23:0] cmd_rsp_data = 0,input GEN generation = gen4);
    extern task Send_OS_m(input OS_type OS, input GEN generation);
    extern task send_data_m(input logic [7:0] data, input GEN gen_speed,input LANE lane);
    extern task Disconnect_m();
  endclass : electrical_layer_generator


         /////*** Define the task outside the class***/////

   task electrical_layer_generator::sbrx_after_sbtx_high();
    wait(env_cfg_mem.ready_phase2 ==2) // Blocking with the event sbtx_transition_high (do it on sequance)
    env_cfg_mem.ready_phase2=0;
    //$display("[ELEC GENERATOR] : sbtx is high");
    transaction = new();                    // Construct the transaction
    transaction.sbrx = 1'b1;                // Set transaction.sbrx to 1'b1
    transaction.phase = 3'd2;               // Set transaction.phase to 3'd2
    elec_gen_drv.put(transaction);          // Put the transaction on the elec_gen_drv mailbox
    elec_gen_mod.put(transaction);          // Put the transaction on the elec_gen_mod mailbox
    elec_gen_2_scoreboard.put(transaction); // Put the transaction on the elec_gen_2_scoreboard mailbox
    $display("[ELEC GENERATOR] : sbrx send high");
     @(elec_gen_driver_done);               // Blocking with the event elec_gen_driver_done
    $display("[ELEC GENERATOR] : SENDING SBRX  high IS SUCCESSFUL");
   endtask


    // Transaction methods
    task electrical_layer_generator::send_transaction_2_driver(input tr_type trans_type = None, input bit read_write = 0, input bit [7:0] address = 0,
                                                      input bit [6:0] len = 0, input bit [23:0] cmd_rsp_data = 0, input GEN generation = gen4);
      transaction = new(); // Instantiate the transaction object using the default constructor
      transaction.phase ='d3;
      transaction.transaction_type = trans_type;
      transaction.tr_os = tr;
      transaction.sbrx = 1;
      transaction.gen_speed = generation;
      case(trans_type)
        AT_cmd, AT_rsp: begin
          transaction.read_write = read_write;
          transaction.address = address;
          transaction.len = len;
          transaction.cmd_rsp_data = cmd_rsp_data;
          $display("[ELEC GENERATOR] sending [%p] Transaction", trans_type);
        end
        LT_fall: begin
          //transaction.sbrx = 0;  knew it from trans_type
          $display("[ELEC GENERATOR] sending [LT_FALL] Transaction");
        end
      endcase

      elec_gen_drv.put(transaction);       // Sending transaction to the Driver
      elec_gen_mod.put(transaction);       // Sending transaction to the Reference model
      elec_gen_2_scoreboard.put(transaction); // Put the transaction on the elec_gen_2_scoreboard mailbox
      @(elec_gen_driver_done);
      $display("at time(%0t)[ELEC GENERATOR] SUCCESSFULLY SENT ******>>>> [%p]",$time,trans_type);
    endtask

     //task to send ordered sets
    task electrical_layer_generator::Send_OS(input OS_type OS, input GEN generation);
      $display("[ELEC GENERATOR] waiting for correct recieved order_sets from type [%p] ", OS);
      wait(env_cfg_mem.correct_OS ==1); // Blocking with the correct_OS event "this event on sboard"
      env_cfg_mem.correct_OS =0;
      $display("[ELEC GENERATOR] correct recieved order_sets from type [%p] ", OS);
      
      repeat (1) begin        
        transaction = new();                 // Instantiate a new transaction object
        transaction.o_sets = OS;             // type of the ordered set
        transaction.tr_os = ord_set;         // indicates whether the driver will send transaction or ordered set
        transaction.gen_speed = generation;  // to indicate the generation
        transaction.sbrx = 1;
	    	transaction.phase ='d4;
        elec_gen_drv.put(transaction);        // Sending transaction to the Driver
        elec_gen_mod.put(transaction);        // Sending transaction to the Reference model
         elec_gen_2_scoreboard.put(transaction); // Put the transaction on the elec_gen_2_scoreboard mailbox
        $display("[ELEC GENERATOR] SENDING [%p]", OS);
        @(elec_gen_driver_done);               // To wait for the driver to finish driving the data
        $display("[ELEC GENERATOR] [%p] SENT SUCCESSFULLY ", OS);
        
      end
    endtask

    
    
    task electrical_layer_generator::send_data(input logic [7:0] data, input GEN gen_speed,input LANE lane);  //discuss on the width of the input data later
      transaction = new();                     // Instantiate the transaction object using the default constructor
      transaction.sbrx = 1;
      transaction.phase = 3'd5;                //not real phase but for env only
      transaction.lane = lane;
      transaction.gen_speed = gen_speed;
      transaction.electrical_to_transport = data;
      elec_gen_drv.put(transaction);           // Sending transaction to the Driver
      elec_gen_mod.put(transaction);           // Sending transaction to the Reference model
       elec_gen_2_scoreboard.put(transaction); // Put the transaction on the elec_gen_2_scoreboard mailbox
      @(elec_gen_driver_done);
      $display("[ELEC GENERATOR] data sent SUCCESSFULLY");
      endtask

  
      task electrical_layer_generator::Disconnect();
      transaction = new();                     // Instantiate the transaction object using the default constructor
      transaction.sbrx = 0;
      transaction.phase = 3'd6;                //not real phase but for env only
      elec_gen_drv.put(transaction);           // Sending transaction to the Driver
      elec_gen_mod.put(transaction);           // Sending transaction to the Reference model
      elec_gen_2_scoreboard.put(transaction);  // Put the transaction on the elec_gen_2_scoreboard mailbox
      @(elec_gen_driver_done);
      $display("[ELEC GENERATOR] Disconnect order sent to driver");
      endtask
  


      task  electrical_layer_generator::wake_up(input bit [2:0] phase, input GEN speed = gen4);
      transaction = new();                     // Instantiate the transaction object using the default constructor
      transaction.sbrx = 1;
      transaction.phase = phase;                //not real phase but for env only
		  transaction.gen_speed = speed;
      elec_gen_mod.put(transaction);           // Sending transaction to the Driver
    endtask




    //--------------------------------------//
    //--------------------------------------//
    //--------------------------------------//
    //--------------------------------------//
    //-----------for test model only -----------//
    //--------------------------------------//
    //--------------------------------------//
    //--------------------------------------//
  



    
   task electrical_layer_generator::sbrx_after_sbtx_high_m();
   // @(sbtx_transition_high); // Blocking with the event sbtx_transition_high (do it on sequance)
    //$display("[ELEC GENERATOR] : sbtx is high");
    transaction = new();                    // Construct the transaction
    transaction.sbrx = 1'b1;                // Set transaction.sbrx to 1'b1
    transaction.phase = 3'd2;               // Set transaction.phase to 3'd2
    elec_gen_mod.put(transaction);          // Put the transaction on the elec_gen_mod mailbox
    elec_gen_2_scoreboard.put(transaction); // Put the transaction on the elec_gen_2_scoreboard mailbox
    $display("[ELEC GENERATOR] : sbrx send high");
   endtask



     //task to send ordered sets
    task electrical_layer_generator::Send_OS_m(input OS_type OS, input GEN generation);
      //$display("[ELEC GENERATOR] waiting for correct recieved order_sets from type [%p] ", OS);
      @correct_OS; // Blocking with the correct_OS event "this event on sboard"
      $display("[ELEC GENERATOR] correct recieved order_sets from type [%p] ", OS);
      
      repeat (1) begin        
        transaction = new();                 // Instantiate a new transaction object
        transaction.o_sets = OS;             // type of the ordered set
        transaction.tr_os = ord_set;         // indicates whether the driver will send transaction or ordered set
        transaction.gen_speed = generation;  // to indicate the generation
        transaction.sbrx = 1;
	    	transaction.phase ='d4;
        elec_gen_mod.put(transaction);        // Sending transaction to the Reference model
         elec_gen_2_scoreboard.put(transaction); // Put the transaction on the elec_gen_2_scoreboard mailbox
        $display("[ELEC GENERATOR] SENDING [%p]", OS);
      end
    endtask

    task electrical_layer_generator::send_transaction_2_driver_m(input tr_type trans_type = None, input bit read_write = 0, input bit [7:0] address = 0,
                                                      input bit [6:0] len = 0, input bit [23:0] cmd_rsp_data = 0, input GEN generation = gen4);
      transaction = new(); // Instantiate the transaction object using the default constructor
      transaction.phase ='d3;
      transaction.transaction_type = trans_type;
      transaction.tr_os = tr;
      transaction.sbrx = 1;
      transaction.gen_speed = generation;
      case(trans_type)
        AT_cmd, AT_rsp: begin
          transaction.read_write = read_write;
          transaction.address = address;
          transaction.len = len;
          transaction.cmd_rsp_data = cmd_rsp_data;
          $display("[ELEC GENERATOR] sending [%p] Transaction", trans_type);
        end
        LT_fall: begin
          //transaction.sbrx = 0;  knew it from trans_type
          $display("[ELEC GENERATOR] sending [LT_FALL] Transaction");
        end
      endcase

      elec_gen_mod.put(transaction);       // Sending transaction to the Reference model
      elec_gen_2_scoreboard.put(transaction); // Put the transaction on the elec_gen_2_scoreboard mailbox
    endtask

    
    
    task electrical_layer_generator::send_data_m(input logic [7:0] data, input GEN gen_speed,input LANE lane);  //discuss on the width of the input data later
      transaction = new();                     // Instantiate the transaction object using the default constructor
      transaction.sbrx = 1;
      transaction.phase = 3'd5;                //not real phase but for env only
      transaction.lane = lane;
      transaction.gen_speed = gen_speed;
      transaction.electrical_to_transport = data;
      elec_gen_mod.put(transaction);           // Sending transaction to the Reference model
       elec_gen_2_scoreboard.put(transaction); // Put the transaction on the elec_gen_2_scoreboard mailbox
      $display("[ELEC GENERATOR] data sent SUCCESSFULLY");
      endtask

  
      task electrical_layer_generator::Disconnect_m();
      transaction = new();                     // Instantiate the transaction object using the default constructor
      transaction.sbrx = 0;
      transaction.phase = 3'd6;                //not real phase but for env only
      elec_gen_mod.put(transaction);           // Sending transaction to the Reference model
      elec_gen_2_scoreboard.put(transaction);  // Put the transaction on the elec_gen_2_scoreboard mailbox
      $display("[ELEC GENERATOR] Disconnect order sent to driver");
      endtask
  





// End of file

/*
module test_electrical_layer_generator;

  import electrical_layer_transaction_pkg::*;
  import electrical_layer_generator_pkg::*;
  
  // Declare events
  event sbrx_transition_high;
  event elec_gen_driver_done;
  event sbtx_transition_high;
  event correct_OS;

  // Declare mailboxes
  mailbox #(elec_layer_tr) elec_gen_drv = new();
  mailbox #(elec_layer_tr) elec_gen_mod = new();

  // Instantiate the electrical_layer_generator
  electrical_layer_generator elec_gen = new(sbrx_transition_high, elec_gen_driver_done, sbtx_transition_high, correct_OS, elec_gen_drv, elec_gen_mod);

    // Call the tasks to test the class
elec_layer_tr received_transaction;

initial begin
  
  fork
  elec_gen.sbrx_after_sbtx_high();
  -> sbtx_transition_high; // To unblock the sbrx_after_sbtx_high task
  begin
  elec_gen_drv.get(received_transaction);
  ->elec_gen_driver_done;  // To unblock the sbrx_after_sbtx_high task
  $display("[TEST MODULE] Received transaction from elec_gen_drv: %p", received_transaction);
  end
  join


fork
  elec_gen.send_transaction(AT_cmd, 3, 0, 32'h0, 32'h0, 32'h0);
  begin
  elec_gen_drv.get(received_transaction);
  $display("[TEST MODULE] Received transaction from elec_gen_drv: %p", received_transaction);
  end
  ->elec_gen_driver_done; // To unblock send_transaction task
join

fork
  elec_gen.Send_OS(OS_type'("OS"), GEN'("gen1"));
  ->correct_OS; // To unblock the Send_OS task
  begin
  elec_gen_drv.get(received_transaction);
  ->elec_gen_driver_done; // To unblock the Send_OS task
  $display("[TEST MODULE] Received transaction from elec_gen_drv: %p", received_transaction);
  end
join

fork
  elec_gen.send_data(10'd99);
  begin
  elec_gen_drv.get(received_transaction);
  ->elec_gen_driver_done; // To unblock the send_data task
  $display("[TEST MODULE] Received transaction from elec_gen_drv: %p", received_transaction);
  end
  
join
  
end

endmodule*/