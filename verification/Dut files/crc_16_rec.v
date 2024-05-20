////////////////////////////////////////////////////////////////////////////////////////////////////
// Block: crc_16_rec (receiver side)
//
// Author: Hager Walid
//
// Description: DSP block to check if an error occurred on the transmitted data it has a CRC POLY 8005h.
//              lfsr is set to initial SEED value at rst and when crc_en is deasserted. when crc is enabled and active
//              XOR operations are done During CRC generation, the lfsr shifts its contents to the right by one position at each clock cycle,
//              with the LSB replaced by the feedback bit. when crc_en is desserted and all lfsr bits are zeros, the messsage is error free.
//
////////////////////////////////////////////////////////////////////////////////////////////////////

module crc_16_rec #( parameter SEED = 16'hFFFF) 

( 
 input      wire                     sb_clk     ,         // module operating clock
 input      wire                     rst        ,        // module reset to intialize the lfsr
 input      wire                     trans_ser  ,       // input serial trans_ser 
 input      wire                     crc_en     ,      // high signal during  trans_ser transaction, low otherwise      
 output     reg                      error             // error detected
);
            

   reg    [3:0]                counter  ;   
   reg    [15:0]               lfsr     ;   
   reg                         flag     ;   
   wire                        feedback ; 

   // feedback
   assign feedback = trans_ser ^ lfsr[15] ;
	  
   always@(posedge sb_clk or negedge rst)
     begin
        if(!rst)
          begin
             lfsr <= SEED;
             error <= 1'b0;
             flag <= 1'b0;
             counter <= 0;
          end
        else if(crc_en) 
          begin
            error <= 1'b0;
			counter <= (counter==9)? 0 : counter + 1;
            if(counter !=0 && counter!=9)
			  begin
			    flag <= 1'b0;
	            lfsr[15] <= lfsr[14] ^ feedback;
	            lfsr[14] <= lfsr[13];     // is equivalent to lfsr <= {feedback, lfsr[7] ^ feedback , lfsr[6:4], lfsr[3] ^ feedback, lfsr[2:1]} ;
                lfsr[13] <= lfsr[12];
                lfsr[12] <= lfsr[11]; 
                lfsr[11] <= lfsr[10];
                lfsr[10] <= lfsr[9];
                lfsr[9]  <= lfsr[8];
                lfsr[8]  <= lfsr[7];
	            lfsr[7]  <= lfsr[6];
	            lfsr[6]  <= lfsr[5];
	            lfsr[5]  <= lfsr[4];
	            lfsr[4]  <= lfsr[3];
	            lfsr[3]  <= lfsr[2];
	            lfsr[2]  <= lfsr[1] ^ feedback;
	            lfsr[1]  <= lfsr[0];
	            lfsr[0]  <= feedback; 
			  end
          end
        else			 
          begin 
            error <= (lfsr != 'h0 && !flag); //if lfsr no having zeros --> error
            flag <= 1; //if lfsr no having zeros --> error
            lfsr <= SEED;	
            counter <= 0;			
          end                
     end
		  
endmodule

`default_nettype none
`resetall


