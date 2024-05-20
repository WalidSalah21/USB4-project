
class phase4 extends primary_steps ;
mailbox #(mem)    mem_ag ;      // internal memory agent
mem        m_transaction;   // memory transaction
elec_layer_tr    temp_elec_tr2 , temp_elec_tr3 , temp_elec_lane ;  // temporary electrical transaction
bit check_equlity ;             // check if the received two transaction are the same   



typedef enum logic [2:0]  {n_TS1,n_TS2,n_TS3,n_TS4,n_SLOS1,n_SLOS2,n_done} next_ord ;  // represent the next order set will be transmited
enum {right , wrong} status ;  // represent the status of the order sets 
next_ord   next_order ;
int i , j;

parameter        SLOS1   = 4'b1000,
                        SLOS2   = 4'b1001,
                        TS1_G2 = 4'b1010,
                        TS2_G2 = 4'b1011,
                        TS1_G4 = 4'b1100,
                        TS2_G4 = 4'b1101,
                        TS3_G4 = 4'b1110,
                        TS4_G4 = 4'b1111;

    function new(mailbox #(elec_layer_tr) elec_ag_Rx , mailbox #(elec_layer_tr) elec_ag_Tx
                         , mailbox #(mem) mem_ag , mailbox #(config_transaction) config_ag_Rx);
      this.elec_ag_Rx = elec_ag_Rx;
      this.elec_ag_Tx = elec_ag_Tx;
      this.mem_ag = mem_ag;
      this.config_ag_Rx= config_ag_Rx;

      m_transaction = new();
      temp_elec_tr3 = new();

    endfunction

    
    task  os_g4();
    begin
        //$display("we are in os_g4");
        next_order = n_TS1 ;          
        status  = wrong; 
        while (status != right)
        begin
            elec_ag_Rx.get (E_transaction);
            //$display ("E_transaction in os_g4%p ",E_transaction);
            gen4_OS();
            


        end
    end
    endtask  

    task  os_g2_3();
    begin
        //$display("we are in os_g2_3");
        next_order = n_SLOS1 ;         
        status  = wrong; 
        while (status != right)
        begin           //` ---------the generator should send the same order set 2 times //
            if (next_order != n_SLOS1) 
            begin
                elec_ag_Rx.get (E_transaction);          // first get
                //$display ("E_transaction = %p",E_transaction);
                elec_ag_Rx.get (temp_elec_tr2);          // second get
                //$display ("temp_elec_tr2 = %p",temp_elec_tr2);
                check_equlity = ((temp_elec_tr3.o_sets == E_transaction.o_sets) && (temp_elec_tr3.o_sets == temp_elec_tr2.o_sets)) ? 1 : 0 ;     //! here we should do the check cond. 
                if (check_equlity) gen2_3_OS();

                else if ((E_transaction.o_sets == SLOS1 ) && (temp_elec_tr2.o_sets == SLOS1))
                    begin
                        send_packet(SLOS2, n_TS1);
                    end
                else if ((E_transaction.o_sets == SLOS2 ) && (temp_elec_tr2.o_sets == SLOS2) && (temp_elec_tr3.o_sets == TS2_G2 ))
                    begin
                        send_packet(SLOS2, n_TS1);
                    end

                else $error ( "the received order sets are not like we wait we recieve %p not %p" , E_transaction.o_sets , temp_elec_tr3.o_sets);
            end
            else
                begin
                    elec_ag_Rx.get (E_transaction);         // for first one to know that we are in phase 4
                gen2_3_OS();
                end
        end
    end
endtask


task  gen4_OS();
        begin
            //$display("we are in gen4_OS");
            if(E_transaction.phase==4) begin    // double check in phase in case of any actions 
                if (next_order == n_TS1) 
                    send_packet(TS1_G4, n_TS2);
                else if ((E_transaction.o_sets==TS1_G4 )&&(next_order == n_TS2)) 
                    send_packet(TS2_G4, n_TS3);
                else if ((E_transaction.o_sets==TS2_G4 )&&(next_order == n_TS3)) 
                    send_packet(TS3_G4, n_TS4 );
                 else if ((E_transaction.o_sets==TS3_G4 )&&(next_order == n_TS4)) 
                     send_packet(TS4_G4, n_done );
                else if ((E_transaction.o_sets==TS4_G4 )&&(next_order == n_done)) 
                    begin
                    status=right ;
                    //$display ("\n \n ⁂ ⁂ ⁂ ⁂ training phase done ⁂ ⁂ ⁂ \n \n");
                    end
                else 
                    begin
                    next_order = n_TS1;                
                    status  = wrong; 
                    end            
                                        
                end
        end
endtask
                            
            task  gen2_3_OS();
            begin
                //$display ("the value of next_order = %p",next_order);
                //$display ("the value of temp_elec_tr3.o_sets = %p",temp_elec_tr3.o_sets);
            //$display("we are in gen2_3_OS");
            if(E_transaction.phase==4) begin
                if (next_order == n_SLOS1) 
                    send_packet(SLOS1, n_SLOS2);
                 else if ((temp_elec_tr3.o_sets ==SLOS1 )&&(next_order == n_SLOS2)) 
                    send_packet(SLOS2, n_TS1);
                 else if ((temp_elec_tr3.o_sets ==SLOS2 )&&(next_order == n_TS1)) 
                    send_packet(TS1_G2, n_TS2);
                 else if ((temp_elec_tr3.o_sets ==TS1_G2 )&&(next_order == n_TS2)) 
                    send_packet(TS2_G2, n_done);
                 else if ((temp_elec_tr3.o_sets ==TS2_G2 )&&(next_order == n_done)) 
                    begin
                    status=right ;
                    //$display ("done training phase");
                    end
                 else
                    begin
                    next_order = n_SLOS1;
                    status  = wrong; 
                    end
                
            end
        end
    endtask

    task send_SLOS1(input bit [3:0] packet);
    begin
        i=0 ;
        repeat(3) begin
            //$display("we are in send_SLOS1 (%0d) times",i);
            E_transaction.order = i;
            $cast (E_transaction.o_sets , packet);
            $cast(temp_elec_tr3.o_sets , packet);
             put_transactions ();
            i++;
        end
    end
    endtask

    task send_SLOS2(input bit [3:0] packet);
    begin
        i=0 ;
        repeat(3) begin
            //$display("we are in send_SLOS2 (%0d) times",i);
            E_transaction.order = i;
            $cast (E_transaction.o_sets , packet);
            $cast(temp_elec_tr3.o_sets , packet);
            put_transactions ();
            i++;
        end
    end
    endtask

    task send_G2_TS1_G2(input bit [3:0] packet);
    begin
        i=0 ;
        repeat(32) begin
            //$display("we are in send_G2_TS1_G2 (%0d) times",i);

            E_transaction.order = i;
            $cast (E_transaction.o_sets , packet);
            $cast(temp_elec_tr3.o_sets , packet);
            put_transactions ();
            i++;
        end
    end
    endtask

    task send_G2_TS2_G2(input bit [3:0] packet);
    begin
        i=0 ;
        repeat(16) begin
            //$display("we are in send_G2_TS2_G2 (%0d) times",i);
            E_transaction.order = i;
            $cast (E_transaction.o_sets , packet);
            $cast(temp_elec_tr3.o_sets , packet);
            put_transactions ();
            i++;
        end
    end
    endtask

    task send_G3_TS1_G2(input bit [3:0] packet);
    begin
        i=0 ;
        repeat(8) begin
            //$display("we are in send_G3_TS1_G2 (%0d) times",i);
            E_transaction.order = i;
            $cast (E_transaction.o_sets , packet);
            $cast(temp_elec_tr3.o_sets , packet);
            put_transactions ();
            i++;
        end
    end
    endtask

    task send_G3_TS2_G2(input bit [3:0] packet);
    begin
        i=0 ;
        repeat(5) begin
            //$display("we are in send_G3_TS2_G2 (%0d) times",i);
            E_transaction.order = i;
            $cast (E_transaction.o_sets , packet);
            $cast(temp_elec_tr3.o_sets , packet);
            put_transactions ();
            i++;
        end
    end
    endtask

    task send_TS1_G4(input bit [3:0] packet);
    begin
        i=0 ;
        repeat(16) begin
            //$display("we are in send_TS1_G4 (%0d) times",i);
            E_transaction.order = i;
            $cast (E_transaction.o_sets , packet);
            put_transactions ();
            i++;
        end
    end
    endtask

    task send_TS2_G4(input bit [3:0] packet);
    begin
        i=0 ;
        repeat(16) begin
            //$display("we are in send_TS2_G4 (%0d) times",i);
            E_transaction.order = i;
            $cast (E_transaction.o_sets , packet);
            put_transactions ();
            i++;
        end
    end
    endtask

    task send_TS3_G4(input bit [3:0] packet);
    begin   
        i=0 ;
        repeat(16) begin
            //$display("we are in send_TS3_G4 (%0d) times",i);
            E_transaction.order = i;
            $cast (E_transaction.o_sets , packet);
            put_transactions ();
            i++;
        end
    end
    endtask

    task send_TS4_G4(input bit [3:0] packet);
    begin
        i=0 ;
        repeat(16) begin
            //$display("we are in send_TS4_G4 (%0d) timess",i);
            E_transaction.order = i;
            $cast (E_transaction.o_sets , packet);
            put_transactions ();
            i++;
        end
    end
    endtask


    task send_packet(input bit [3:0] packet, input next_ord next);
    begin
        //$display("we are in send_packet");
        //$display ("m_transaction %p ",m_transaction);
        

        case (E_transaction.gen_speed)
            gen2: begin
                E_transaction = new();

                //$display("we are in gen2"); 
                case (packet)
                    SLOS1: send_SLOS1(packet);              // send SLOS1 packet 2 times
                    SLOS2: send_SLOS2(packet);             // send SLOS2 packet 2 times
                    TS1_G2: send_G2_TS1_G2(packet);  // send TS1_G2 packet 32 times
                    TS2_G2: send_G2_TS2_G2(packet); // send TS2_G2 packet 16 times
                endcase
            end
            gen3: begin
                E_transaction = new();
                //$display("we are in gen3");
                case (packet)
                    SLOS1: send_SLOS1(packet);               // send SLOS1 packet 2 times
                    SLOS2: send_SLOS2(packet);              // send SLOS2 packet 2 times
                    TS1_G2: send_G3_TS1_G2(packet);   // send TS1_G2 packet 16 times
                    TS2_G2: send_G3_TS2_G2(packet);  // send TS2_G2 packet 8 times
                endcase
            end
            gen4: begin
                E_transaction = new();
                //$display("we are in gen4");
                case (packet)
                    TS1_G4: send_TS1_G4(packet);          // send TS1_G4 packet 16 times 
                    TS2_G4: send_TS2_G4(packet);         // send TS2_G4 packet 16 times
                    TS3_G4: send_TS3_G4(packet);        // send TS3_G4 packet 16 times
                    TS4_G4: send_TS4_G4(packet);       // send TS4_G4 packet 16 times
                endcase
            end
        endcase
    
        next_order = next;
    end
    endtask

    task  get_transactions();

         elec_ag_Rx.peek (E_transaction);    //We make that peek since we need to sbrx action case 
         config_ag_Rx.try_get(C_transaction);
         //$display ("in phase4 C_transaction = %p",C_transaction);
         //$display ("in phase4 E_transaction = %p",E_transaction);
         mem_ag.try_get(m_transaction); 


    endtask

    task put_transactions ();

        E_transaction.lane= lane_0 ;
        E_transaction.sbtx = 1;
        // here we use ""shallow copy""" , not to share the same memory for both transactions
        temp_elec_lane = new E_transaction ;        // this temp transaction for not make all handels point to same object for E_transaction 
        elec_ag_Tx.put(E_transaction);      //* send in lane 0
        //$display ("in phase 4 lane_0 E_transaction = %p",E_transaction);
        E_transaction = new();

        temp_elec_lane.lane= lane_1 ;
        elec_ag_Tx.put(temp_elec_lane); //* send in lane 1
        //$display ("in phase 4 lane_1 E_transaction = %p",temp_elec_lane);
        temp_elec_lane = new();

    endtask 
    
    
    task run_phase4 () ;
    begin            

        create_transactions();
        get_transactions();


        // ----------------------- handle actions ----------------------
        if(!E_transaction.sbrx)      
                begin
                 // E_transaction.phase = 1;         //! should we go to phase 1 or 2 
                    //$display ("we are in sbrx =0 case action");
                  E_transaction.sbtx = 0;         
                  elec_ag_Tx.put(E_transaction) ;
                    E_transaction = new();
                    
                end
                else if (C_transaction.lane_disable && (E_transaction.phase == 4) ) 
                begin       
                    //$display ("we are in disable case action");
                   E_transaction.sbtx  = 0;
                   elec_ag_Tx.put(E_transaction) ;
                    E_transaction = new();

                 end

         // ----------------------- run main task ----------------------

                else if (E_transaction.phase==4 )   // we are in phase 4 
                        begin
                    if ( (m_transaction.gen4 == 1) )       // we are gen 4 send in order (TS1->TS2 ->TS3-> TS4 )
                           os_g4() ; 

                          
                          else if(( m_transaction.gen2 == 1) ||  ( m_transaction.gen3 == 1) ) // we are gen 2 or 3 send in order (SLOS1->SLOS2 ->TS1-> TS2 )
                          os_g2_3() ; 
                          
                          
                         end
    end   
    endtask 

endclass //phase 4
    
