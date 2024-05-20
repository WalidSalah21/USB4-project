/*module dummy_module;
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



task automatic reverse(input bit input_queue[$], output bit output_queue[$]);
    int size = input_queue.size();
    for (int i = 0; i < size; i++) begin
        output_queue.push_front(input_queue[i]);
    end
endtask: 



    initial 
    begin
 bit PRBS11_OUT[$];
 PRBS11_OUT={};

 PRSC11(11'b11111111111,'d100,PRBS11_OUT);

    // Display the value of PRBS11_OUT
    foreach(PRBS11_OUT[i]) begin
        $write("%b", PRBS11_OUT[i]);
    end
    $display("");
    end
  
endmodule
*/
/*
class parent;
endclass
class child1 extends parent;
task child1();
$display("child1");
endtask
endclass
class child2 extends parent;
task child1();
$display("child2");
endtask
endclass

module dummy_module;
task t1(parent p);
child1 ch1;
child2 ch2;
if($cast(ch1,p)) 
   c1.child1();
if($cast(ch2,p))
    c2.child1();
endtask

parent p=new();
child1 c1=  new();
child2 c2=  new();

initial
begin
 t1(c1);
    t1(c2);   
end
endmodule

module names(); 
  int b;
  int c;
  mailbox #(int) mbx;
  
  initial 
  begin
    mbx = new();
    mbx.put(1);
  end
  
  initial 
    begin
      #10;
      
      mbx.get(b);
      $display("b1=%d",b);
      $display("b2=%d",b);
      mbx.peek(c);
      $display("b3=%d",b);
      $display("c=%d",c);
      
    end
  
endmodule*/
/*
module dummy_module;


task CALC_CRC(input bit [7:0] STX, input bit [7:0] data_symb[$], output bit [15:0] CRC_out);
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
    data_symb.push_front(STX);

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

// Define the tr_type enum
typedef enum {AT_cmd, AT_rsp, None} tr_type;
  ////****tasks to send transactions to the DUT
task send_AT_cmd_OR_res_2_DUT(bit read_write = 0, bit [7:0] address = 0,
                                                       bit [6:0] len = 0 , bit [23:0] cmd_rsp_data = 0,
                                                       tr_type trans_type = None);
bit [7:0] data_symb[$];
bit [7:0] CRC_DATA_Q[$];
bit [7:0] L_CRC,H_CRC;
bit [9:0] send_data_symb[$];
bit [0:9] actual_send_data_symb[$];

int k;  //counter

//choose send command or response
if(trans_type==AT_cmd)begin
data_symb ={DLE,STX_cmd,address,len,read_write/*,cmd_rsp_data,DLE,ETX}; //zakarian check
end
else if (trans_type==AT_rsp) begin
  data_symb ={DLE,STX_rsp,address,len,read_write,cmd_rsp_data,DLE,ETX};   //zakarian check
end

CRC_DATA_Q=data_symb[1:$-2];
CALC_CRC(STX_cmd,CRC_DATA_Q,{H_CRC,L_CRC});
$display("CRC_DATA_Q size= %d", CRC_DATA_Q.size());  //check size of CRC_DATA_Q
data_symb.delete();

//choose send command or response
if(trans_type==AT_cmd)
begin
data_symb ={DLE,STX_cmd,address,len,read_write/*,cmd_rsp_data,{L_CRC,H_CRC},DLE,ETX}; //zakarian check
end
else if (trans_type==AT_rsp) 
begin
  data_symb ={DLE,STX_rsp,address,len,read_write,cmd_rsp_data,{L_CRC,H_CRC},DLE,ETX};   
end
     
        // Add start and end bits to each data symbol and store in send_data_symb
        foreach(data_symb[i]) begin
          send_data_symb[i] = {stop_bit, data_symb[i],start_bit};   ///ERROR///
        end

        //to send correct data to the DUT
        foreach(send_data_symb[i]) begin
          bit [9:0] reversed_byte = 0;
          for(int j = 0; j < 10; j++) begin
            reversed_byte[j] = send_data_symb[i][9-j];
          end
          actual_send_data_symb.push_back(reversed_byte);
        end
        $display("actual_send_data_symb: %p", actual_send_data_symb);
        
        // Send the data symbols to the DUT
        foreach(actual_send_data_symb[i,j]) begin
            @(negedge ELEC_vif.SB_clock);
            // Send bit to DUT
            ELEC_vif.sbrx <= actual_send_data_symb[i][j];
          end
        
       //->elec_gen_driver_done; // Indicate that the driver has finished sending the transaction
endtask: send_AT_cmd_OR_res_2_DUT


initial
begin
    
    import electrical_layer_transaction_pkg::*;
    import electrical_layer_driver_pkg::parent;
    bit [7:0] address = 8'hA5;
    bit [6:0] len = 7'h32;
    bit [23:0] cmd_rsp_data = 24'h123456;
    tr_type trans_type = AT_cmd;

    send_AT_cmd_OR_res_2_DUT(0, address, len, cmd_rsp_data, trans_type);
end
endmodule
*/

module tb;

  // Declare variables for the data and CRC
  bit [7:0] data_symb[$];
  bit [15:0] CRC_out;

  // Declare the crc16 task
  task automatic crc16(input bit [7:0] data_symb[$], output bit [15:0] CRC_out);
    bit [15:0] crc;
    bit [15:0] poly;
    integer i, j;
    bit [7:0] data;

    // Initialize CRC and polynomial
    crc = 16'hFFFF;
    poly = 16'h8005;

    // Process each byte in the data
    for (i = 0; i < data_symb.size(); i = i + 1) begin
      data = data_symb[i];

      // Process each bit in the byte
      for (j = 0; j < 8; j = j + 1) begin
        if ((crc[15] ^ data[7]) == 1'b1) begin
          crc = crc << 1;
          crc = crc ^ poly;
        end else begin
          crc = crc << 1;
        end
        data = data << 1;
      end
    end

    // Reflect the CRC result
    CRC_out = {<<{crc}};
  endtask

  // Test the crc16 task
  initial begin
    // Generate some random data
    //{8'hfe,8'h51,8'h80,8'h0a,8'h43,8'h01,8'h0a,8'h05}
   data_symb={<<{8'h01,8'h0a,8'h05}};

    // Calculate the CRC for the data
    crc16(data_symb, CRC_out);

    // Print the result
    $display("Data: %p", data_symb);
    $display("CRC: %0h", CRC_out);
  end

endmodule