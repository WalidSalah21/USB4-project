	class config_transaction;

		//Driver Components
		rand bit lane_disable;
		rand bit [31:0] c_data_in;


		//Monitor Components
		logic c_read, c_write;
		logic [7:0] c_address;	
		logic [31:0] c_data_out;


		
		constraint DISABLE{

			lane_disable dist {0 := 2000, 1 := 1};

		} 
	
	endclass : config_transaction

