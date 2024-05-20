class env_cfg_class;
bit [2:0]   phase;
OS_type     o_sets; 
GEN         gen_speed;
tr_type     transaction_type;
bit         data_income; 
bit  [1:0]  ready_phase2; 
bit         correct_OS;
bit         recieved_on_elec_sboard;  //for recieving on elec scoreboard
bit         done;
endclass: env_cfg_class

