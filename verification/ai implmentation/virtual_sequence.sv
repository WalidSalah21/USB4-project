class virtual_sequence;

////***stimulus generation declaration***////
    electrical_layer_generator virtual_elec_gen;
    config_generator virtual_cfg_gen; 
    up_transport_generator virtual_up_gen;


    env_cfg_class cfg_class;
    virtual upper_layer_if vif ;

////***event declaration***////
    /*event sbtx_transition_high,  //connect with elec_monitor
      sbtx_response;  //connect with elec_scoreboard to indecate recieve transaction*/

function new(env_cfg_class cfg_class);
    this.cfg_class=cfg_class;
endfunction: new


task run(input GEN speed);
/////////////////////////gen4////////////////////////
    ///phase 1///
    //virtual_elec_gen.wake_up(1);
    virtual_cfg_gen.generate_stimulus() ;
    $display("[virtual_sequence]:waiting for sbtx_transition_high event");

   ///phase 2///
   //@(sbtx_transition_high); // Blocking with the event sbtx_transition_high 
   //->sbtx_response;

    wait(cfg_class.recieved_on_elec_sboard ==1); // wait first AT_cmd from dut to trigger
    cfg_class.recieved_on_elec_sboard =0;
   virtual_elec_gen.sbrx_after_sbtx_high; // Call the sbrx_after_sbtx_high task
    
   ///phase 3///
    wait(cfg_class.recieved_on_elec_sboard ==1); // wait first AT_cmd fro dut to trigger
    cfg_class.recieved_on_elec_sboard =0;
    //virtual_elec_gen.wake_up(3);
  virtual_elec_gen.send_transaction_2_driver(AT_rsp,0,8'd78,7'd3,24'h053303,gen4);  
	virtual_elec_gen.send_transaction_2_driver(AT_cmd,0,8'd78,7'd3,24'h000000,gen4);//phase4


      
      

    wait(cfg_class.recieved_on_elec_sboard ==1);  //  wait AT_rsp from dut to trigger 
    cfg_class.recieved_on_elec_sboard =0;
  //$display("[virtual_sequence]:waittttttttttttttttttttttttttttttttttttttt");
   
   ///phase 4///
    //@(recieved_on_elec_sboard); // Blocking with the event recieved_on_elec_sboard
     //virtual_elec_gen.wake_up(4,speed);
    virtual_elec_gen.Send_OS(TS1_gen4,gen4);
    virtual_elec_gen.Send_OS(TS2_gen4,gen4);
    virtual_elec_gen.Send_OS(TS3,gen4);
    virtual_elec_gen.Send_OS(TS4,gen4);

    ///phase 5///
    wait(vif.cl0_s === 1'b1);         // transport is ready to send and recieve data  //! i think that should be in the virtual sequence
    // sending from transport to electrical layer
  fork

    begin
        // start sending data from the transport layer
        vif.enable_sending = 1'b1;
         // Send data 5 times
            virtual_up_gen.run(5);

            @(negedge  vif.gen4_fsm_clk);
    end

    begin
        //* electrical should recieve here 
    end
    join



      wait(vif.cl0_s === 1'b1);         // transport is ready to send and recieve data  //! i think that should be in the virtual sequence

// sending from electrical to transport layer
  fork

    begin
        //* electrical should send here 
    end

    begin
        // start receiving data on the transport layer
        vif.enable_receive = 1'b1;
    end

  join
    
endtask


/*
/////////////////////////////////////////////////////
/////////////////////////gen3////////////////////////
/////////////////////////////////////////////////////

        virtual_elec_gen.wake_up(1);
        virtual_cfg_gen.generate_stimulus() ;
        $display("[virtual_sequence]:waiting for sbtx_transition_high event");
///phase 2///
        wait(cfg_class.recieved_on_elec_sboard ==1); // wait first AT_cmd fro dut to trigger
        cfg_class.recieved_on_elec_sboard =0;
        virtual_elec_gen.sbrx_after_sbtx_high; // Call the sbrx_after_sbtx_high task
 ///phase 3///
        wait(cfg_class.recieved_on_elec_sboard ==1); // wait first AT_cmd fro dut to trigger
        cfg_class.recieved_on_elec_sboard =0;
        virtual_elec_gen.wake_up(3);
        virtual_elec_gen.send_transaction_2_driver(AT_rsp,0,8'd78,7'd3,24'h013303,gen3);  
        virtual_elec_gen.send_transaction_2_driver(AT_cmd,0,8'd78,7'd3,24'h000000,gen3);
        
        wait(cfg_class.recieved_on_elec_sboard ==1);  //  wait AT_rsp from dut to trigger 
        cfg_class.recieved_on_elec_sboard =0;
 ///phase 4///                                      
               
    // Stop the simulation
    //$stop;


endtask
*/


    


endclass