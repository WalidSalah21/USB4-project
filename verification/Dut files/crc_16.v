////////////////////////////////////////////////////////////////////////////////////////////////////
// Block:crc_16
//
// Author: Hager Walid
//
// Description: DSP block to check if an error occurred on the transmitted data it has a CRC POLY 8005h.
//              lfsr is set to initial SEED value at rst and when crc_en is deasserted. when crc is enabled and active
//              XOR operations are done During CRC generation, the lfsr shifts its contents to the right by one position at each clock cycle,
//              with the LSB replaced by the feedback bit. when crc_active is desserted then parity bits are shifted out bit by bit.
//
////////////////////////////////////////////////////////////////////////////////////////////////////

module crc_16 #( parameter SEED = 16'hFFFF) 

( 
  input      wire        sb_clk     ,          // module operating clock
  input      wire        rst        ,          // module reset to intialize the lfsr
  input      wire        trans_ser  ,         // input serial trans_ser 
  input      wire        crc_en     ,       // high signal during  trans_ser transaction, low otherwise
  input      wire        crc_active ,       
  output     reg         parity           // serial output parity bits 

 );
            

   reg    [15:0]               lfsr     ;   
   reg    [3:0]                counter  ;   
   wire                        feedback ; 

   // feedback
   assign feedback = trans_ser ^ lfsr[15] ;
	  
   always@(posedge sb_clk or negedge rst)
     begin
        if(!rst)
          begin
             lfsr <= SEED;
			 counter <= 0;
          end
        else
           if(!crc_en) 
             begin
             lfsr <= SEED;
			 counter <= 0;
             end
           else if (!crc_active)			 
             begin
              if(counter !=0 && counter!=9)
                begin			  
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
              counter <= (counter == 9)? 0 : counter + 1;		  
             end 
           else
             begin
			  if(counter !=0 && counter!=9)
			    begin
                  lfsr[15] <= lfsr[14];
	              lfsr[14] <= lfsr[13];     
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
	              lfsr[2]  <= lfsr[1];
	              lfsr[1]  <= lfsr[0];
	              lfsr[0]  <= feedback;
				end
		      counter <= (counter == 9)? 0 : counter + 1;

             end                  
     end
  
  
   always@ (*)
     begin
	   if (crc_active && counter==0)
	     parity = 0;
	   else if (crc_active && counter==9)
	     parity = 1;
	   else if (crc_active)
	     parity = lfsr[15];
	   else
	     parity = 0;
	 end
  
endmodule

`default_nettype none
`resetall


