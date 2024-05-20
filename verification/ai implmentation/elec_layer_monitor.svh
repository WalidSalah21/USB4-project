class electrical_layer_monitor  extends parent;
	//import electrical_layer_transaction_pkg::*;

	//timing parameters
	parameter	tDisconnectTx =	100000; //min is 50ms
     //to define the generation
	 /*typedef enum logic [1:0] {gen2, gen3, gen4} GEN;
     typedef enum logic [3:0] {SLOS1 = 4'b1000, SLOS2, TS1_gen2_3, TS2_gen2_3, TS1_gen4, TS2_gen4, TS3, TS4} OS_type;*/
	 //defind variables
	 logic       trans_to_ele_lane0[$];
	 logic       trans_to_ele_lane1[$];
	 logic [9:0] recieved_transaction_data_symb[$];
	 logic       recieved_transaction_byte[$];

	  GEN speed; 	// indicates the generation
	 //declare the events
      event sbtx_transition_high;  // Event to indicate that the monitor recieved sbtx high("connect to sequance")
	  event correct_OS;            // Event to indicate that the monitor recieved correct ordered set("connect to sequancer")
	  event ready_to_recieved_data;  // Event to indicate that the monitor is ready to recieve data
      event sbtx_response,done;          // Event to indicate that the monitor recieved sbtx response("connect to sequance")
	  //event data_income;            
    //declare the transactions
    elec_layer_tr mon_2_Sboard_trans;    // Transaction to be recieved from the generator
	env_cfg_class env_cfg_mem;           // Transaction to be recieved from the scoreboard
    //declare the mailboxes
    //mailbox #(env_cfg_class) elec_sboard_2_monitor;  // Mailbox to receive the transaction from the generator
    mailbox #(elec_layer_tr) elec_mon_2_Sboard;   // Mailbox to send transaction to the scoreboard
	mailbox #(GEN)           speed_mailbox;           // Mailbox to send the generation speed to the scoreboard
    //declare varsual interface
    virtual electrical_layer_if ELEC_vif; 
    // Constructor
  function new(mailbox #(elec_layer_tr) elec_mon_2_Sboard,virtual electrical_layer_if ELEC_vif
               ,event correct_OS ,env_cfg_class env_cfg_mem );
    this.elec_mon_2_Sboard=elec_mon_2_Sboard;
    this.ELEC_vif=ELEC_vif;
    this.sbtx_transition_high=sbtx_transition_high;
	this.correct_OS=correct_OS;
	this.sbtx_response=sbtx_response;
	this.env_cfg_mem =env_cfg_mem;    //check it
	//mon_2_Sboard_trans=new();
  endfunction 


//extern tasks 
         extern task get_transport_data(input GEN speed);
		 extern task run();
		 extern task check_AT_transaction(input  [9:0] q[$],input tr_type trans_type);
         extern task recieved_SLOS1_gen23(input GEN speed);
		 extern task recieved_SLOS2_gen23(input GEN speed);
		 extern task recieved_TS12_gen23(input GEN speed,input OS_type os);
		 //extern task recieved_TS2_gen23(input GEN speed);
		 extern task recieved_TS234_gen4(input OS_type os,bit done_training);
		 extern task recieved_TS1_gen4();
  endclass : electrical_layer_monitor




task electrical_layer_monitor::recieved_TS12_gen23(input GEN speed ,input OS_type os);
logic      			    recieved_TS_lane0[$],
           				recieved_TS_lane1[$];

logic                   correct_TS1_lane0[$],
                        correct_TS1_lane1[$],
						correct_TS2_lane0[$],
                        correct_TS2_lane1[$];

logic                   temp_TS_lane0[$],
						temp_TS_lane1[$];



