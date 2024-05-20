typedef enum logic [2:0] {None = 3'b00, LT_fall, AT_cmd, AT_rsp, LT_fall_wrong, AT_cmd_wrong, AT_rsp_wrong} tr_type;
typedef enum logic [3:0] {SLOS1 = 4'b1000, SLOS2, TS1_gen2_3, TS2_gen2_3, TS1_gen4, TS2_gen4, TS3, TS4} OS_type;
typedef enum logic [1:0] {none = 2'b00, tr, ord_set} tr_os_type; // indicates whether the driver will send transaction or ordered set
typedef enum logic [1:0] {gen2, gen3, gen4} GEN; // indicates the generation
typedef enum logic [1:0] {NONE = 2'b00, lane_0, lane_1, both} LANE; // indicates which lane received the transaction

class elec_layer_tr;

	//General Components
	rand tr_type transaction_type; // NONE / LT_FALL/ AT_cmd / AT_RSP  
	//rand var [2:0] LT_type; // type of LT transaction
	rand var read_write ; // read/write operation
	rand var [7:0] address; // Address of the register being read from or written to
	rand var [6:0] len; //	Number of bytes to read/write.  Shall not be greater than 64.
	rand var [23:0] cmd_rsp_data; // data to be read or written ( Gen speed, ....)
								  //Length in standard: Not more than 64 bytes (we assumed 3 bytes only for simplicity).
								  
	rand GEN gen_speed; 	// indicates the generation
	rand OS_type o_sets; // defines different ordered sets for different generations

	//Driver Components
	rand bit sbrx;
	rand var [15:0] electrical_to_transport; // Data sent after training between electrical layer and transport layer.
	rand var [2:0] phase; // specifies current initialization phase 
	rand tr_os_type tr_os; // indicates whether the driver will send transaction or ordered set
	bit phase_5_read_disable; // to disable the monitor in phase 5 from reading from the Lanes (if no transport layer packets are sent)
	bit send_to_UL; // to allow the driver to send data on the lanes to be received by the transport layer

	//Monitor Components
	logic sbtx;
	logic [7:0] transport_to_electrical; // Data sent after training between electrical layer and transport layer
	logic [15:0] crc_received;	//crc field received in the AT cmd and AT rsp
	logic [3:0] order; //Indicates the order of the TS recieved
	
	LANE lane;

	//constraints



	
    virtual function string convert2string();
        return $sformatf("\nTransaction:\tphase = %0d   ,\tread_write = %0d   ,\taddress = %0d   \nsbrx = %0b  ,\tsbtx = %0b \ntr_os = %p    ,\ttransaction_type = %s    ,\tcrc_received = %0d    ,\tlen = %0d   ,\tcmd_rsp_data = %0d   \no_sets = %p  ,\torder = %0d   ,\tlane = %0d,\ngen_speed = %s    ,\telectrical_to_transport = %0d    ,\tphase_5_read_disable = %0b   ,\tsend_to_UL = %0b    ,\ttransport_to_electrical = %0d \n\n  ", 
			phase, read_write, address, sbrx, sbtx, tr_os, transaction_type, crc_received, len, cmd_rsp_data, o_sets, order, lane, gen_speed, electrical_to_transport, phase_5_read_disable, send_to_UL, transport_to_electrical);
    endfunction


endclass : elec_layer_tr



