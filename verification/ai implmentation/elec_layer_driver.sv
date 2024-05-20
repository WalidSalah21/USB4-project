///************ Define the parent class inside electrical_layer_driver_pkg************///
class parent;
	parameter start_bit = 1'b0;
	parameter stop_bit = 1'b1;

	parameter [7:0] DLE = 8'hFE;	//Data Link Escape (DLE) Symbol – indicates the beginning of a Transaction. 
	parameter [7:0] ETX = 8'h40;	//End of Transaction (ETX) Symbol 

	parameter [7:0] LSE_lane0 = 8'b10000000;	//Lane State Event (LSE) - indicating LT_Fall for lane 0.
	parameter [7:0] LSE_lane1 = 8'b10100000;	//Lane State Event (LSE) - indicating LT_Fall for lane 1.
  parameter [7:0] CLSE_lane0 =~(LSE_lane0);	//Lane State Event (LSE) - indicating LT_Fall for lane 0.
	parameter [7:0] CLSE_lane1 =~(LSE_lane1);	//Lane State Event (LSE) - indicating LT_Fall for lane 1.

	parameter [7:0] STX_cmd = 8'b00000101;		//Start Transaction (STX) Symbol – defines the operation of the Transaction. 
	parameter [7:0] STX_rsp = 8'b00000100;		//Start Transaction (STX) Symbol – defines the operation of the Transaction. 


	//Constants sizes
	parameter TR_HEADER_SIZE = 20; 	// We need the first 20 bits of the transaction received to know the transaction type
	parameter MIN_TR_SIZE = 30;		//The minimum size of any transaction is 30 bits (LT Fall)
	parameter LT_TR_SIZE = 30;		//Size of the LT Transactions (30 bits)

	parameter SLOS_SIZE = 2112; // 66 * 32 = 2112 or 132 * 16 = 2112
  parameter SLOS_SIZE_IN_BYTE=(SLOS_SIZE/8);
	parameter TS_GEN_2_3_SIZE = 64;
	parameter TS_GEN_4_HEADER_SIZE = 32;
	parameter TS16_SIZE = 7168; // Size of 16 back to back TS (448 * 16 = 7168)

	parameter PRBS11_SYMBOL_SIZE = 448; // Size of the PRBS11 symbol

  //timing parameters
  parameter tConnectRx = 25;        //min is 25us
  parameter tDisconnectRx = 1500;   //max is 1000us
  parameter	tDisconnectTx =	100000; //min is 50ms


	//Ordered sets
	parameter [65:0] SLOS1_64 [0:31] = {66'b100100000000101000000100010000101010100100000001101000001110010001,
										66'b101011101011101010001010000101000100100010101101010000110000100111,
										66'b101001011100111001011110111001001010111011000010101110010000101110,
										66'b101001001010011011000111101110110010101011110000001001100001011111,
										66'b100010010001110110101101011000110001110111101101010010110000110011,
										66'b101001111110111100001010011001000111111010110000100011100101011011,
										66'b101000011010110011100011111011011000101101110100110101001111000011,
										66'b101001100110111111111010000000100100000101101000100110010101111110,
										66'b100001000011001010011111000111000110110110111011011010101101100000,
										66'b101101110001110101101101000110110010111011110010101001110000011101,
										66'b101000110101110111000101010110100000011001000011111010011000100111,
										66'b101101011100010001011010101001100000011111000011000110011110111111,
										66'b100010100001110001001101101011110110001001011101011001010001111000,
										66'b101011001101001111110011100001111011001100101111111100100000011101,
										66'b100000110100100111001101110111110101010001000000101010000100000100,
										66'b101010001011000101001110100011101001011010011001100111111111110000,
										66'b100000011000000011110000011001100011111111011000000101110000100101,
										66'b101001011001111001111100111100011110011011001111101111100010100011,
										66'b100100010111001010010111000110010110111110011010001111100101100011,
										66'b101001110110111101011010010001100110101111111000100000110101000111,
										66'b100000101101100100110111101111010010100100110001101111101110100010,
										66'b101010010100000110001000111101010110010000011110100011001001011111,
										66'b100110010001011110101001001000011011010011101100111010111110100010,
										66'b100010010101010110000000011100000011011000011101110011010101111100,
										66'b100001000110001010111101000010010010010110110110011011011111101101,
										66'b100000101100100100111101101110010110101110011000101111110100100001,
										66'b100011010010111100110010011111110111000001010110001000011101010011,
										66'b100100001111001001100111011111110101000001000010001010010101000110,
										66'b100000101111000100100110101101111000110100110111001111010111100100,
										66'b100100111010101110100000101001000100011010101011100000001011000001,
										66'b100011100010111011010010101100110000111111100110000011111100011000,
										66'b100110111100111010011110100111001001110111011101010101010000000000};


	parameter [2111:0] SLOS1_64_1 = {	SLOS1_64[31], SLOS1_64[30], SLOS1_64[29], SLOS1_64[28], SLOS1_64[27], SLOS1_64[26], SLOS1_64[25], SLOS1_64[24], 
										SLOS1_64[23], SLOS1_64[22], SLOS1_64[21], SLOS1_64[20], SLOS1_64[19], SLOS1_64[18], SLOS1_64[17], SLOS1_64[16], 
										SLOS1_64[15], SLOS1_64[14], SLOS1_64[13], SLOS1_64[12], SLOS1_64[11], SLOS1_64[10], SLOS1_64[9], SLOS1_64[8], 
										SLOS1_64[7], SLOS1_64[6], SLOS1_64[5], SLOS1_64[4], SLOS1_64[3], SLOS1_64[2], SLOS1_64[1], SLOS1_64[0]};


	parameter [65:0] SLOS2_64 [0:31] = {66'b101011111111010111111011101111010101011011111110010111110001101110,
										66'b100100010100010101110101111010111011011101010010101111001111011000,
										66'b100110100011000110100001000110110101000100111101010001101111010001,
										66'b100110110101100100111000010001001101010100001111110110011110100000,
										66'b101101101110001001010010100111001110001000010010101101001111001100,
										66'b100110000001000011110101100110111000000101001111011100011010100100,
										66'b100111100101001100011100000100100111010010001011001010110000111100,
										66'b100110011001000000000101111111011011111010010111011001101010000001,
										66'b101110111100110101100000111000111001001001000100100101010010011111,
										66'b100010001110001010010010111001001101000100001101010110001111100010,
										66'b100111001010001000111010101001011111100110111100000101100111011000,
										66'b100010100011101110100101010110011111100000111100111001100001000000,
										66'b101101011110001110110010010100001001110110100010100110101110000111,
										66'b100100110010110000001100011110000100110011010000000011011111100010,
										66'b101111001011011000110010001000001010101110111111010101111011111011,
										66'b100101110100111010110001011100010110100101100110011000000000001111,
										66'b101111100111111100001111100110011100000000100111111010001111011010,
										66'b100110100110000110000011000011100001100100110000010000011101011100,
										66'b101011101000110101101000111001101001000001100101110000011010011100,
										66'b100110001001000010100101101110011001010000000111011111001010111000,
										66'b101111010010011011001000010000101101011011001110010000010001011101,
										66'b100101101011111001110111000010101001101111100001011100110110100000,
										66'b101001101110100001010110110111100100101100010011000101000001011101,
										66'b101101101010101001111111100011111100100111100010001100101010000011,
										66'b101110111001110101000010111101101101101001001001100100100000010010,
										66'b101111010011011011000010010001101001010001100111010000001011011110,
										66'b101100101101000011001101100000001000111110101001110111100010101100,
										66'b101011110000110110011000100000001010111110111101110101101010111001,
										66'b101111010000111011011001010010000111001011001000110000101000011011,
										66'b101011000101010001011111010110111011100101010100011111110100111110,
										66'b101100011101000100101101010011001111000000011001111100000011100111,
										66'b101001000011000101100001011000110110001000100010101010101111111111};


	parameter [2111:0] SLOS2_64_1 = {SLOS2_64[31], SLOS2_64[30], SLOS2_64[29], SLOS2_64[28], SLOS2_64[27], SLOS2_64[26], SLOS2_64[25], SLOS1_64[24], 
										SLOS2_64[23], SLOS2_64[22], SLOS2_64[21], SLOS2_64[20], SLOS2_64[19], SLOS2_64[18], SLOS2_64[17], SLOS2_64[16], 
										SLOS2_64[15], SLOS2_64[14], SLOS2_64[13], SLOS2_64[12], SLOS2_64[11], SLOS2_64[10], SLOS2_64[9], SLOS2_64[8], 
										SLOS2_64[7], SLOS2_64[6], SLOS2_64[5], SLOS2_64[4], SLOS2_64[3], SLOS2_64[2], SLOS2_64[1], SLOS2_64[0]};

	
	parameter [131:0] SLOS1_128 [0:15] = {132'b101001000000001010000001000100001010101001000000011010000011100100011011101011101010001010000101000100100010101101010000110000100111,
											132'b101010010111001110010111101110010010101110110000101011100100001011101001001010011011000111101110110010101011110000001001100001011111,
											132'b101000100100011101101011010110001100011101111011010100101100001100111001111110111100001010011001000111111010110000100011100101011011,
											132'b101010000110101100111000111110110110001011011101001101010011110000111001100110111111111010000000100100000101101000100110010101111110,
											132'b101000010000110010100111110001110001101101101110110110101011011000001101110001110101101101000110110010111011110010101001110000011101,
											132'b101010001101011101110001010101101000000110010000111110100110001001111101011100010001011010101001100000011111000011000110011110111111,
											132'b101000101000011100010011011010111101100010010111010110010100011110001011001101001111110011100001111011001100101111111100100000011101,
											132'b101000001101001001110011011101111101010100010000001010100001000001001010001011000101001110100011101001011010011001100111111111110000,
											132'b101000000110000000111100000110011000111111110110000001011100001001011001011001111001111100111100011110011011001111101111100010100011,
											132'b101001000101110010100101110001100101101111100110100011111001011000111001110110111101011010010001100110101111111000100000110101000111,
											132'b101000001011011001001101111011110100101001001100011011111011101000101010010100000110001000111101010110010000011110100011001001011111,
											132'b101001100100010111101010010010000110110100111011001110101111101000100010010101010110000000011100000011011000011101110011010101111100,
											132'b101000010001100010101111010000100100100101101101100110110111111011010000101100100100111101101110010110101110011000101111110100100001,
											132'b101000110100101111001100100111111101110000010101100010000111010100110100001111001001100111011111110101000001000010001010010101000110,
											132'b101000001011110001001001101011011110001101001101110011110101111001000100111010101110100000101001000100011010101011100000001011000001,
											132'b101000111000101110110100101011001100001111111001100000111111000110000110111100111010011110100111001001110111011101010101010000000000};


	parameter [2111:0] SLOS1_128_1 = {	SLOS1_128[15], SLOS1_128[14], SLOS1_128[13], SLOS1_128[12], SLOS1_128[11], SLOS1_128[10], SLOS1_128[9], SLOS1_128[8], 
										SLOS1_128[7], SLOS1_128[6], SLOS1_128[5], SLOS1_128[4], SLOS1_128[3], SLOS1_128[2], SLOS1_128[1], SLOS1_128[0]};


	parameter [131:0] SLOS2_128 [0:15] = {	132'b101010111111110101111110111011110101010110111111100101111100011011100100010100010101110101111010111011011101010010101111001111011000,
											132'b101001101000110001101000010001101101010001001111010100011011110100010110110101100100111000010001001101010100001111110110011110100000,
											132'b101011011011100010010100101001110011100010000100101011010011110011000110000001000011110101100110111000000101001111011100011010100100,
											132'b101001111001010011000111000001001001110100100010110010101100001111000110011001000000000101111111011011111010010111011001101010000001,
											132'b101011101111001101011000001110001110010010010001001001010100100111110010001110001010010010111001001101000100001101010110001111100010,
											132'b101001110010100010001110101010010111111001101111000001011001110110000010100011101110100101010110011111100000111100111001100001000000,
											132'b101011010111100011101100100101000010011101101000101001101011100001110100110010110000001100011110000100110011010000000011011111100010,
											132'b101011110010110110001100100010000010101011101111110101011110111110110101110100111010110001011100010110100101100110011000000000001111,
											132'b101011111001111111000011111001100111000000001001111110100011110110100110100110000110000011000011100001100100110000010000011101011100,
											132'b101010111010001101011010001110011010010000011001011100000110100111000110001001000010100101101110011001010000000111011111001010111000,
											132'b101011110100100110110010000100001011010110110011100100000100010111010101101011111001110111000010101001101111100001011100110110100000,
											132'b101010011011101000010101101101111001001011000100110001010000010111011101101010101001111111100011111100100111100010001100101010000011,
											132'b101011101110011101010000101111011011011010010010011001001000000100101111010011011011000010010001101001010001100111010000001011011110,
											132'b101011001011010000110011011000000010001111101010011101111000101011001011110000110110011000100000001010111110111101110101101010111001,
											132'b101011110100001110110110010100100001110010110010001100001010000110111011000101010001011111010110111011100101010100011111110100111110,
											132'b101011000111010001001011010100110011110000000110011111000000111001111001000011000101100001011000110110001000100010101010101111111111};


	parameter [2111:0] SLOS2_128_1 = {	SLOS2_128[15], SLOS2_128[14], SLOS2_128[13], SLOS2_128[12], SLOS2_128[11], SLOS2_128[10], SLOS2_128[9], SLOS2_128[8], 
										SLOS2_128[7], SLOS2_128[6], SLOS2_128[5], SLOS2_128[4], SLOS2_128[3], SLOS2_128[2], SLOS2_128[1], SLOS2_128[0] };

 
	//Parameters for TS1 and TS2 symbols for Gen 2 and Gen 3
	parameter [7:0] lane_number_0 = 8'h00,
                  lane_number_1 = 8'h01; // To indicate the lane number (one for lane 0  and one for lane 1)
	parameter [5:0] TSID_TS1 = 6'b100110;  // To indicate TS1
	parameter [5:0] TSID_TS2 = 6'b011001;  // To indicate TS2
	parameter [9:0] SCR = 10'b0011110010;

  //Order sets TS1 and 2 for Gen 2 and 3
  parameter        TS1_gen2_3_lane0= {5'd0,3'd1,lane_number_0,32'd0,TSID_TS1,SCR};
  parameter        TS1_gen2_3_lane1= {5'd0,3'd1,lane_number_1,32'd0,TSID_TS1,SCR};
  parameter        TS2_gen2_3_lane0= {5'd0,3'd1,lane_number_0,32'd0,TSID_TS2,SCR};
  parameter        TS2_gen2_3_lane1= {5'd0,3'd1,lane_number_1,32'd0,TSID_TS2,SCR};


	//Parameters for TS symbols for Gen 4
  parameter        CURSOR = 12'h7E0;
  parameter        indication_TS1=4'h2,
                   indication_TS2=4'h4,
                   indication_TS3=4'h6;
  parameter        indication_TS4=8'hf0;
                  
  parameter        counter_TS1=8'h0f,   //check on sending the counter value from zakaria
                   counter_TS2=8'h0f,
                   counter_TS3=8'h0f;
  parameter        counter_TS4=4'hf;


   //Order sets TS1&2 for Gen4
  parameter [27:0] ts2_gen4={4'd0,counter_TS2,~(indication_TS2),indication_TS2,CURSOR};
  parameter [27:0] ts3_gen4={4'd0,counter_TS3,~(indication_TS3),indication_TS3,CURSOR};

   
	// Seeds for the Pseudo Random Sequences
	parameter [10:0] PRBS11_lane0_seed =11'b11111111111;
	parameter [10:0] PRBS11_lane1_seed =11'b11101110000;


///-------------------------///
//Order sets TS1,2,3,4 for Gen4
parameter [27:0]  HEADER_TS1_GEN4={counter_TS1,~(indication_TS1),indication_TS1,CURSOR};
parameter [27:0]  HEADER_TS2_GEN4={4'd0,counter_TS2,~(indication_TS2),indication_TS2,CURSOR};
parameter [27:0]  HEADER_TS3_GEN4={4'd0,counter_TS3,~(indication_TS3),indication_TS3,CURSOR};
parameter [27:0]  HEADER_TS4_GEN4={4'd0,~(counter_TS4),counter_TS4,indication_TS4,CURSOR};

//TASKS for genetate PRBS11 
    task automatic PRSC11(input bit [10:0] seed, input int size, output bit PRBS11_OUT[$]);
 
        // Declare OLD_D10 and OLD_D8
        bit OLD_D10;
        bit OLD_D8;

        // Declare rig_data and assign seed to it
        bit [10:0] rig_data = seed;

        // For loop with upper limit of iteration equal to the value of size input
        for (int i = 0; i < size; i++)
         begin
            // Push rig_data[10] to PRBS11_OUT
            PRBS11_OUT.push_back(rig_data[10]);

        OLD_D10=rig_data[10];
        OLD_D8=rig_data[8];

        for (int k=10;k>0;k--) begin
                 rig_data[k]=rig_data[k-1];
        end
        rig_data[0]=OLD_D10^OLD_D8;
         end

endtask: PRSC11
 endclass: parent


  ///************ Define the child class selectrical_layer_driver inside electrical_layer_driver_pkg************///
 class electrical_layer_driver extends parent;

    //declare the events
     event elec_gen_driver_done;  // Event to indicate that the driver has finished sending the transaction

    //declare the transactions
    elec_layer_tr transaction;    // Transaction to be recieved from the generator

    //declare the mailboxes
    mailbox #(elec_layer_tr) elec_drv_gen;  // Mailbox to receive the transaction from the generator

    //declare varsual interface
      virtual electrical_layer_if ELEC_vif;

    // Constructor
  function new(event  elec_gen_driver_done,mailbox #(elec_layer_tr) elec_drv_gen,virtual electrical_layer_if ELEC_vif);
    this.elec_gen_driver_done=elec_gen_driver_done;
    this.elec_drv_gen=elec_drv_gen;
    this.ELEC_vif=ELEC_vif;
  endfunction:new 
 
    /////////********** Declare the task as extern**********/////////
    //**tasks to send trasactions to the DUT**//
    extern task send_AT_cmd_OR_res_2_DUT(bit read_write = 0,bit [7:0] address = 0,
                                         bit [6:0] len = 0 ,bit [23:0] cmd_rsp_data = 0,
                                         tr_type trans_type = None);
    extern task send_LT_fall_2_DUT();
    extern task CALC_CRC(/*bit [7:0] STX,*/bit [7:0] data_symb[$], output bit [15:0] CRC_out);
    ///---------------------------///

    //**tasks to send OS to DUT**//
     extern task SLOS1_2_DUT(input GEN gen_speed);
     extern task SLOS2_2_DUT(input GEN gen_speed);
     extern task TS1_gen23_2_DUT(input GEN gen_speed);
     extern task TS2_gen23_2_DUT(input GEN gen_speed);
     extern task TS1_gen4_2_DUT();
     extern task TS2_gen4_2_DUT();
     extern task TS3_2_DUT();
     //extern task TS4_2_DUT();
     ///---------------------------///

     ///**tasks to send OS to DUT**//
     extern task  send_data_2_DUT(input logic[7:0] data_2_DUT,input GEN gen_speed
                                 ,input LANE lane);
    ///---------------------------///
    //**tasks to send Disconnect_2_DUT to DUT**//

     extern task Disconnect_2_DUT();
    ///---------------------------///
     extern task run();
     
     ///**add here task to reset the dut**///


 endclass:electrical_layer_driver


task electrical_layer_driver::Disconnect_2_DUT();
    @(negedge ELEC_vif.SB_clock);
    ELEC_vif.sbrx = 1'b0;
    #(tDisconnectRx);
endtask: Disconnect_2_DUT



///************ Define the task outside electrical_layer_driver class************///

// Task to calculate the CRC
task electrical_layer_driver::CALC_CRC(/*input bit [7:0] STX,*/ input bit [7:0] data_symb[$], output bit [15:0] CRC_out);
    bit [15:0] crc; // Initial value
    bit [15:0] poly; // Polynomial (CRC-16)
    bit [15:0] data;
    int i;
    bit [7:0] crc_high, crc_low;
    // Reverse each byte of the CRC output
    bit [7:0] crc_high_rev;
    bit [7:0] crc_low_rev;

    crc = 16'hFFFF;
    poly = 16'h8005;

    // Include STX in CRC calculation
    //data_symb.push_front(SbTX);

    // Calculate CRC
    for(i=0; i<data_symb.size(); i++) begin
      data = {8'b0, data_symb[i]};
      for(int j = 0; j < 16; j++) begin
        if((data[j] ^ crc[15]) == 1'b1) begin
          crc = crc << 1;
          crc = crc ^ poly;
        end else begin
          crc = crc << 1;
        end
      end
    end

    // Assign crc to {crc_high, crc_low}
  
    {crc_high, crc_low} = crc;



    for(i = 0; i < 8; i++) begin
      crc_high_rev[i] = crc_high[7-i];
      crc_low_rev[i] = crc_low[7-i];
    end

    CRC_out = {crc_high_rev, crc_low_rev};
  endtask

////****tasks to send transactions to the DUT****////
task electrical_layer_driver::send_AT_cmd_OR_res_2_DUT(bit read_write = 0, bit [7:0] address = 0,
                                                       bit [6:0] len = 0 , bit [23:0] cmd_rsp_data = 0,
                                                       tr_type trans_type = None);
bit [7:0] data_symb[$];
bit [7:0] CRC_DATA_Q[$];
bit [7:0] L_CRC,H_CRC;
bit [9:0] send_data_symb[$];
bit [0:9] actual_send_data_symb[$];
bit [7:0] data_rsp[2:0];
bit [7:0] conn;
int i;  //counter

conn={read_write,len};
//choose send command or response
if(trans_type==AT_cmd)
  begin
    data_symb ={DLE,STX_cmd,address,conn,DLE,ETX};
    CRC_DATA_Q=data_symb[1:$-2]; 
    CALC_CRC(CRC_DATA_Q,{H_CRC,L_CRC});
    $display("[ELEC DRIVER] the value of size data_symb ",data_symb.size());
  end

else if (trans_type==AT_rsp) 
  begin
    data_rsp={>>{cmd_rsp_data}};
    data_symb ={DLE,STX_rsp,address,data_rsp[0],data_rsp[1],data_rsp[2],conn,,DLE,ETX};
    CRC_DATA_Q=data_symb[1:$-2];   
    CALC_CRC(CRC_DATA_Q,{H_CRC,L_CRC});
  end

$display("[ELEC DEIVER]the size of data_symb is %0d in case (%p)",data_symb.size(),trans_type);
$display("[ELEC DEIVER]the values of data_symb is%p in case (%p)",data_symb,trans_type);
$display("[ELEC DEIVER]CRC_DATA_Q size= %0d", CRC_DATA_Q.size());  
data_symb.delete();

//choose send command or response
if(trans_type==AT_cmd)
begin
data_symb ={DLE,STX_cmd,address,conn,{L_CRC,H_CRC},DLE,ETX}; //zakarian check
end
else if (trans_type==AT_rsp) 
begin
  data_symb ={DLE,STX_rsp,address,conn,cmd_rsp_data,{L_CRC,H_CRC},DLE,ETX};   
end
     
     $display("[ELEC DRIVER] data_symb[%0h]",data_symb[4]);

        // Add start and end bits to each data symbol and store in send_data_symb
        foreach(data_symb[i]) begin
          send_data_symb[i] = {stop_bit, data_symb[i],start_bit};   ///ERROR///
        end
        $display("[ELEC DRIVER] actual_send_data_symb: %p",send_data_symb);
        
        // Send the data symbols to the DUT
        foreach(send_data_symb[i,j]) begin
            @(posedge ELEC_vif.SB_clock);
        // Send bit to DUT
        ELEC_vif.sbrx <= send_data_symb[i][j];
        end

endtask: send_AT_cmd_OR_res_2_DUT

task electrical_layer_driver::send_LT_fall_2_DUT(); //correct send no need to flip
bit [7:0] data_symb_lane0[3];
bit [9:0] send_data_symb_lane0[3];
bit [7:0] data_symb_lane1[3];
bit [9:0] send_data_symb_lane1[3];
bit       LT_FALL_arr[2][LT_TR_SIZE]; //array of LT_FALL symbols for lane 0 and lane 1
// Generate the LT_Fall symbols for lane 0 and lane 1
data_symb_lane0={DLE,LSE_lane0,CLSE_lane0};
data_symb_lane1={DLE,LSE_lane1,CLSE_lane1};
// Add start and end bits to each data symbol and store in send_data_symb
        foreach(data_symb_lane0[i]) begin
          bit  start = 1'b0;
          bit  stop_bit = 1'b1;
          send_data_symb_lane0[i] = {stop_bit, data_symb_lane0[i], start_bit};
          send_data_symb_lane1[i] = {stop_bit, data_symb_lane1[i], start_bit};
        end
   
  //casting arrays to 2D array
  for (int i = 0; i < 3; i++) begin
    for (int j = 0; j < 10; j++) begin
      LT_FALL_arr[0][i*10 + j] = send_data_symb_lane0[i][j];
      LT_FALL_arr[1][i*10 + j] = send_data_symb_lane1[i][j];
    end
  end
  
// Send the LT_FALL symbols to the DUT
foreach(LT_FALL_arr[i,j])
 begin
  @(posedge ELEC_vif.SB_clock);
    // Send bit to DUT
    ELEC_vif.sbrx <= LT_FALL_arr[i][j];
 end
  //->elec_gen_driver_done; // Indicate that the driver has finished sending the transaction
endtask: send_LT_fall_2_DUT


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


////****tasks to send os  to the DUT****////
task electrical_layer_driver::SLOS1_2_DUT(input GEN gen_speed);  //check it send 2 on each lane or 2 no both lanes 

if(gen_speed ==gen2) begin
      @(posedge ELEC_vif.gen2_lane_clk);
      ELEC_vif.data_incoming <=1;

      foreach (SLOS1_64_1[i])
      begin
        ELEC_vif.lane_0_rx <=SLOS1_64_1[i];
        ELEC_vif.lane_1_rx <=SLOS1_64_1[i];
        @(posedge ELEC_vif.gen2_lane_clk);
      end
    end
else if(gen_speed ==gen3) begin
    @(posedge ELEC_vif.gen3_lane_clk);
      ELEC_vif.data_incoming <=1;

      foreach (SLOS1_128_1[i])
        begin
          ELEC_vif.lane_0_rx <=SLOS1_128_1[i];
          ELEC_vif.lane_1_rx <=SLOS1_128_1[i];
          @(posedge ELEC_vif.gen3_lane_clk);
    end
end
    ELEC_vif.data_incoming <=0;
endtask: SLOS1_2_DUT

task electrical_layer_driver::SLOS2_2_DUT(input GEN gen_speed);
if(gen_speed ==gen2) begin
   @(posedge ELEC_vif.gen2_lane_clk);
   ELEC_vif.data_incoming <=1;

   foreach (SLOS2_64_1[i])
   begin
    ELEC_vif.lane_0_rx <=SLOS2_64_1[i];
    ELEC_vif.lane_1_rx <=SLOS2_64_1[i];
    @(posedge ELEC_vif.gen2_lane_clk);
   end
    end
else if(gen_speed ==gen3) begin
@(posedge ELEC_vif.gen3_lane_clk);
ELEC_vif.data_incoming <=1;
 foreach (SLOS2_128_1[i])
   begin
    ELEC_vif.lane_0_rx <=SLOS2_128_1[i];
    ELEC_vif.lane_1_rx <=SLOS2_128_1[i];
    @(posedge ELEC_vif.gen2_lane_clk);
   end
end
  ELEC_vif.data_incoming <=0;
endtask: SLOS2_2_DUT


task electrical_layer_driver::TS1_gen23_2_DUT(input GEN gen_speed);
if(gen_speed ==gen2) begin
    @(posedge ELEC_vif.gen2_lane_clk);
    ELEC_vif.data_incoming <=1;

      foreach(TS1_gen2_3_lane0[i]) begin
      ELEC_vif.lane_0_rx <=TS1_gen2_3_lane0[i];
      ELEC_vif.lane_1_rx <=TS1_gen2_3_lane1[i];
      @(posedge ELEC_vif.gen2_lane_clk);
      end
    end
    
else if(gen_speed ==gen3) begin
    @(posedge ELEC_vif.gen3_lane_clk);
    ELEC_vif.data_incoming <=1;

    foreach(TS1_gen2_3_lane0[i]) begin 
    ELEC_vif.lane_0_rx <=TS1_gen2_3_lane0[i];
    ELEC_vif.lane_1_rx <=TS1_gen2_3_lane1[i];
    @(posedge ELEC_vif.gen3_lane_clk);
    end
end
ELEC_vif.data_incoming <=0;
endtask: TS1_gen23_2_DUT


task electrical_layer_driver::TS2_gen23_2_DUT(input GEN gen_speed);
if(gen_speed ==gen2) begin
   @(posedge ELEC_vif.gen2_lane_clk);
   ELEC_vif.data_incoming <=1;

    foreach(TS2_gen2_3_lane0[i]) begin
    ELEC_vif.lane_0_rx <=TS2_gen2_3_lane0[i];
    ELEC_vif.lane_1_rx <=TS2_gen2_3_lane1[i];
    @(posedge ELEC_vif.gen2_lane_clk);
    end
    end
else if(gen_speed ==gen3) begin
    @(posedge ELEC_vif.gen3_lane_clk);
    ELEC_vif.data_incoming <=1;
    foreach(TS2_gen2_3_lane0[i]) begin 
    ELEC_vif.lane_0_rx <=TS2_gen2_3_lane0[i];
    ELEC_vif.lane_1_rx <=TS2_gen2_3_lane1[i];
    @(posedge ELEC_vif.gen3_lane_clk);
    end
end
  ELEC_vif.data_incoming <=0;
endtask: TS2_gen23_2_DUT

task electrical_layer_driver::TS1_gen4_2_DUT();
bit PRBS11_OUT_lane0[$],
    PRBS11_OUT_lane1[$];
bit trancated_PRBS11_OUT_lane0[0:419],
    trancated_PRBS11_OUT_lane1[0:419];
bit TS1_Frame_lane0 [447:0],
    TS1_Frame_lane1 [447:0];



PRSC11(PRBS11_lane0_seed,PRBS11_SYMBOL_SIZE,PRBS11_OUT_lane0); //generate PRBS11 
PRSC11(PRBS11_lane1_seed,PRBS11_SYMBOL_SIZE,PRBS11_OUT_lane1); //generate PRBS11
trancated_PRBS11_OUT_lane0=PRBS11_OUT_lane0[28:$];  //trancate the PRBS11
trancated_PRBS11_OUT_lane1=PRBS11_OUT_lane1[28:$];  //trancate the PRBS11

trancated_PRBS11_OUT_lane0.reverse();     //reverse the trancated PRBS11
trancated_PRBS11_OUT_lane1.reverse();     //reverse the trancated PRBS11

TS1_Frame_lane0={ >>{trancated_PRBS11_OUT_lane0,HEADER_TS1_GEN4}};
TS1_Frame_lane1={ >>{trancated_PRBS11_OUT_lane1,HEADER_TS1_GEN4}};

//send the TS1 symbols to the DUT
@(posedge ELEC_vif.gen4_lane_clk);
   ELEC_vif.data_incoming <=1;

    foreach(TS1_Frame_lane0[i]) begin
    ELEC_vif.lane_0_rx <=TS1_Frame_lane0[i];
    ELEC_vif.lane_1_rx <=TS1_Frame_lane1[i];
    @(posedge ELEC_vif.gen4_lane_clk);
    end
    ELEC_vif.data_incoming <=0;
endtask: TS1_gen4_2_DUT

task electrical_layer_driver::TS2_gen4_2_DUT();

@(posedge ELEC_vif.gen4_lane_clk)
   ELEC_vif.data_incoming <=1;

   foreach(HEADER_TS2_GEN4[i])
    begin
    ELEC_vif.lane_0_rx <=HEADER_TS2_GEN4[i];
    ELEC_vif.lane_1_rx <=HEADER_TS2_GEN4[i];
    @(posedge ELEC_vif.gen4_lane_clk);
   end
   ELEC_vif.data_incoming <=0;
endtask: TS2_gen4_2_DUT

task electrical_layer_driver::TS3_2_DUT();
@(posedge ELEC_vif.gen4_lane_clk);
   ELEC_vif.data_incoming <=1;
    foreach(HEADER_TS3_GEN4[i]) 
    begin
    ELEC_vif.lane_0_rx <=HEADER_TS3_GEN4[i];
    ELEC_vif.lane_1_rx <=HEADER_TS3_GEN4[i];
    @(posedge ELEC_vif.gen4_lane_clk);
   end
   ELEC_vif.data_incoming <=0;
endtask: TS3_2_DUT
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//task send data to the DUT
task electrical_layer_driver:: send_data_2_DUT(input logic[7:0] data_2_DUT,
                                               input GEN gen_speed,input LANE lane);
      ELEC_vif.sbrx <=1; 
      ELEC_vif.data_incoming <=1;
      case(gen_speed)
        gen2: begin
          case(lane)
            lane_0: begin  
               foreach(data_2_DUT[i]) begin
                ELEC_vif.lane_0_rx <=data_2_DUT[i];
                @(posedge ELEC_vif.gen2_lane_clk);
               end
             end
            lane_1: begin
              foreach(data_2_DUT[i]) begin
                ELEC_vif.lane_1_rx <=data_2_DUT[i];
                @(posedge ELEC_vif.gen2_lane_clk);
            end
            end
          
          endcase
        end
        gen3: begin
          case(lane)
            lane_0: begin  
               foreach(data_2_DUT[i]) begin
                ELEC_vif.lane_0_rx <=data_2_DUT[i];
                 @(posedge ELEC_vif.gen3_lane_clk);
               end
             end
            lane_1: begin
              foreach(data_2_DUT[i]) begin
                ELEC_vif.lane_1_rx <=data_2_DUT[i];
                @(posedge ELEC_vif.gen3_lane_clk);
            end
            end
          endcase
        end

        gen4: begin
           case(lane)
            lane_0: begin  
               foreach(data_2_DUT[i]) begin
                ELEC_vif.lane_0_rx <=data_2_DUT[i];
                @(posedge ELEC_vif.gen4_lane_clk);
               end
             end
            lane_1: begin
              foreach(data_2_DUT[i]) begin
                ELEC_vif.lane_1_rx <=data_2_DUT[i];
                @(posedge ELEC_vif.gen4_lane_clk);
            end
            end
          
          endcase
        end
      endcase
endtask: send_data_2_DUT
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//task to disconnect the DUT

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//task to run the driver
  task electrical_layer_driver::run();
    forever
     begin
      // Wait for the transaction from the generator
      elec_drv_gen.get(transaction);
      //$display("[ELEC DRIVER] the value of transaction is %p",transaction); //test
      case(transaction.phase)
      3'b010:begin  //indecate the phase 2 of the transaction
         @(negedge ELEC_vif.SB_clock);
         ELEC_vif.sbrx <=transaction.sbrx;
         #(tConnectRx);          // Wait for the time required for the connection to be established
        end

      3'b011:begin  //indecate the phase 3 of the transaction
case(transaction.transaction_type)
  AT_cmd,AT_rsp: begin
    send_AT_cmd_OR_res_2_DUT(transaction.read_write,
                             transaction.address,
                             transaction.len,
                             transaction.cmd_rsp_data,
                             transaction.transaction_type
                            );

              //add explain on gen speed               
  end
  LT_fall:  begin
    send_LT_fall_2_DUT();
  end
  default:begin
  end
endcase    
      end
      3'b100:begin
       //**stable consant signal on interface during training**// 
      ELEC_vif.sbrx <=1;           //drive sbrx to 1 
      case(transaction.o_sets)
        SLOS1: begin
           SLOS1_2_DUT(transaction.gen_speed);
        end
       SLOS2: begin
          SLOS2_2_DUT(transaction.gen_speed);
        end
        TS1_gen2_3: begin
          TS1_gen23_2_DUT(transaction.gen_speed);
        end
        TS2_gen2_3: begin
          TS2_gen23_2_DUT(transaction.gen_speed);
        end
        TS1_gen4: begin
          TS1_gen4_2_DUT();
        end
        TS2_gen4: begin
          TS2_gen4_2_DUT();
        end
        TS3: begin
          TS3_2_DUT();
        end
        TS4: begin
          //TS4_2_DUT();  no need to this task as no response in case TS4 
        end
        default: begin
        end
      endcase
       
      end
      3'b101:begin   //added phase represent send data from electrical layer to the DUT
        ELEC_vif.sbrx <=1;           //drive sbrx to 1
        send_data_2_DUT( transaction.electrical_to_transport
                         ,transaction.gen_speed,transaction.lane);
      end
      3'b110:begin //added phase to represent disconnect phase (drive sbrx to zero)
        Disconnect_2_DUT();
      end
      default:begin
        // Add your code here for default case
      end
      endcase
      ->elec_gen_driver_done; // Indicate that the driver has finished sending the transaction
      
      end

  endtask: run

//endpackage:electrical_layer_driver_pkg

