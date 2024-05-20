class elec_scoreboard;
 
    elec_layer_tr model_tr,
                  monitor_tr,
                  gen_tr;
    env_cfg_class env_cfg_mem;

    event recieved_on_elec_sboard;

    // Mailboxes for module and monitor transactions
    mailbox #(elec_layer_tr) elec_mod_sboard,
                             elec_mon_sboard,
                             ele_generator_sboard;
    
    // Constructor
    function new(mailbox #(elec_layer_tr) elec_mod_sboard ,
                           elec_mon_sboard, ele_generator_sboard,
                           env_cfg_class env_cfg_mem);
        this.elec_mod_sboard = elec_mod_sboard;
        this.elec_mon_sboard = elec_mon_sboard;
        this.ele_generator_sboard  =ele_generator_sboard;
        this.env_cfg_mem=env_cfg_mem;  //check it
        
    endfunction: new

    // Main task to run the scoreboard
    task run();
        forever begin

         fork
            begin
                elec_mon_sboard.get(monitor_tr);
                $display("\n[ELEC SCOREBOARD FROM DUT] at time (%t) is: %p",$time ,monitor_tr.convert2string());
                
                // elec_mod_sboard.get(model_tr);
                // $display("\n[ELEC SCOREBOARD FROM MODEL] at time (%t) is: %p",$time ,model_tr.convert2string());
               /*
                case (monitor_tr.phase)
                3'd0: begin
                       assert (model_tr.sbtx == monitor_tr.sbtx)
                            $display("[ELEC SCOREBOARD] CORRECT SBTX HIGH ");
                        else $error("[[ELEC SCOREBOARD] case sbtx=1 is failed!");
                end
               3'd2:begin                  //check on AT_Cmd transaction 
                    assert (model_tr.transaction_type == monitor_tr.transaction_type)
                        else $error("[ELEC SCOREBOARD] case transaction_type is failed!");
                    assert (model_tr.cmd_rsp_data == monitor_tr.cmd_rsp_data)
                        else $error("[ELEC SCOREBOARD] case cmd_rsp_data is failed!");
                    assert (model_tr.crc_received == monitor_tr.crc_received)
                        else $error("[ELEC SCOREBOARD] case crc_received is failed!");
                    assert (model_tr.len == monitor_tr.len)
                        else $error("[ELEC SCOREBOARD] case len is failed!");
                    assert (model_tr.address == monitor_tr.address)
                        else $error("[ELEC SCOREBOARD] case address is failed!");
                    assert (model_tr.read_write == monitor_tr.read_write)
                        else $error("[ELEC SCOREBOARD] case read_write is failed!");

                end

                3'd3:begin
                    case(monitor_tr.transaction_type)
                    LT_fall:begin
                            assert ((model_tr.sbtx == monitor_tr.sbtx)&&(model_tr.transport_to_electrical == monitor_tr.transport_to_electrical))
                            else $error("[ELEC SCOREBOARD] (LT_FALL)case sbtx is failed!");
                    end
                    AT_cmd,AT_rsp:begin   //recieve the AT_cmd transaction
                       assert (model_tr.transaction_type == monitor_tr.transaction_type)
                            else $error("[ELEC SCOREBOARD] (%p)case transaction_type is failed!",model_tr.transaction_type);
                        assert (model_tr.crc_received == monitor_tr.crc_received)
                            else $error("[ELEC SCOREBOARD] (%p)case crc_received is failed!",model_tr.transaction_type);
                        assert (model_tr.len == monitor_tr.len)
                            else $error("[ELEC SCOREBOARD] (%p)case len is failed!",model_tr.transaction_type);
                        assert (model_tr.address == monitor_tr.address)
                            else $error("[ELEC SCOREBOARD] (%p)case address is failed!",model_tr.transaction_type);
                        assert (model_tr.read_write == monitor_tr.read_write)
                            else $error("[ELEC SCOREBOARD] (%p)case read_write is failed!",model_tr.transaction_type);
                        if(monitor_tr.transaction_type==AT_rsp)
                        begin
                            assert (model_tr.cmd_rsp_data == monitor_tr.cmd_rsp_data)
                            else $error("[ELEC SCOREBOARD] (%p)case cmd_rsp_data is failed!",model_tr.transaction_type);
                        end 
                        ->recieved_on_elec_sboard;
                    end
                    endcase
                end

                3'd4:begin
                    case(monitor_tr.o_sets)
                    SLOS1,SLOS2,TS1_gen2_3,TS2_gen2_3:begin
                        assert ((model_tr.sbtx == monitor_tr.sbtx)&&
                                (model_tr.lane== monitor_tr.lane) &&
                                (model_tr.tr_os== monitor_tr.tr_os) &&
                                (model_tr.o_sets== monitor_tr.o_sets) &&
                                (model_tr.gen_speed== monitor_tr.gen_speed))
                                $display("[ELEC SCOREBOARD] (%p)OS send is correct!",model_tr.o_sets);
                        else $error("[ELEC SCOREBOARD] (SLOS1)case sbtx is failed!");
                    end
                    TS1_gen4, TS2_gen4, TS3, TS4:begin
                        assert ((model_tr.sbtx == monitor_tr.sbtx)&&
                                (model_tr.lane== monitor_tr.lane) &&
                                (model_tr.tr_os== monitor_tr.tr_os) &&
                                (model_tr.o_sets== monitor_tr.o_sets) &&
                                (model_tr.gen_speed== monitor_tr.gen_speed))
                                $display("[ELEC SCOREBOARD] (%p)OS send is correct!",model_tr.o_sets);
                        else $error("[ELEC SCOREBOARD] (SLOS2)case sbtx is failed!");
                    end

                    endcase
                    ->recieved_on_elec_sboard;
                end

                //***this thread check it after reciecve on descision***/
 /*               3'd5:begin
                    assert ((model_tr.sbtx == monitor_tr.sbtx)&&(model_tr.transport_to_electrical== monitor_tr.transport_to_electrical))
                            $display("[ELEC SCOREBOARD] transport data send is correct!");
                        else $error("[ELEC SCOREBOARD] case transport data CONNECT is failed!");
                end


                3'd6:begin
                    assert ((model_tr.sbtx == monitor_tr.sbtx)&&
                            (model_tr.transport_to_electrical== monitor_tr.transport_to_electrical))
                            $display("[ELEC SCOREBOARD] DISCONNECT send is correct!");
                        else $error("[ELEC SCOREBOARD] case DISCONNECT is failed!");

                end

                endcase
*/              env_cfg_mem.recieved_on_elec_sboard=1;
            end

            begin  
                ele_generator_sboard.get(gen_tr);
                env_cfg_mem.phase=gen_tr.phase;
                env_cfg_mem.transaction_type=gen_tr.transaction_type;
                env_cfg_mem.gen_speed=gen_tr.gen_speed;
                env_cfg_mem.o_sets=gen_tr.o_sets;
                env_cfg_mem.data_income=1;
            end
         join
        end
    endtask






//--------for test model only -----------//
    
    // Main task to run the scoreboard
    task run_m();
            begin
                elec_mod_sboard.get(monitor_tr);
                $display("\n[ELEC SCOREBOURD FROM MODEL]at time (%t) is : %p", $time ,model_tr.convert2string());
            end
    endtask
endclass
 






/*class parent;
function void f1;
$display("hello");
endfunction
virtual function void f2;
$display("hello");
endfunction
endclass

class child extends parent;
function void f1;
$display("hi");
endfunction
function void f2;
$display("hi");
endfunction
endclass  

module x;
parent p=new;
child c=new;

initial 
begin
p.f1;
p.f2;
p=c;
p.f1;
p.f2;
end 
endmodule*/