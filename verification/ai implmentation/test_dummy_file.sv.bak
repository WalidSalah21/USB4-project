task check_AT_transaction(input [9:0] q[$]);
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

/*
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