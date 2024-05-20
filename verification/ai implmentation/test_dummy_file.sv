/*task check_AT_transaction(input [9:0] q[$]);
parameter  DLE = 8'hFE;	//Data Link Escape (DLE) Symbol – indicates the beginning of a Transaction. 
parameter  ETX = 8'h40;
parameter  STX_cmd = 8'b00000101;

if(q[0]=={1'b1,DLE,1'b0} && q[$-1]=={1'b1,DLE,1'b0}
         && q[1]=={1'b1,STX_cmd,1'b0} &&q[$]=={<<{1'b1,ETX,1'b0}}) //check the data later 
		 $display("AT transaction is correct");
         $display("the size of the queue is %d",q.size());
         $display("the first element is %b",{<<{1'b1,ETX,1'b0}});
		
endtask




module dummy_tb;
    logic [9:0] test_queue[$];
parameter [7:0] DLE = 8'hFE;	//Data Link Escape (DLE) Symbol – indicates the beginning of a Transaction. 
parameter [7:0] ETX = 8'h40;
parameter [7:0] STX_cmd = 8'b00000101;

    initial begin
        // Initialize the test_queue
        test_queue.push_back({1'b1, DLE, 1'b0});
        test_queue.push_back({1'b1, STX_cmd, 1'b0});
        // Add more elements as needed
        test_queue.push_back({1'b1, DLE, 1'b0});
        test_queue.push_back({1'b1, ETX, 1'b0});

        // Call the function to check the AT transaction
        check_AT_transaction(test_queue);
    end
endmodule


module dummy_tb;
bit PRBS11_OUT[$];
bit [7:0]  counter_TS1='h0f;
bit [3:0]   indication_TS1='h2;
bit [11:0]  CURSOR='h7E0;
bit trancated_PRBS11_OUT[0:419],
    REVERSE_trancated_PRBS11_OUT[0:419];
bit TS1_Frame [447:0];
//PRSC11(PRBS11_lane0_seed,PRBS11_SYMBOL_SIZE,PRBS11_OUT); //generate PRBS11
trancated_PRBS11_OUT=PRBS11_OUT[28:$];  //trancate the PRBS11
//reverse(trancated_PRBS11_OUT,REVERSE_trancated_PRBS11_OUT);     //reverse the trancated PRBS11

TS1_Frame={REVERSE_trancated_PRBS11_OUT,counter_TS1,~(indication_TS1),indication_TS1,CURSOR};
$display("TS1_Frame=%d",$size(TS1_Frame));  
    endmodule*/

 module test;

  // Declare a queue to test the function
  logic  queue_in[$];
  logic   x[$];

  initial begin
    x='{0,1,1,1,1,1,1,1,0,0,0,0,0,1,1,1,0,0,0,0,1,1,1,1,0,1,0,1,0,1,0,1};
    foreach(x[i])
    begin
    queue_in.push_back(x[i]);

    end
    // Initialize the queue with some test data
    $display("queue_in[0] size = %0d", queue_in.size());
    $display("queue_in[0] = %p", queue_in[0:7]);
    $display("queue_in[1] = %p", queue_in[8:15]);
    $display("queue_in[3] = %p", queue_in[16:23]);
    $display("queue_in = %p", queue_in);
    // Call the function under test
    reverse_bits_in_place(queue_in);

    // Check the results
    $display("after queue_in[0] = %p", queue_in[0:7]);
    $display("after queue_in[1] = %p", queue_in[8:15]);
    $display("after queue_in[3] = %p", queue_in[16:23]);
    $display("after queue_in = %p", queue_in);
  end

  // The reverse_bits_in_place function goes here
  function automatic void reverse_bits_in_place(ref logic queue_in[$]);
  integer i;
  logic [0:7] temp;
  for (i = 0; i < (queue_in.size()/8); i+=1) begin
    temp ={>>{queue_in[(i*8):7+(8*i)]}} ; // get 8 bits
    temp ={<<{temp}}; // reverse bits
    //$display("temp = %b", temp);
    queue_in[(i*8):((i*8)+7)] = {>>{temp}}; // store back in input queue

  end
endfunction

endmodule