//case to recevied the TS for gen2,3 and check the TS
case (os)
TS1_gen2_3:
	begin	//collect data from the two lanes
		    foreach(TS1_gen2_3_lane0[i])begin
				temp_TS_lane0.push_back(TS1_gen2_3_lane0[i]);
				temp_TS_lane1.push_back(TS1_gen2_3_lane1[i]);
			end
			//$display("[ELEC MONITOR]the value of TS1_gen2_3_lane0 is %h",temp_TS_lane0);
			//$display("[ELEC MONITOR]the value of TS1_gen2_3_lane1 is %h",temp_TS_lane1);
			//$display("[ELEC MONITOR]the value of TS1_gen2_3_lane0 is %p",temp_TS_lane0);
			//$display("[ELEC MONITOR]the value of TS1_gen2_3_lane1 is %p",temp_TS_lane1);
			
			//TS1_gen23_lane0=temp_TS_lane0;
			//TS1_gen23_lane1=temp_TS_lane1;
            
			reverse_8bits_in_Gen4(temp_TS_lane0);
			reverse_8bits_in_Gen4(temp_TS_lane1);

			$display("[ELEC MONITOR]the value of TS1_gen2_3_lane0 is %p",temp_TS_lane0);
			//$display("[ELEC MONITOR]the value of TS1_gen2_3_lane1 is %p",TS1_gen23_lane1);
			
		case(speed)
		   gen2:begin
			///////////////////generate 2TS1 FOR GEN2 in arow///////////////////////////
			/*repeat(2)begin
				TS1_gen23_lane0.push_back(1'b1);
				TS1_gen23_lane1.push_back(1'b1);
				TS1_gen23_lane0.push_back(1'b0);
				TS1_gen23_lane1.push_back(1'b0);
				foreach(temp_TS_lane0[i])begin	
				TS1_gen23_lane0.push_back(temp_TS_lane0[i]);
				TS1_gen23_lane1.push_back(temp_TS_lane1[i]);
				end

			end*/
			$display("[ELEC MONITOR]the value of TS1_gen23_lane0 is %p",TS1_gen23_lane0);
			///////////////////generate 32TS1 FOR GEN2///////////////////////////
			repeat(32)begin
				correct_TS1_lane0.push_back(1'b1);
				correct_TS1_lane1.push_back(1'b1);
				correct_TS1_lane0.push_back(1'b0);
				correct_TS1_lane1.push_back(1'b0);
			foreach(temp_TS_lane0[i])begin	
			correct_TS1_lane0.push_back(temp_TS_lane0[i]);
			correct_TS1_lane1.push_back(temp_TS_lane1[i]);
			end
			end
			$display("[ELEC MONITOR]the value of correct_TS1_lane0 is %p",correct_TS1_lane0);
			/////////////////////////////////////////////////////
			while(1)    
		       begin                                                 
			    @(negedge ELEC_vif.gen2_lane_clk);
				recieved_TS_lane0.push_back(ELEC_vif.lane_0_tx);
				recieved_TS_lane1.push_back(ELEC_vif.lane_1_tx);
				if(correct_TS1_lane0.size()==recieved_TS_lane0.size())begin
					//$display("[ELEC MONITOR]the value of recieved_TS_lane0 is %p",recieved_TS_lane0);
				if((recieved_TS_lane0 ==correct_TS1_lane0)&&(recieved_TS_lane1 ==correct_TS1_lane1))begin
					$display("[ELEC MONITOR] ****************TS1 IS CORRECT ON GEN2****************");
					TS1_gen23_lane0=recieved_TS_lane0[0:135];
					TS1_gen23_lane1=recieved_TS_lane1[0:135];
					$stop;
					env_cfg_mem.correct_OS=1;   //do that on all first OS on each gen
					mon_2_Sboard_trans.phase=3'd4;
					mon_2_Sboard_trans.gen_speed=gen2;
					mon_2_Sboard_trans.o_sets=TS1_gen2_3;
					mon_2_Sboard_trans.sbtx='b1;
					mon_2_Sboard_trans.tr_os=ord_set;
					mon_2_Sboard_trans.lane=both;
					ELEC_vif.data_incoming=0;
					elec_mon_2_Sboard.put(mon_2_Sboard_trans);
					break;
					end
					else
					begin
						recieved_TS_lane0.delete(0);
						recieved_TS_lane1.delete(0);
					end
					end

					if(!ELEC_vif.enable_rs || !ELEC_vif.sbtx)
					begin
					$display("[ELEC MONITOR]the value of ELEC_vif.sbtx is  %0d and ELEC_vif.enable_rs %0d during send TS2_gen4 GEN4",ELEC_vif.sbtx,ELEC_vif.enable_rs);
					break;
					end
				
		    end
			    $display("[ELEC MONITOR] the size of correct_TS1_lane0 is %0d for GEN2",correct_TS1_lane0.size());
				$display("[ELEC MONITOR] the size of correct_TS1_lane1 is %0d for GEN2",correct_TS1_lane1.size());

		//////////////////delete the recieved TS////////////////////////
			recieved_TS_lane0.delete();
			recieved_TS_lane1.delete();
			
		end
	
    
     //////////////////////////////////////////
gen3:begin
		///////////////////generate 2TS1 FOR GEN3 in arow///////////////////////////
			
				/*TS1_gen23_lane0.push_back(1'b1);
				TS1_gen23_lane1.push_back(1'b1);
				TS1_gen23_lane0.push_back(1'b0);
				TS1_gen23_lane1.push_back(1'b0);
				TS1_gen23_lane0.push_back(1'b1);
				TS1_gen23_lane1.push_back(1'b1);
				TS1_gen23_lane0.push_back(1'b0);
				TS1_gen23_lane1.push_back(1'b0);
				repeat(2)begin
				foreach(temp_TS_lane0[i])begin	
				TS1_gen23_lane0.push_back(temp_TS_lane0[i]);
				TS1_gen23_lane1.push_back(temp_TS_lane1[i]);
				end
				end*/
 			///////////////////generate TS FOR GEN3///////////////////////////
			//$display("[ELEC MONITOR]the value of correct_TS1_lane0 before is %p",correct_TS1_lane0);
			repeat(8)begin
				correct_TS1_lane0.push_back(1'b1);
				correct_TS1_lane1.push_back(1'b1);
				correct_TS1_lane0.push_back(1'b0);
				correct_TS1_lane1.push_back(1'b0);
				correct_TS1_lane0.push_back(1'b1);
				correct_TS1_lane1.push_back(1'b1);
				correct_TS1_lane0.push_back(1'b0);
				correct_TS1_lane1.push_back(1'b0);
				repeat(2)begin
					foreach(temp_TS_lane0[i])begin	
					correct_TS1_lane0.push_back(temp_TS_lane0[i]);
					correct_TS1_lane1.push_back(temp_TS_lane1[i]);
					end
				end
			end
			$display("[ELEC MONITOR]the value of correct_TS1_lane0 is %p",correct_TS1_lane0);
			/////////////////////////////////////////////////////
			while(1)    
		       begin                                                 
			    @(negedge ELEC_vif.gen3_lane_clk);
				recieved_TS_lane0.push_back(ELEC_vif.lane_0_tx);
				recieved_TS_lane1.push_back(ELEC_vif.lane_1_tx);
				if(correct_TS1_lane0.size()==recieved_TS_lane0.size())begin
				if((recieved_TS_lane0 ==correct_TS1_lane0)&&(recieved_TS_lane1 ==correct_TS1_lane1))begin
					$display("[ELEC MONITOR] ****************TS1 IS CORRECT ON GEN3****************");
					//$display("[ELEC MONITOR]the value of TS1_gen23_lane0 is %p and size is %0d",TS1_gen23_lane0,TS1_gen23_lane0.size());
					//$display("[ELEC MONITOR]the value of TS1_gen23_lane1 is %p and size is %0d",TS1_gen23_lane1,TS1_gen23_lane0.size());
					TS1_gen23_lane0=recieved_TS_lane0[0:131];
					TS1_gen23_lane1=recieved_TS_lane1[0:131];
					$display("[ELEC MONITOR]the value of TS1_gen23_lane0 is %p and size is %0d",TS1_gen23_lane0,TS1_gen23_lane0.size());
					$display("[ELEC MONITOR]the value of TS1_gen23_lane1 is %p and size is %0d",TS1_gen23_lane1,TS1_gen23_lane0.size());
					//$stop;
					env_cfg_mem.correct_OS=1;   //do that on all first OS on each gen
					mon_2_Sboard_trans.phase=3'd4;
					mon_2_Sboard_trans.gen_speed=gen3;
					mon_2_Sboard_trans.o_sets=TS1_gen2_3;
					mon_2_Sboard_trans.sbtx='b1;
					mon_2_Sboard_trans.tr_os=ord_set;
					mon_2_Sboard_trans.lane=both;
					ELEC_vif.data_incoming=0;
					elec_mon_2_Sboard.put(mon_2_Sboard_trans);
					break;
					end
					else
					begin
						recieved_TS_lane0.delete(0);
						recieved_TS_lane1.delete(0);
					end
					end

					if(!ELEC_vif.enable_rs || !ELEC_vif.sbtx)
					begin
					$display("[ELEC MONITOR]the value of ELEC_vif.sbtx is  %0d and ELEC_vif.enable_rs %0d during send TS2_gen4 GEN4",ELEC_vif.sbtx,ELEC_vif.enable_rs);
					break;
					end
				
		    end
			    $display("[ELEC MONITOR] the size of correct_TS1_lane0 is %0d for GEN3",correct_TS1_lane0.size());
				$display("[ELEC MONITOR] the size of correct_TS1_lane1 is %0d for GEN3",correct_TS1_lane1.size());

		//////////////////delete the recieved TS////////////////////////
			recieved_TS_lane0.delete();
			recieved_TS_lane1.delete();

	  end

	 
endcase
end
TS2_gen2_3:
begin
	       foreach(TS2_gen2_3_lane0[i])begin
				temp_TS_lane0.push_back(TS2_gen2_3_lane0[i]);
				temp_TS_lane1.push_back(TS2_gen2_3_lane1[i]);
			end
			$display("[ELEC MONITOR]the value of temp_TS_lane0 is %p",temp_TS_lane0);
			//TS2_gen23_lane0=temp_TS_lane0;
			//TS2_gen23_lane1=temp_TS_lane1;
			reverse_8bits_in_Gen4(temp_TS_lane0);
			reverse_8bits_in_Gen4(temp_TS_lane1);

	case(speed)
	gen2:begin
		///////////////////generate 2TS2 FOR GEN2 in arow///////////////////////////
			repeat(2)begin
				TS2_gen23_lane0.push_back(1'b1);
				TS2_gen23_lane1.push_back(1'b1);
				TS2_gen23_lane0.push_back(1'b0);
				TS2_gen23_lane1.push_back(1'b0);
				foreach(temp_TS_lane0[i])begin	
				TS2_gen23_lane0.push_back(temp_TS_lane0[i]);
				TS2_gen23_lane1.push_back(temp_TS_lane1[i]);
				end

			end
			$display("[ELEC MONITOR]the value of TS1_gen23_lane0 is %p",TS2_gen23_lane0);
			///////////////////generate 16TS2 FOR GEN2///////////////////////////
			repeat(16)begin
				correct_TS2_lane0.push_back(1'b1);
				correct_TS2_lane1.push_back(1'b1);
				correct_TS2_lane0.push_back(1'b0);
				correct_TS2_lane1.push_back(1'b0);
			foreach(temp_TS_lane0[i])begin	
			correct_TS2_lane0.push_back(temp_TS_lane0[i]);
			correct_TS2_lane1.push_back(temp_TS_lane1[i]);
			end
			end
			$display("[ELEC MONITOR]the value of correct_TS1_lane0 is %p",correct_TS2_lane0);
		while(1)    
		       begin                                                 
			    @(negedge ELEC_vif.gen2_lane_clk);
				recieved_TS_lane0.push_back(ELEC_vif.lane_0_tx);
				recieved_TS_lane1.push_back(ELEC_vif.lane_1_tx);
				if(correct_TS2_lane0.size()==recieved_TS_lane0.size())begin
				if((recieved_TS_lane0 ==correct_TS2_lane0)&&(recieved_TS_lane1 ==correct_TS2_lane1))begin
					$display("[ELEC MONITOR] ****************TS2 IS CORRECT ON GEN2****************");
					env_cfg_mem.correct_OS=1;   //do that on all first OS on each gen
					mon_2_Sboard_trans.phase=3'd4;
					mon_2_Sboard_trans.gen_speed=gen2;
					mon_2_Sboard_trans.o_sets=TS2_gen2_3;
					mon_2_Sboard_trans.sbtx='b1;
					mon_2_Sboard_trans.tr_os=ord_set;
					mon_2_Sboard_trans.lane=both;
					ELEC_vif.data_incoming=0;
					-> ready_to_recieved_data;   //do that on all first OS on each gen
					elec_mon_2_Sboard.put(mon_2_Sboard_trans);
					break;
					end
					else
					begin
						recieved_TS_lane0.delete(0);
						recieved_TS_lane1.delete(0);
					end
					end

					if(!ELEC_vif.enable_rs || !ELEC_vif.sbtx)
					begin
					$display("[ELEC MONITOR]the value of ELEC_vif.sbtx is  %0d and ELEC_vif.enable_rs %0d during send TS2_gen2 GEN2",ELEC_vif.sbtx,ELEC_vif.enable_rs);
					break;
					end
				
		    end
			    $display("[ELEC MONITOR] the size of correct_TS1_lane0 is %0d for GEN2",correct_TS1_lane0.size());
				$display("[ELEC MONITOR] the size of correct_TS1_lane1 is %0d for GEN2",correct_TS1_lane1.size());

		//////////////////delete the recieved TS////////////////////////
			recieved_TS_lane0.delete();
			recieved_TS_lane1.delete();
		end
	gen3:
	begin
		///////////////////generate 2TS2 FOR GEN3 in arow///////////////////////////
			
				TS2_gen23_lane0.push_back(1'b1);
				TS2_gen23_lane1.push_back(1'b1);
				TS2_gen23_lane0.push_back(1'b0);
				TS2_gen23_lane1.push_back(1'b0);
				TS2_gen23_lane0.push_back(1'b1);
				TS2_gen23_lane1.push_back(1'b1);
				TS2_gen23_lane0.push_back(1'b0);
				TS2_gen23_lane1.push_back(1'b0);
				repeat(2)begin
				foreach(temp_TS_lane0[i])begin	
				TS2_gen23_lane0.push_back(temp_TS_lane0[i]);
				TS2_gen23_lane1.push_back(temp_TS_lane1[i]);
				end
				end
 			///////////////////generate TS FOR GEN3///////////////////////////
			//$display("[ELEC MONITOR]the value of correct_TS1_lane0 before is %p",correct_TS1_lane0);
			repeat(4)begin
				correct_TS2_lane0.push_back(1'b1);
				correct_TS2_lane1.push_back(1'b1);
				correct_TS2_lane0.push_back(1'b0);
				correct_TS2_lane1.push_back(1'b0);
				correct_TS2_lane0.push_back(1'b1);
				correct_TS2_lane1.push_back(1'b1);
				correct_TS2_lane0.push_back(1'b0);
				correct_TS2_lane1.push_back(1'b0);
				repeat(2)begin
					foreach(temp_TS_lane0[i])begin	
					correct_TS2_lane0.push_back(temp_TS_lane0[i]);
					correct_TS2_lane1.push_back(temp_TS_lane1[i]);
					end
				end
			end
			$display("[ELEC MONITOR]the value of correct_TS1_lane0 is %p and size %0d",correct_TS1_lane0,correct_TS1_lane0.size());
			/////////////////////////////////////////////////////
		while(1)    
		       begin                                                 
			    @(negedge ELEC_vif.gen3_lane_clk);
				recieved_TS_lane0.push_back(ELEC_vif.lane_0_tx);
				recieved_TS_lane1.push_back(ELEC_vif.lane_1_tx);
				if(correct_TS2_lane0.size()==recieved_TS_lane0.size())begin
				if((recieved_TS_lane0 ==correct_TS2_lane0)&&(recieved_TS_lane1 ==correct_TS2_lane1))begin
					
					$display("[ELEC MONITOR] ****************TS2 IS CORRECT ON GEN3****************");
					
					env_cfg_mem.correct_OS=1;   //do that on all first OS on each gen
					mon_2_Sboard_trans.phase=3'd4;
					mon_2_Sboard_trans.gen_speed=gen3;
					mon_2_Sboard_trans.o_sets=TS2_gen2_3;
					mon_2_Sboard_trans.sbtx='b1;
					mon_2_Sboard_trans.tr_os=ord_set;
					mon_2_Sboard_trans.lane=both;
					ELEC_vif.data_incoming=0;
					-> ready_to_recieved_data;   //do that on all first OS on each gen
					//speed_mailbox.put(gen3);
					elec_mon_2_Sboard.put(mon_2_Sboard_trans);
					break;
					end
					else
					begin
						recieved_TS_lane0.delete(0);
						recieved_TS_lane1.delete(0);
					end
					end

					if(!ELEC_vif.enable_rs || !ELEC_vif.sbtx)
					begin
					$display("[ELEC MONITOR]the value of ELEC_vif.sbtx is  %0d and ELEC_vif.enable_rs %0d during send TS2_gen4 GEN4",ELEC_vif.sbtx,ELEC_vif.enable_rs);
					break;
					end
				
		    end
			    $display("[ELEC MONITOR] the size of correct_TS2_lane0 is %0d for GEN3 ",correct_TS2_lane0.size());
				$display("[ELEC MONITOR] the size of correct_TS2_lane1 is %0d for GEN3",correct_TS2_lane1.size());

		//////////////////delete the recieved TS////////////////////////
			recieved_TS_lane0.delete();
			recieved_TS_lane1.delete();

		/*repeat(TS_GEN_2_3_SIZE*8)begin //collect the TS from the two lanes
		@(negedge ELEC_vif.gen3_lane_clk);
		recieved_TS_lane0.push_back(ELEC_vif.lane_0_rx);
		recieved_TS_lane1.push_back(ELEC_vif.lane_1_rx);
		if(!ELEC_vif.enable_rs || !ELEC_vif.sbtx)
			begin
			 $display("[ELEC MONITOR] %0t:the value of ELEC_vif.sbtx is %0d and ELEC_vif.enable_rs %0d  during send TS1 GEN3",$time,ELEC_vif.sbtx,ELEC_vif.enable_rs);
			break;
			end
		end
			$display("the size of recieved_TS2_gen3 on lane0 is %0d and must be (512) on lane 0",recieved_TS_lane0.size());


			//calculate the correct TS
			repeat(8)begin
			foreach(TS2_gen2_3_lane0[i])begin
			correct_TS2_lane0.push_back(TS2_gen2_3_lane0[i]);
			correct_TS2_lane1.push_back(TS2_gen2_3_lane1[i]);
			end
			end

			//check the recieved TS with the correct	
		if(recieved_TS_lane0==correct_TS2_lane0 && recieved_TS_lane1==correct_TS2_lane1)
		begin	
			 $display("TS2 is correct on gen3");	
			-> ready_to_recieved_data;   //do that on all first OS on each gen	
			mon_2_Sboard_trans.phase=3'd4;
			mon_2_Sboard_trans.gen_speed=gen3;
			mon_2_Sboard_trans.o_sets=TS2_gen2_3;
			mon_2_Sboard_trans.sbtx='b1;
			mon_2_Sboard_trans.tr_os=ord_set;
			mon_2_Sboard_trans.lane=both;
			elec_mon_2_Sboard.put(mon_2_Sboard_trans);
			speed_mailbox.put(gen3);

		end
		else
		$display("[ELEC MONITOR] TS2 is not correct on gen3");*/

		end
	endcase
end

endcase
endtask:recieved_TS12_gen23


task electrical_layer_monitor::recieved_SLOS2_gen23(input GEN speed);
	int i;
	logic 			        recieved_SLOS2_lane0[$],
						    recieved_SLOS2_lane1[$];

	if(speed==gen2) //collect the SLOS from the two lanes
	begin
		 while(1)    
		 begin                                                 //repeat(16*TS_GEN_4_HEADER_SIZE)begin //collect the TS from the two lanes
			@(negedge ELEC_vif.gen2_lane_clk);
				recieved_SLOS2_lane0.push_back(ELEC_vif.lane_0_tx);
				recieved_SLOS2_lane1.push_back(ELEC_vif.lane_1_tx);
				if(recieved_SLOS2_lane0.size()==GEN2_Recieved_SLOS2.size())begin
				if((recieved_SLOS2_lane0 ==GEN2_Recieved_SLOS2)&&(recieved_SLOS2_lane1 ==GEN2_Recieved_SLOS2))begin
					$display("[ELEC MONITOR] ****************SLOS2 IS CORRECT ON GEN2****************");
					mon_2_Sboard_trans=new();
					env_cfg_mem.correct_OS=1;   //do that on all first OS on each gen
					mon_2_Sboard_trans.phase=3'd4;
					mon_2_Sboard_trans.gen_speed=gen2;
					mon_2_Sboard_trans.o_sets=SLOS2;
					mon_2_Sboard_trans.sbtx='b1;
					mon_2_Sboard_trans.tr_os=ord_set;
					mon_2_Sboard_trans.lane=both;
					//ELEC_vif.data_incoming=0;
					elec_mon_2_Sboard.put(mon_2_Sboard_trans);
					break;
					end
					else
					begin
						recieved_SLOS2_lane0.delete(0);
						recieved_SLOS2_lane1.delete(0);
					end
					end

					if(!ELEC_vif.enable_rs || !ELEC_vif.sbtx)
					begin
					$display("[ELEC MONITOR]the value of ELEC_vif.sbtx is  %0d and ELEC_vif.enable_rs %0d during send TS2_gen4 GEN4",ELEC_vif.sbtx,ELEC_vif.enable_rs);
					break;
					end
		end


		/////////////////
	
	//$display("the value of recieved_SLOS2_lane0 is %p for GEN2",recieved_SLOS2_lane0);
	$display("the size of recieved_SLOS2_lane0 is %0d for GEN2",recieved_SLOS2_lane0.size());
	$display("the size of recieved_SLOS2_lane1 is %0d for GEN2",recieved_SLOS2_lane1.size());
	end
	else if(speed==gen3)
	begin
		$display("[ELEC MONITOR]READY TO RECIEVE SLOS2 ON GEN3");
		while(1)    
		 begin                                                 //repeat(16*TS_GEN_4_HEADER_SIZE)begin //collect the TS from the two lanes
			@(negedge ELEC_vif.gen3_lane_clk);
				recieved_SLOS2_lane0.push_back(ELEC_vif.lane_0_tx);
				recieved_SLOS2_lane1.push_back(ELEC_vif.lane_1_tx);
				if(recieved_SLOS2_lane0.size()==GEN3_Recieved_SLOS2.size())begin
				if((recieved_SLOS2_lane0 ==GEN3_Recieved_SLOS2)&&(recieved_SLOS2_lane1 ==GEN3_Recieved_SLOS2))begin
					$display("[ELEC MONITOR] ****************SLOS2 IS CORRECT ON GEN3****************");
					mon_2_Sboard_trans=new();
					env_cfg_mem.correct_OS=1;   //do that on all first OS on each gen
					mon_2_Sboard_trans.phase=3'd4;
					mon_2_Sboard_trans.gen_speed=gen2;
					mon_2_Sboard_trans.o_sets=SLOS2;
					mon_2_Sboard_trans.sbtx='b1;
					mon_2_Sboard_trans.tr_os=ord_set;
					mon_2_Sboard_trans.lane=both;
					//ELEC_vif.data_incoming=0;
					elec_mon_2_Sboard.put(mon_2_Sboard_trans);
					break;
					end
					else
					begin
						recieved_SLOS2_lane0.delete(0);
						recieved_SLOS2_lane1.delete(0);
					end
					end

					if(!ELEC_vif.enable_rs || !ELEC_vif.sbtx)
					begin
					$error("[ELEC MONITOR]the value of ELEC_vif.sbtx is  %0d and ELEC_vif.enable_rs %0d during send TS2_gen4 GEN4",ELEC_vif.sbtx,ELEC_vif.enable_rs);
					break;
					end
		end

	//$display("the value of recieved_SLOS2_lane0 is %p for GEN3",recieved_SLOS2_lane0);
	$display("the size of recieved_SLOS2_lane0 is %0d for GEN3",recieved_SLOS2_lane0.size());
	$display("the size of recieved_SLOS2_lane1 is %0d for GEN3",recieved_SLOS2_lane1.size());
	end
endtask:recieved_SLOS2_gen23

//task to recieved TS for gen4
task electrical_layer_monitor::recieved_TS234_gen4(input OS_type os,bit done_training);

logic 		         	recieved_TS_lane0[$],
					    recieved_TS_lane1[$];
logic                   correct_TS2[$],
                        correct_TS3[$],
						correct_TS4[$],
						temp_correct_TS[$];
logic 		            TS4_gen4[32];						
bit		[3:0]			counter;


if(!done_training)begin
	case(os)
	TS2_gen4:
	begin
		$display("[ELEC MONITOR]HEADER_TS2_GEN4=%32b",HEADER_TS2_GEN4);
			repeat(No_TS_GEN4)begin
				foreach(HEADER_TS2_GEN4[i])begin
					correct_TS2.push_front(HEADER_TS2_GEN4[i]);
				end
			end
		   $display("[ELEC MONITOR]the value of correct_TS2 is %p",correct_TS2);
            while(1)    begin                                                 //repeat(16*TS_GEN_4_HEADER_SIZE)begin //collect the TS from the two lanes
				@(negedge ELEC_vif.gen4_lane_clk);
					recieved_TS_lane0.push_back(ELEC_vif.lane_0_tx);
					recieved_TS_lane1.push_back(ELEC_vif.lane_1_tx);

					if(recieved_TS_lane0.size()==correct_TS2.size())begin
					if((recieved_TS_lane0 ==correct_TS2)&&(recieved_TS_lane1 ==correct_TS2))begin
						$display("[ELEC MONITOR] TS2 IS CORRECT ON GEN4");
						env_cfg_mem.correct_OS=1;   //do that on all first OS on each gen
						mon_2_Sboard_trans.phase=3'd4;
						mon_2_Sboard_trans.gen_speed=gen4;
						mon_2_Sboard_trans.o_sets=TS2_gen4;
						mon_2_Sboard_trans.sbtx='b1;
						mon_2_Sboard_trans.tr_os=ord_set;
						mon_2_Sboard_trans.lane=both;
						ELEC_vif.data_incoming=0;
						elec_mon_2_Sboard.put(mon_2_Sboard_trans);
						break;
					end
					else
					begin
						recieved_TS_lane0.delete(0);
						recieved_TS_lane1.delete(0);
					end
					end

					if(!ELEC_vif.enable_rs || !ELEC_vif.sbtx)
					begin
					$display("[ELEC MONITOR]the value of ELEC_vif.sbtx is  %0d and ELEC_vif.enable_rs %0d during send TS2_gen4 GEN4",ELEC_vif.sbtx,ELEC_vif.enable_rs);
					break;
					end
			end

			$display("[ELEC MONITOR] the size of recieved_TS2 GEN4 on lane0 is %0d and must be 32*16 on lane 0",recieved_TS_lane0.size());
			$display("[ELEC MONITOR] the recieved_TS2 GEN4 on lane0 is %0p ",recieved_TS_lane0[0:31]);
			/*if((correct_TS2 ==recieved_TS_lane1)&& (correct_TS2 ==recieved_TS_lane0))begin
			$display("[ELEC MONITOR] TS2 IS CORRECT ON GEN4");
			env_cfg_mem.correct_OS=1;   //do that on all first OS on each gen
			mon_2_Sboard_trans.phase=3'd4;
			mon_2_Sboard_trans.gen_speed=gen4;
			mon_2_Sboard_trans.o_sets=TS2_gen4;
			mon_2_Sboard_trans.sbtx='b1;
			mon_2_Sboard_trans.tr_os=ord_set;
			mon_2_Sboard_trans.lane=both;
			elec_mon_2_Sboard.put(mon_2_Sboard_trans);
			end
			else
			$display("[ELEC MONITOR] TS2 is not correct on gen4");*/
			end

	TS3:
		begin
			$display("[ELEC MONITOR]HEADER_TS3_GEN4=%32b",HEADER_TS3_GEN4);
			repeat(No_TS_GEN4)begin
				foreach(HEADER_TS3_GEN4[i])begin
					correct_TS3.push_front(HEADER_TS3_GEN4[i]);
				end
			end
		   //$display("[ELEC MONITOR]the value of correct_TS3 is %p",correct_TS3);
			while(1)begin
					@(negedge ELEC_vif.gen4_lane_clk);
					recieved_TS_lane0.push_back(ELEC_vif.lane_0_tx);
					recieved_TS_lane1.push_back(ELEC_vif.lane_1_tx);

					if(recieved_TS_lane0.size()==correct_TS3.size())begin
					if((recieved_TS_lane0 ==correct_TS3)&&(recieved_TS_lane1 ==correct_TS3))begin
						$display("[ELEC MONITOR] ****************TS3 IS CORRECT ON GEN4****************");
						env_cfg_mem.correct_OS=1;   //do that on all first OS on each gen
						mon_2_Sboard_trans.phase=3'd4;
						mon_2_Sboard_trans.gen_speed=gen4;
						mon_2_Sboard_trans.o_sets=TS3;
						mon_2_Sboard_trans.sbtx='b1;
						mon_2_Sboard_trans.tr_os=ord_set;
						mon_2_Sboard_trans.lane=both;
						ELEC_vif.data_incoming=0;
						elec_mon_2_Sboard.put(mon_2_Sboard_trans);
						break;
					end
					else
					begin
						recieved_TS_lane0.delete(0);
						recieved_TS_lane1.delete(0);
					end
					end

					if(!ELEC_vif.enable_rs || !ELEC_vif.sbtx)
					begin
					$display("[ELEC MONITOR]the value of ELEC_vif.sbtx is  %0d and ELEC_vif.enable_rs %0d during send TS2_gen4 GEN4",ELEC_vif.sbtx,ELEC_vif.enable_rs);
					break;
					end
			end
			$display("[ELEC MONITOR] the size of recieved_TS3 GEN4 on lane0 is %0d and must be 32*16 on lane 0",recieved_TS_lane0.size());
			$display("[ELEC MONITOR] the recieved_TS3 GEN4 on lane0 is %0p ",recieved_TS_lane0[0:31]);
		end
	TS4:
	begin
			counter=4'b0;
			//calculate the correct TS4
			repeat(No_TS_GEN4-1)
			begin
			counter=counter+1;
			$display("[ELEC MONITOR]the value of counter is %0d",counter);	
			TS4_gen4={<<{4'd0,{<<{~(counter)}},{<<{counter}},indication_TS4,CURSOR}};
			foreach(TS4_gen4[j])begin
			 correct_TS4.push_back(TS4_gen4[j]);  //check the correct value
			end 
			end

			$display("[ELEC MONITOR]the value of correct_TS4 is %p and size= %0d",correct_TS4[0:31],correct_TS4.size());
			
			while(1)begin
					@(negedge ELEC_vif.gen4_lane_clk);
					recieved_TS_lane0.push_back(ELEC_vif.lane_0_tx);
					recieved_TS_lane1.push_back(ELEC_vif.lane_1_tx);

					if(recieved_TS_lane0.size()==correct_TS4.size())begin
					if((recieved_TS_lane0 ==correct_TS4)&&(recieved_TS_lane1 ==correct_TS4))begin
						$display("[ELEC MONITOR] ****************TS4 IS CORRECT ON GEN4****************");
						env_cfg_mem.correct_OS=1;   //do that on all first OS on each gen
						mon_2_Sboard_trans.phase=3'd4;
						mon_2_Sboard_trans.gen_speed=gen4;
						mon_2_Sboard_trans.o_sets=TS4;
						mon_2_Sboard_trans.sbtx='b1;
						mon_2_Sboard_trans.tr_os=ord_set;
						mon_2_Sboard_trans.lane=both;
						ELEC_vif.data_incoming=0;
						elec_mon_2_Sboard.put(mon_2_Sboard_trans);
						break;
					end
					else
					begin
						recieved_TS_lane0.delete(0);
						recieved_TS_lane1.delete(0);
					end
					end

					if(!ELEC_vif.enable_rs || !ELEC_vif.sbtx)
					begin
					$display("[ELEC MONITOR]the value of ELEC_vif.sbtx is  %0d and ELEC_vif.enable_rs %0d during send TS4_gen4 GEN4",ELEC_vif.sbtx,ELEC_vif.enable_rs);
					break;
					end
			end
			//$stop;
		end

	
	endcase

    
end
else
	begin
      $display("[ELEC MONITOR] training is done for gen4");
	  -> ready_to_recieved_data;
	 // speed_mailbox.put(gen4);

	end
endtask:recieved_TS234_gen4


task  electrical_layer_monitor::recieved_TS1_gen4();
int i,k=0;
logic 		               	   recieved_TS1_lane0[$],
							   recieved_TS1_lane1[$];
logic		      		       TS1_total_lane0[$],
                               TS1_total_lane1[$],
							   temp_q_lane0[$],
							   temp_q_lane1[$];						   
logic                          PRBS11_q_lane0[$],
                               PRBS11_q_lane1[$];

temp_q_lane0={<<{HEADER_TS1_GEN4}};
temp_q_lane1={<<{HEADER_TS1_GEN4}};

//generate the TS1 for gen4
PRSC11(PRBS11_lane0_seed,No_TS_GEN4*PRBS11_SYMBOL_SIZE, PRBS11_q_lane0);
PRSC11(PRBS11_lane1_seed,No_TS_GEN4*PRBS11_SYMBOL_SIZE, PRBS11_q_lane1);
//$display("[ELEC MONITOR] size of PRBS11_q_lane0=%0d",PRBS11_q_lane0.size());
/////////////////////////////////////
 @(posedge ELEC_vif.gen4_lane_clk)
//*****collect the TS1 from both lanes*****//
repeat(TS16_SIZE) 
 begin 
   @(posedge ELEC_vif.gen4_lane_clk)
  	recieved_TS1_lane0.push_back(ELEC_vif.lane_0_tx);
  	recieved_TS1_lane1.push_back(ELEC_vif.lane_1_tx);
  if(!ELEC_vif.enable_rs || !ELEC_vif.sbtx)
        begin
		   $error("[ELEC MONITOR]the value of ELEC_vif.sbtx is %0d AND ELEC_vif.enable_rs %0d during send TS1 GEN4",ELEC_vif.sbtx,ELEC_vif.enable_rs);
		   break;
		end
  end
	$display("[ELEC MONITOR]the size of recieved_TS1_gen4 on lane0 is %0d and must be 7168 on lane 0",recieved_TS1_lane0.size());
	$display("[ELEC MONITOR]the size of recieved_TS1_gen4 on lane1 is %0d and must be 7168 on lane 1",recieved_TS1_lane1.size());
/////////////////////////////////////////
//*****create 16 TS1 equivel*****//	
i=0;
repeat(No_TS_GEN4)
begin
	
	//$display("[ELEC MONITOR] size of temp_q_lane0 in case HEADER_TS1_GEN4=%p",temp_q_lane0);

	foreach(temp_q_lane0[j])begin
		TS1_total_lane0.push_back(temp_q_lane0[j]);
		TS1_total_lane1.push_back(temp_q_lane1[j]);
	end
	//$display("[ELEC MONITOR] size of TS1_total_lane0 in case HEADER_TS1_GEN4=%p",TS1_total_lane0[0:27]);
	//temp_q_lane0.delete();
	//temp_q_lane1.delete();

	for(int k=(i*448)+28;k<=((i*448)+447);k++)begin
		TS1_total_lane0.push_back(PRBS11_q_lane0[k]);
		TS1_total_lane1.push_back(PRBS11_q_lane1[k]);
	end
	//$display("[ELEC MONITOR] check the first 28 bits= %p of Temp_recieved_TS1_lane0",(recieved_TS1_lane0[0:27]));
i++;
end
//////////////////////////////////////////////
//*****reverse the recieved TS(8bit for gen4)*****//
	//reverse_8bits_in_Gen4(recieved_TS1_lane0);
	//reverse_8bits_in_Gen4(recieved_TS1_lane1);
////////////////////////////////////////////// 
	$display("[ELEC MONITOR]the value of recieved_TS1_lane0 on lane0 is %p and size %0d ",recieved_TS1_lane0[0:31],recieved_TS1_lane0.size());
	$display("[ELEC MONITOR]the value of TS1_total_lane0    on lane0 is %p and size %0d",TS1_total_lane0[0:31],TS1_total_lane0.size());
	$display("[ELEC MONITOR]the value of recieved_TS1_lane1 on lane0 is %p and size %0d",recieved_TS1_lane1[0:31],recieved_TS1_lane1.size());
	$display("[ELEC MONITOR]the value of TS1_total_lane1    on lane0 is %p and size %0d",TS1_total_lane1[0:31],TS1_total_lane1.size());
/////////////////////////////////////

foreach(TS1_total_lane0[i])
begin
	if(TS1_total_lane0[i] ==recieved_TS1_lane0[i])begin
	end
	else
	$display("[monitor] error on bit%0d TS1_total_lane0[%0d] and recieved_TS1_lane0[%0d]",i,TS1_total_lane0[i],recieved_TS1_lane0[i]);
end
///*****compare*****///
if(TS1_total_lane0==recieved_TS1_lane0 && TS1_total_lane1==recieved_TS1_lane1)
begin

for(int x=0;x<448;x++) begin
			GEN4_recieved_TS1_LANE0[x]=recieved_TS1_lane0[x];
			GEN4_recieved_TS1_LANE1[x]=recieved_TS1_lane1[x];
                       end
$display("[ELEC MONITOR]*************TS1 IS CORRECT on GEN4*******************");
env_cfg_mem.correct_OS=1;   //do that on all first OS on each gen
$display("[ELEC monitor correct_OS is trigger]");
        wait(env_cfg_mem.done == 1);
		env_cfg_mem.done=0;
		//@(done);
		mon_2_Sboard_trans=new();
        mon_2_Sboard_trans.gen_speed=gen4;
		mon_2_Sboard_trans.o_sets=TS1_gen4;
		mon_2_Sboard_trans.sbtx='b1;
		mon_2_Sboard_trans.tr_os=ord_set;
		mon_2_Sboard_trans.lane=both;
		mon_2_Sboard_trans.phase=3'd4;
		elec_mon_2_Sboard.put(mon_2_Sboard_trans);
end
else	begin
$error("[ELEC MONITOR]TS1 is NOT CORRECT on GEN4");
end
recieved_TS1_lane0.delete();
recieved_TS1_lane1.delete();
TS1_total_lane0.delete();
TS1_total_lane1.delete();
$display("tmammmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm");
endtask:recieved_TS1_gen4

//task to recieved SLOS1 for gen2,3
	task  electrical_layer_monitor::recieved_SLOS1_gen23(input GEN speed);  //add check on sbtx=1 all the time of recieved
	int i;
	logic  			      recieved_SLOS1_lane0[$],
						  recieved_SLOS1_lane1[$],
						  Temp_GEN3_Recieved_SLOS2[$],
						  Temp_GEN2_Recieved_SLOS2[$];  //check the rang is good or flip?
	logic		  		  SLOS1_total[$],
					      SLOS1_Total_With_sync[$];
	bit					  popped_bit;

/////////////////////////////////////////////
	if(speed==gen2) //collect the SLOS from the two lanes
	begin
    ////////////////this delay for difference clk edges////////////////////////
    @(negedge ELEC_vif.gen2_lane_clk);
	repeat(SLOS_SIZE)  
	begin
		@(negedge ELEC_vif.gen2_lane_clk);
		recieved_SLOS1_lane0.push_back(ELEC_vif.lane_0_tx);
		recieved_SLOS1_lane1.push_back(ELEC_vif.lane_1_tx);
		if(!ELEC_vif.enable_rs || !ELEC_vif.sbtx)begin
		   $display("at%0t:[ELEC MONITOR]the value of ELEC_vif.sbtx is %0d AND enable_rs equal %0d during send slos1 for GEN2 ",$time,ELEC_vif.sbtx,ELEC_vif.enable_rs);
		   break;
		end
	end
	//$display("the value of recieved_SLOS1_lane0 is %p for GEN2",recieved_SLOS1_lane0);
	$display("the size of recieved_SLOS1_lane0 is %0d for GEN2",recieved_SLOS1_lane0.size());
	$display("the size of recieved_SLOS1_lane1 is %0d for GEN2",recieved_SLOS1_lane1.size());
	end
	else if(speed==gen3)
	begin
    ///////////////this delay for difference clk edges////////////////////////
    @(negedge ELEC_vif.gen3_lane_clk);
	repeat(SLOS_SIZE)	//collect the SLOS from the two lanes
	begin
	@(negedge ELEC_vif.gen3_lane_clk);
	recieved_SLOS1_lane0.push_back(ELEC_vif.lane_0_tx);
	recieved_SLOS1_lane1.push_back(ELEC_vif.lane_1_tx);
	if(!ELEC_vif.enable_rs || !ELEC_vif.sbtx)begin
		$display("[ELEC MONITOR]the value of ELEC_vif.sbtx is %0d during send slos1 for for GEN3",ELEC_vif.sbtx);
		break;
	end
	end
	//$display("the value of recieved_SLOS1_lane0 is %p for GEN3",recieved_SLOS1_lane0);
	$display("[ELEC MONITOR] the size of recieved_SLOS1_lane0 is %0d  for GEN3",recieved_SLOS1_lane0.size());
	$display("[ELEC MONITOR] the size of recieved_SLOS1_lane1 is %0d  for GEN3",recieved_SLOS1_lane1.size());
	end

	//////////////////////////////////////////////////////////
	PRSC11(PRBS11_lanes_seed,PRBS_SLOS_SIZE,SLOS1_total);
	//TO Delete the first 10 bits
	for (int j = 0; j < 10; j++) begin
	popped_bit = SLOS1_total.pop_front();
	end
	//$display("[ELEC MONITOR]the size of SLOS1_total is %0d",SLOS1_total.size());
	reverse_8bits_in_Gen4(SLOS1_total);   //to reverse bytes

	foreach(SLOS1_total[i])begin
		Temp_GEN2_Recieved_SLOS2[i]=!SLOS1_total[i];     //set slos 2
	    Temp_GEN3_Recieved_SLOS2[i]=!SLOS1_total[i]; 
	end
	    //
	//$display("[ELEC MONITOR]the size of SLOS1_total is %p",SLOS1_total);
	
//add sync bits
if(speed==gen3)begin
	i=0;
	repeat(NO_SLOS_SYNC_GEN3)begin
		SLOS1_Total_With_sync.push_back(1);
		GEN3_Recieved_SLOS2.push_back(1);
		SLOS1_Total_With_sync.push_back(0);
		GEN3_Recieved_SLOS2.push_back(0);
	    SLOS1_Total_With_sync.push_back(1);
		GEN3_Recieved_SLOS2.push_back(1);
	    SLOS1_Total_With_sync.push_back(0);
		GEN3_Recieved_SLOS2.push_back(0);
		repeat(128)begin
			SLOS1_Total_With_sync.push_back(SLOS1_total[i]);
			GEN3_Recieved_SLOS2.push_back(Temp_GEN3_Recieved_SLOS2[i]);
			i++;
		end
	end
end
else if(speed==gen2)begin
	i=0;
	repeat(NO_SLOS_SYNC_GEN2)begin
		SLOS1_Total_With_sync.push_back(1);
		GEN2_Recieved_SLOS2.push_back(1);
		SLOS1_Total_With_sync.push_back(0);
		GEN2_Recieved_SLOS2.push_back(0);
		repeat(64)begin
			SLOS1_Total_With_sync.push_back(SLOS1_total[i]);
			GEN2_Recieved_SLOS2.push_back(Temp_GEN2_Recieved_SLOS2[i]);
			i++;
		end
	end

end
$display("SLOS1_Total_With_sync size =%0d and SLOS1_Total_With_sync is= %p",SLOS1_Total_With_sync.size(),SLOS1_Total_With_sync);
//////////////////////////////

$display("the value of recieved_SLOS1_lane1 is =%p",recieved_SLOS1_lane1);
//----compare----//
case (speed)
	gen2:begin
		foreach(SLOS1_Total_With_sync[k])
		begin
			if(SLOS1_Total_With_sync[k] ==recieved_SLOS1_lane1[k])begin
			end
			else
			$display("[ELEC MONITOR] SLOS1_Total_With_sync[%0d] =%0d and recieved_SLOS1_lane1[%0d] =%0d on gen2",k,SLOS1_Total_With_sync[k],k,recieved_SLOS1_lane1[k]);
		end
		end
	gen3:begin 
		foreach(SLOS1_Total_With_sync[k])begin
			if(SLOS1_Total_With_sync[k] ==recieved_SLOS1_lane1[k])begin
			end
			else
			$display("[ELEC MONITOR] SLOS1_Total_With_sync[%0d] =%0d and recieved_SLOS1_lane1[%0d] =%0d on gen3",k,SLOS1_Total_With_sync[k],k,recieved_SLOS1_lane1[k]);
		end
		end
	endcase


	case (speed)
	gen2:begin
		if((SLOS1_Total_With_sync==recieved_SLOS1_lane1) && (SLOS1_Total_With_sync==recieved_SLOS1_lane0))	
		begin
		$display("[ELEC MONITOR]************** SLOS1 is CORRECT ON GEN2*******************");
		foreach(SLOS1_Total_With_sync[i])begin
		GEN2_Recieved_SLOS1[i] =SLOS1_Total_With_sync[i];
		end
		wait(env_cfg_mem.done == 1);
		mon_2_Sboard_trans=new();
		//env_cfg_mem.done=0;
		env_cfg_mem.correct_OS ='b1;    //do that on all first OS on each gen
		mon_2_Sboard_trans.phase=3'd4;
		mon_2_Sboard_trans.gen_speed=gen2;
		mon_2_Sboard_trans.o_sets=SLOS1;
		mon_2_Sboard_trans.sbtx='b1;
		mon_2_Sboard_trans.tr_os=ord_set;
		mon_2_Sboard_trans.lane=both;
		elec_mon_2_Sboard.put(mon_2_Sboard_trans);

		end
		else	
		$error("[ELEC MONITOR]SLOS1 is NOT CORRECT ON GEN 2");
		end
	gen3:begin 
			if((SLOS1_Total_With_sync==recieved_SLOS1_lane0) && (SLOS1_Total_With_sync==recieved_SLOS1_lane1))
		begin
		$display("[ELEC MONITOR]************** SLOS1 is CORRECT ON GEN3*******************");
		foreach(SLOS1_Total_With_sync[i])begin
		GEN3_Recieved_SLOS1[i] =SLOS1_Total_With_sync[i];
		end
		wait(env_cfg_mem.done == 1);
		mon_2_Sboard_trans=new();
		//env_cfg_mem.done=0;
		env_cfg_mem.correct_OS=1;   //do that on all first OS on each gen
		mon_2_Sboard_trans.phase=3'd4;
		mon_2_Sboard_trans.gen_speed=gen3;
		mon_2_Sboard_trans.o_sets=SLOS1;
		mon_2_Sboard_trans.sbtx='b1;
		mon_2_Sboard_trans.tr_os=ord_set;
		mon_2_Sboard_trans.lane=both;
		elec_mon_2_Sboard.put(mon_2_Sboard_trans);
		end
		else	
		$error("[ELEC MONITOR]SLOS1 is NOT CORRECT on gen3");
	end
	endcase
	
	
	//$stop;
	endtask:recieved_SLOS1_gen23


	//task to check the AT transaction
	task electrical_layer_monitor::check_AT_transaction(input  [9:0] q[$],tr_type trans_type);
		mon_2_Sboard_trans=new();
	case(trans_type)
	AT_cmd:begin
		if(q[0] =={<<{stop_bit,DLE,start_bit}} && q[$-1]=={<<{stop_bit,DLE,start_bit}}
			&& q[1]=={<<{stop_bit,STX_cmd,start_bit}}&&q[$]=={<<{stop_bit,ETX,start_bit}})  //check the data later
			begin
			$display("[ELEC MONITOR] AT_CMD transaction is CORRECT");
			mon_2_Sboard_trans.transaction_type=AT_cmd;
			mon_2_Sboard_trans.read_write=recieved_transaction_data_symb[3][1];

			mon_2_Sboard_trans.crc_received[15:8] = {<<{recieved_transaction_data_symb[5][8:1]}}; //check crc on scoreboard
			mon_2_Sboard_trans.crc_received[7:0] = {<<{recieved_transaction_data_symb[4][8:1]}};
			mon_2_Sboard_trans.address = {<<{recieved_transaction_data_symb[2][8:1]}};
			mon_2_Sboard_trans.len = {<<{recieved_transaction_data_symb[3][8:2]}};
			mon_2_Sboard_trans.phase=3'd3;
			//error warning
			$display("the value of crc is=%0d",mon_2_Sboard_trans.crc_received);
			$display("[ELEC MONITOR] the value of mon_2_Sboard_trans %p",mon_2_Sboard_trans.convert2string());
			end 
			else
			$display("[ELEC MONITOR]AT_cmd transaction is NOT CORRECT");
	end
	AT_rsp:begin
		if(q[0] =={<<{stop_bit,DLE,start_bit}} && q[$-1]=={<<{stop_bit,DLE,start_bit}}
			&& q[1]=={<<{stop_bit,STX_rsp,start_bit}} /*&& q[$]=={<<{stop_bit,ETX,start_bit}}*/)  //check the data later
			begin
			$display("[ELEC MONITOR]AT_rsp transaction is correct");
			mon_2_Sboard_trans.transaction_type=AT_rsp;
			mon_2_Sboard_trans.read_write=recieved_transaction_data_symb[3][1];

			mon_2_Sboard_trans.crc_received[15:8] = {<<{recieved_transaction_data_symb[8][8:1]}}; //check crc on scoreboard
			mon_2_Sboard_trans.crc_received[7:0] = {<<{recieved_transaction_data_symb[7][8:1]}};
			mon_2_Sboard_trans.address = {<<{recieved_transaction_data_symb[2][8:1]}};
			mon_2_Sboard_trans.len = {<<{recieved_transaction_data_symb[3][8:2]}};
			mon_2_Sboard_trans.phase=3'd3;  
			mon_2_Sboard_trans.cmd_rsp_data={{<<{q[6][8:1]}},{<<{q[5][8:1]}},{<<{q[4][8:1]}}};

			env_cfg_mem.done = 1;
			
			end
		else
		begin
			$display("[ELEC MONITOR]AT_rsp transaction is %0p",q);
			$error("at time(%0t)[ELEC MONITOR]AT_rsp transaction is not correct",$time);
		end
	end
	endcase
    elec_mon_2_Sboard.put(mon_2_Sboard_trans);
	//$display("[ELEC MONITOR]MONITOR SENT TO SBOARD");
	endtask:check_AT_transaction

//task to get the transport data
 task electrical_layer_monitor::get_transport_data(input GEN speed);
                    trans_to_ele_lane0.push_back(ELEC_vif.lane_0_tx);
					trans_to_ele_lane1.push_back(ELEC_vif.lane_1_tx);
					if(trans_to_ele_lane0.size()==8)
					begin
						foreach(trans_to_ele_lane0[i])
						begin
                        mon_2_Sboard_trans.transport_to_electrical[i]=trans_to_ele_lane0[i];
						end
						elec_mon_2_Sboard.put(mon_2_Sboard_trans);
						foreach(mon_2_Sboard_trans.transport_to_electrical[i])
						begin
                        mon_2_Sboard_trans.transport_to_electrical[i]=trans_to_ele_lane1[i];
						end
						elec_mon_2_Sboard.put(mon_2_Sboard_trans);
                        trans_to_ele_lane0.delete();
					    trans_to_ele_lane1.delete();
					end
 endtask:get_transport_data

       ////***run task***/////
  task electrical_layer_monitor::run();
     mon_2_Sboard_trans=new();
      
        fork 
          begin  //thread to monitor(sbtx high) 
		  forever 
		  begin
		  @(posedge ELEC_vif.sbtx)
		  wait(env_cfg_mem.ready_phase2==1) //wait for the ready_phase2 from the sequance
		  env_cfg_mem.ready_phase2=2;
		  $display("[ELEC MONITOR] CHECKING THE VALUES OF SBTX AT PHASE 2"); //active on simulation
          //#1                      //to make sure that the sbtx is high not pulse only(must wait 25us after the sbtx is high check the spec)
          if(ELEC_vif.sbtx==1'b1 )  //last condition in for do body at the second phase only 
		  begin
		  mon_2_Sboard_trans.phase=3'd0;
		  mon_2_Sboard_trans.sbtx =1'b1;
		  elec_mon_2_Sboard.put(mon_2_Sboard_trans);
		  end
          end
		  end

          begin  //thread to monitor (transaction and disconnect)
		  forever
		   begin
           wait(env_cfg_mem.data_income == 1)
		   $display("[ELEC_MONITOR]the value of env_cfg_mem.data_income=%0d and the value of env_cfg_mem.phase=%0d ",env_cfg_mem.data_income,env_cfg_mem.phase); //active on simulation
		   env_cfg_mem.data_income=0;
			case (env_cfg_mem.phase)  //enum
			3'd2: //wait AT_Cmd transaction with size=8 symbols
			begin
				@(!ELEC_vif.sbtx)  //it will come with sb clk at first posedge clk
				//case
				while(1)
					begin
						@(negedge ELEC_vif.SB_clock);
						recieved_transaction_byte.push_back(ELEC_vif.sbtx);  //collect AT from Sideband channel 

						if(recieved_transaction_byte.size()==10)
						begin
							recieved_transaction_data_symb.push_back({>>{recieved_transaction_byte}});  //check the corectness of the data.......
							recieved_transaction_byte.delete();
							/*$display("[ELEC MONITOR]the value of recieved_transaction_data_symb=%p",recieved_transaction_data_symb);
							//$display("[ELEC MONITOR]the size of recieved_transaction_data_symb=%0d",recieved_transaction_data_symb.size());
							//$display("[ELEC MONITOR]the value of recieved_transaction_data_symb[7]=%p",recieved_transaction_data_symb[7]);
							if(recieved_transaction_data_symb.size()==8 &&(recieved_transaction_data_symb[7]=={<<{1'b1,8'h40,1'b0}}))
							 begin
								$display("[ELEC MONITOR]reiceved AT_cmd with size of AT 8 symbols");
							 end*/
							///////////////////////////////////////////////////////////////////////////////////////////
							if(recieved_transaction_data_symb.size()==8 &&recieved_transaction_data_symb[7]=={<<{1'b1,ETX,1'b0}}) 
							 begin
								$display("[ELEC MONITOR]reiceved AT_cmd with size of AT 8 symbols");
								break;
							 end
							else if(recieved_transaction_data_symb.size()>8)
							 begin
								$display("[ELEC MONITOR]the size of AT transaction is more than 8 symbols");
							 end

						end
					end
               check_AT_transaction(recieved_transaction_data_symb,AT_cmd);
               

           end
          3'd3: //wait for order sets 
          begin
            case (env_cfg_mem.transaction_type)
              LT_fall: begin   //wait for LT fall reaction on the dut
                @(negedge ELEC_vif.sbtx)
				#(tDisconnectTx);
				if(!ELEC_vif.lane_0_tx && !ELEC_vif.lane_1_tx && !ELEC_vif.enable_rs)begin
				$display("[ELEC MONITOR] LT fall is correct");
				mon_2_Sboard_trans.sbtx='b0;
				mon_2_Sboard_trans.transport_to_electrical='b0;
				mon_2_Sboard_trans.phase=3'd3;
				elec_mon_2_Sboard.put(mon_2_Sboard_trans); 
				end
				else
				$display("[ELEC MONITOR] LT fall is not correct");
              end
              AT_cmd: begin //wait AT response then os depend on generation
			  fork
					begin
					@(!ELEC_vif.sbtx)  //it will come with sb clk at first posedge clk
					recieved_transaction_byte.delete();
					recieved_transaction_data_symb.delete();
					while(1)
					begin
						@(negedge ELEC_vif.SB_clock);
						recieved_transaction_byte.push_back(ELEC_vif.sbtx);  //collect AT from Sideband channel 

						if(recieved_transaction_byte.size()==10)
						begin
							//$display("[ELEC MONITOR]the value of recieved_transaction_byte=%p",recieved_transaction_byte);
							recieved_transaction_data_symb.push_back({>>{recieved_transaction_byte}});  //check the corectness of the data.......
							recieved_transaction_byte.delete();
							/*$display("[ELEC MONITOR]the value of recieved_transaction_data_symb=%p",recieved_transaction_data_symb);
							//$display("[ELEC MONITOR]the size of recieved_transaction_data_symb=%0d",recieved_transaction_data_symb.size());
							//$display("[ELEC MONITOR]the value of recieved_transaction_data_symb[7]=%p",recieved_transaction_data_symb[7]);
							if(recieved_transaction_data_symb.size()==8 &&(recieved_transaction_data_symb[7]=={<<{1'b1,8'h40,1'b0}}))
							 begin
								$display("[ELEC MONITOR]reiceved AT_cmd with size of AT 8 symbols");
							 end*/
							///////////////////////////////////////////////////////////////////////////////////////////
							if(recieved_transaction_data_symb.size()==11 /*&&recieved_transaction_data_symb[10]=={<<{1'b1,ETX,1'b0}}*/) 
							 begin
								$display("[ELEC MONITOR]reiceved AT_rsp with size of AT 11 symbols");
								break;
							 end
							else if(recieved_transaction_data_symb.size()>11)
							 begin
								$error("[ELEC MONITOR]the size of AT rsp transaction is more than 11 symbols");
							 end

						end
					end
				     check_AT_transaction(recieved_transaction_data_symb,AT_rsp);
					end
					begin
						wait(ELEC_vif.enable_rs ==1)
						$display("at time(%0d),[ELEC MONITOR]wait first OS after AT_rsp transaction at env_cfg_mem.gen_speed =%0p",$time,env_cfg_mem.gen_speed);
						$display("at time(%0d)[ELEC MONITOR]enable_rs=1",$time);
						case(env_cfg_mem.gen_speed)  //wait first type of os depend on generation
						gen2:begin
							recieved_SLOS1_gen23(gen2);  ///check after part_2 in all cases
							end
						gen3:begin
							recieved_SLOS1_gen23(gen3);
							end
						gen4:begin
							recieved_TS1_gen4();
							end
							endcase
					end
			  join
              end
              AT_rsp: begin  //won't recieve any thing  
			end
			endcase
		  end
          3'd4: //wait os accourded to the transaction (last os another thread will recieve)
          begin
			$display("[ELEC MONITOR]wait OS type %0p at env_cfg_mem.gen_speed =%0p",(env_cfg_mem.o_sets),env_cfg_mem.gen_speed);
			//wait(ELEC_vif.enable_rs ==1)
			case(env_cfg_mem.gen_speed)
			gen2:begin
				case(env_cfg_mem.o_sets)
				SLOS1:
				begin
                recieved_SLOS2_gen23(gen2);
				end
				SLOS2:
				begin
					recieved_TS12_gen23(gen2,TS1_gen2_3);
				end
				TS1_gen2_3:
				begin
					recieved_TS12_gen23(gen2,TS2_gen2_3);
				end
				TS2_gen2_3:begin
					recieved_TS12_gen23(gen2,TS2_gen2_3);   //need to modify like GEN4
				end
				endcase
			    end
			    
			gen3:begin
			// wait(ELEC_vif.enable_rs ==1)
			 case(env_cfg_mem.o_sets)
				SLOS1:
				begin
				//@(ELEC_vif.enable_rs);	
                 recieved_SLOS2_gen23(gen3);
				end
				SLOS2:
				begin
					//@(ELEC_vif.enable_rs);
					recieved_TS12_gen23(gen3,TS1_gen2_3);
				end
				TS1_gen2_3:
				begin
					//@(ELEC_vif.enable_rs);
					recieved_TS12_gen23(gen3,TS2_gen2_3);
				end
				TS2_gen2_3:begin
					//@(ELEC_vif.enable_rs);
					recieved_TS12_gen23(gen3,TS2_gen2_3);   //need to modify like GEN4
				end
				
				endcase
			end
			gen4:begin 
				case(env_cfg_mem.o_sets)
                  TS1_gen4:begin
					$display("[ELEC MONITOR]waittttttttttttttt");
					$display("[ELEC MONITOR] enable_rs =1 on recieving TS2_gen4");
					recieved_TS234_gen4(TS2_gen4,0); 
				  end
				  TS2_gen4:begin 
					$display("[ELEC MONITOR] enable_rs =1 on recieving TS3_gen4");
					recieved_TS234_gen4(TS3,0);

				  end
				  TS3:begin 
					recieved_TS234_gen4(TS4,0); 
				  end
				  TS4:begin 
					recieved_TS234_gen4(TS4,1); 
				  end
			     endcase
				end
			endcase
		  end
		    
          3'd6: //case to disconnect
          begin
			@(negedge ELEC_vif.sbtx)
			#(tDisconnectTx);
			if(!ELEC_vif.sbtx && !ELEC_vif.lane_0_tx && !ELEC_vif.lane_1_tx && !ELEC_vif.enable_rs)
			begin
				$display("[ELEC MONITOR]DISCONNECT IS SUCCEESS");
				mon_2_Sboard_trans.sbtx='b0;
                mon_2_Sboard_trans.transport_to_electrical='b0;
				
				elec_mon_2_Sboard.put(mon_2_Sboard_trans);
			end
			else	
			begin
				$error("[ELEC MONITOR] DISCONNECT IS FAIL");
			end
          end
		  
          endcase 
		  end
          end
		  
			//***this thread check it after reciecve on descision***//
          begin  //in case data sent from transport layer to electrical
		  @(ready_to_recieved_data)  //note forget to put it up
		  //speed_mailbox.get(speed);  //queue to get the speed
		  $display("[ELEC MONITOR] readyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy");
		  speed=gen4;
		  //$stop;
		  while(ELEC_vif.sbtx)begin
          if(ELEC_vif.enable_rs) //defind event 
          begin
          case(speed)
            gen2: begin
				 @(negedge ELEC_vif.gen2_lane_clk);
                get_transport_data(speed);
               
            end
            gen3: begin
				@(negedge ELEC_vif.gen3_lane_clk);
                 get_transport_data(speed);
                
            end
            gen4: begin
				 @(negedge ELEC_vif.gen4_lane_clk);
                 get_transport_data(speed);
               
            end
          endcase
            
          
          end
		  end
		  end

        join
      
		 endtask





