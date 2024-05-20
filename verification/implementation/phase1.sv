class phase1 extends primary_steps;

   mem         m_transaction;
   int_packet i_transaction ;
   mailbox #(int_packet) int_ag ;
   mailbox #(mem)    mem_ag   ;      // internal memory agent


  // Constructor
  function new(mailbox #(config_transaction) config_ag_Rx, mailbox #(elec_layer_tr) elec_ag_Rx, mailbox #(elec_layer_tr) elec_ag_Tx 
                      , mailbox  #(config_transaction) config_ag_Tx , mailbox #(mem) mem_ag , mailbox #(int_packet) int_ag);

    this.config_ag_Tx   = config_ag_Tx;
    this.config_ag_Rx = config_ag_Rx;
    this.elec_ag_Tx = elec_ag_Tx;
    this.elec_ag_Rx = elec_ag_Rx;
    this.mem_ag = mem_ag;
    //this.int_ag = int_ag;


    // link with the extentions agent class
    
      i_transaction = new();
      
      
    endfunction

    
    
    // Task to send sb data
    task read_order1;
    begin
      C_transaction.c_address = 8'd18;   
      C_transaction.c_write = 0 ;   
      C_transaction.c_read = 1;   
      C_transaction.c_data_out=0;
      config_ag_Tx.put(C_transaction) ;    // this should go to scoreboard "read case "
      C_transaction = new ();
      //E_transaction.sbtx = 0 ;        //? is that should be here 
      //elec_ag_Tx.put(E_transaction);
      //$display ("E_transaction = %p",E_transaction);
      //$display ("E_transaction = %p",E_transactio//n);
      

     // assign_sb_data();
    end
  endtask

  // task to get packets
  task  get_packets();
    begin
      config_ag_Rx.get(C_transaction);
      $display ("in phase 1 got C_transaction = %p",C_transaction);
      elec_ag_Rx.get(E_transaction);  // we should get here since i do peek in the ref model the handle will not be deleted if not so 
      //elec_ag_Rx.get(E_transaction);
      //$display ("done get_packet");
    end
  endtask

  // task to check USB4 data
  task  check_usb4_data ();
    begin
      m_transaction=new();
      // Check the value representing the value of USB4 data
      if (C_transaction.c_data_in == 32'h00200040) begin   //USB4 data
        m_transaction.usb4 = 1;       //USB4 connection
      end 
      else begin
        m_transaction.usb4 = 0;         //USB4 disconnection
      end
    end
  endtask
  
 task  check_gen4_data ();
    begin

      //config_ag_Rx.get(C_transaction);  //* we will get only one transcation 
     
      if (C_transaction.c_data_in[20] == 1) begin   //Gen 3 data
        m_transaction.gen_config = 3;       //gen 3 speed
      end 
      else if (C_transaction.c_data_in[21] == 1) begin  //Gen 4 data
        m_transaction.gen_config = 4;       //gen 4 speed
      end
      else begin
        m_transaction.gen_config = 2;         
      end
     //$display ("m_transaction = %p",m_transaction);
      mem_ag.put(m_transaction);     //Put the transaction into memory agent FIFO
      $display ("in model memory ] %p",m_transaction);
      m_transaction = new();
    end
  endtask

/*
  task write_in_config();
    C_transaction.c_data_out = 32'd12;   //!we should know that from d.team
    C_transaction.c_address = 8'd18;   
    C_transaction.c_write = 1;   
    C_transaction.c_read = 0;   
    config_ag_Tx.put(C_transaction) ;  // this should go to scoreboard
    C_transaction = new ();
    ////$display ("C_transaction = %p",C_transaction);
    //$display ("write config");

    
  endtask
*/

  task run_phase1();
    begin
      create_transactions();
      //$display ("done creat transactions ");
      //write_in_config();    // ! they don't add this part
      
      read_order1();
      get_packets();
      check_usb4_data();
      check_gen4_data ();

    end
  endtask

endclass

