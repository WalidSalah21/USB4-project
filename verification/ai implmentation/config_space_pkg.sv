class config_transaction;

//Driver Components
rand bit lane_disable;
rand bit [31:0] c_data_in;



//Monitor Components
logic c_read, c_write;
logic [7:0] c_address;	
logic [31:0] c_data_out;

rand var [2:0]phase;

constraint DISABLE{

	lane_disable dist {0 := 2000, 1 := 1};

} 

virtual function string convert2string();
return $sformatf("\nTransaction:\tlane_disable = %0b   ,\tc_data_in = %0d   ,\tc_read = %0b   ,\tc_write = %0b   ,\tc_address = %0d   ,\tc_data_out = %0d   ,\tphase = %0d  \n\n", 
	lane_disable, c_data_in, c_read, c_write, c_address, c_data_out, phase);
endfunction

endclass : config_transaction

