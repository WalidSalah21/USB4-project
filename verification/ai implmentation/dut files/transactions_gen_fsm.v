`default_nettype none
module transactions_gen_fsm (
    input  wire           sb_clk,                   
    input  wire           rst,                       

    input  wire [23:0]     sb_read,                   
    input  wire [2:0]      trans_sel,                 
    input  wire           disconnect_sbtx,
    input  wire           tdisconnect_tx_min,

    output reg [9:0] trans,  
    output reg [ 1 : 0 ] trans_state,                       
    output reg       crc_en,                    
    output reg       sbtx_sel,                 
    output reg       trans_sent,               
    output wire      disconnected_s            
);

// Define states
localparam DISCONNECT = 5'b00000,
IDLE = 5'b00001,
DLE1 = 5'b00010,
LSE = 5'b00011,
CLSE = 5'b00100,

STX_COMMAND = 5'b00101,
DATA_WRITE_COMMAND_ADDRESS = 5'b00110,
DATA_WRITE_COMMAND_LENGTH = 5'b00111,
DATA_WRITE_COMMAND_DATA = 5'b01000,

DATA_READ_COMMAND_ADDRESS = 5'b01001,
DATA_READ_COMMAND_LENGTH = 5'b01010,


STX_RESPONSE = 5'b01011,
DATA_WRITE_RESPONSE_ADDRESS = 5'b01100,
DATA_WRITE_RESPONSE_LENGTH = 5'b01101,
DATA_WRITE_RESPONSE_DATA = 5'b01110,

DATA_READ_RESPONSE_ADDRESS = 5'b01111,
DATA_READ_RESPONSE_LENGTH = 5'b10000,
DATA_READ_RESPONSE_DATA = 5'b10001,

CRC1=5'b10010,
CRC2=5'b10011,

DLE2 = 5'b10100,
ETX = 5'b10101;

// Local localparams
localparam DLE_SYMBOL = 8'hFE;

localparam STX_COMMAND_SYMBOL = 8'b00000101;
localparam STX_RESPONSE_SYMBOL = 8'b00000100;


localparam LSE_SYMBOL = 8'b10000000;
localparam CLSE_SYMBOL = ~LSE_SYMBOL;

localparam DISCONNECTED_S = 2'h0,
	       IDLE_S         = 2'h1,
		   START          = 2'h2;




// State register
reg [4:0] cs, ns;

// Counter
reg [3:0] symbol_count;

//data_counter

reg [2:0] data_count;

//capture output at posedge clk

reg [9:0] trans_reg ;
reg [1:0] trans_state_reg;
reg	crc_en_reg ;
reg	sbtx_sel_reg;
//reg disconnected_s_reg;

reg [2:0] trans_sel_pulse;

//delay for sending trans for training sync
reg trans_sent_1;
reg trans_sent_2;
reg trans_sent_3;


always @(posedge sb_clk) begin 

	
	trans <= trans_reg ;
	crc_en <= crc_en_reg ;
	sbtx_sel <= sbtx_sel_reg ;
	trans_state <= trans_state_reg ;
	//disconnected_s<= disconnected_s_reg;	
	
end



// Next state logic
always @ (posedge sb_clk or negedge rst) begin
    if (!rst) begin
        cs <= DISCONNECT;
    end else begin
        cs <= ns;
    end
end

// State transition and output logic
	always @(*) begin
	  
	trans_reg = trans ;
	crc_en_reg = crc_en ;
	sbtx_sel_reg = sbtx_sel ;
	trans_state_reg = trans_state ;
	ns=cs;
	
    case (cs)
    DISCONNECT: begin
            if (disconnect_sbtx || !tdisconnect_tx_min) begin
                ns = DISCONNECT;
                trans_reg = 0;
                crc_en_reg = 0;
                sbtx_sel_reg = 0;
                trans_state_reg = DISCONNECTED_S;
               // disconnected_s_reg =1'b1;
            end else begin
                ns = IDLE; // Default next state
                trans_reg = 10'b1111111111;
                crc_en_reg = 0;
                trans_state_reg = IDLE_S;
                sbtx_sel_reg = 0;
               // disconnected_s_reg =1'b1;
            end
        end
        
        IDLE: begin
		case(trans_sel_pulse ) // If trans_sel is 0
              0: begin  ns = IDLE;
                trans_reg = 10'b1111111111;
                crc_en_reg = 0;
                trans_state_reg = IDLE_S;
                sbtx_sel_reg = 0;
                //disconnected_s_reg =1'b0;
		      
			/*   end else if (trans_sel_pulse == 1) begin // If trans_sel is 1
                ns = DISCONNECT;
                trans_reg = 10'b0000000000;
                crc_en_reg = 1'b0;
                trans_state_reg = DISCONNECTED_S;
                sbtx_sel_reg = 1'b0;
                disconnected_s_reg =1'b0; */
			
		end
		2:  begin // If trans_sel is 2
                ns = DLE1;
                trans_reg = {1'b1,8'hFE,1'b0};
                crc_en_reg = 0;
                sbtx_sel_reg = 0;
                trans_state_reg = START;
                //disconnected_s_reg =1'b0;
                
		end 
			3: begin // If trans_sel is 3
                ns = DLE1;
                trans_reg = {1'b1,8'hFE,1'b0};
                crc_en_reg = 0;
                sbtx_sel_reg = 0;
                trans_state_reg = START;
               // disconnected_s_reg =1'b0;
                
		end 
			4:
			begin // If trans_sel is 4
                ns = DLE1;
                trans_reg = {1'b1,8'hFE,1'b0};
                crc_en_reg = 0;
                trans_state_reg = START;
                sbtx_sel_reg = 0;
               // disconnected_s_reg =1'b0;
             end
           default: begin // Default case
                ns = IDLE;
                trans_reg = 10'b1111111111;
                crc_en_reg = 0;
                sbtx_sel_reg = 0;
                trans_state_reg = IDLE;
               // disconnected_s_reg =1'b0;
            end
				endcase
        end
        
        DLE1: begin
            if (symbol_count == 9) begin // If symbol_count reaches 9
		    case (trans_sel_pulse) 
			    2: begin // If trans_sel is 2
                    ns = STX_COMMAND; // Transition to STX_COMMAND state
                    trans_reg = {1'b1, STX_COMMAND_SYMBOL, 1'b0}; // Set trans_reg output to STX_COMMAND_SYMBOL
                    crc_en_reg = 0; // Enable CRC
                    sbtx_sel_reg = 0; // Set sbtx_sel_reg to 0
                   // disconnected_s_reg =1'b0;
		    end 
		   3:  begin // If trans_sel is 3
                    ns = STX_RESPONSE; // Transition to STX_RESPONSE state
                    trans_reg = {1'b1, STX_RESPONSE_SYMBOL, 1'b0}; // Set trans_reg output to STX_RESPONSE_SYMBOL
                    crc_en_reg = 0; // Enable CRC
                    sbtx_sel_reg = 0; // Set sbtx_sel_reg to 0
                   // disconnected_s_reg =1'b0;
		    end 
		    4: begin // If trans_sel is 4
                    ns = LSE; // Transition to LSE state
                    trans_reg = {1'b1, LSE_SYMBOL, 1'b0}; // Set trans_reg output to LSE_SYMBOL
                    crc_en_reg = 0; // Enable CRC
                    sbtx_sel_reg = 0; // Set sbtx_sel_reg to 0
                  //  disconnected_s_reg =1'b0;
                end
		    endcase 
        end
	end
        
        LSE: begin
          crc_en_reg = 1'b1; //enable crc when enter LSE
          
		if (symbol_count == 9) begin
			case (trans_sel_pulse) 
				4:begin // If symbol_count reaches 9 and trans_sel is 4
                ns = CLSE; // Transition to CLSE state
                trans_reg = {1'b1, CLSE_SYMBOL, 1'b0}; // Set trans_reg output to CLSE_SYMBOL
                crc_en_reg = 1; // Enable CRC
                sbtx_sel_reg = 0; // Set sbtx_sel_reg to 0
               // disconnected_s_reg =1'b0;
            end 
			endcase
		end
        end
			
	    
        CLSE: begin
		if (symbol_count == 9) begin
			case (trans_sel_pulse)
				4: begin // If symbol_count reaches 9 and trans_sel is 4
                ns = IDLE; // Transition to IDLE state
                trans_reg = 10'b1111111111; // Set trans_reg output to all ones
                crc_en_reg = 0; // Disable CRC
                sbtx_sel_reg = 0; // Enable sbtx_sel_reg
               // disconnected_s_reg =1'b0;
            end 
			endcase
		end
	end
        
        STX_COMMAND: begin
          crc_en_reg = 1;
		if (symbol_count == 9 ) begin
			case (trans_sel_pulse) 
				2:begin // If symbol_count reaches 9 and trans_sel is 2
                ns = DATA_READ_COMMAND_ADDRESS; // Transition to DATA_READ_COMMAND_ADDRESS state
                trans_reg = {1'b1, 8'd78, 1'b0}; // Set trans_reg output to the address of reg 12
                crc_en_reg = 1; // Enable CRC
               // disconnected_s_reg =1'b0;
                sbtx_sel_reg = 0; // Set sbtx_sel_reg to 0
               
            end 
			endcase
        end
	end
	    
        DATA_READ_COMMAND_ADDRESS: begin
		if (symbol_count == 9 ) begin
			case(trans_sel_pulse ) 
				2:begin // If symbol_count is 9 and trans_sel is 2
                ns = DATA_READ_COMMAND_LENGTH; // Transition to DATA_READ_COMMAND_LENGTH state
		trans_reg = {1'b1,1'b0, 7'h3, 1'b0}; // Set trans_reg output to the length of the command
                crc_en_reg = 1; // Enable CRC
                sbtx_sel_reg = 0; // Set sbtx_sel_reg to 0
                //disconnected_s_reg =1'b0;
            end 
			endcase
		end
	end
			
        
       DATA_READ_COMMAND_LENGTH: begin
	       if (symbol_count == 9) begin
		       case(trans_sel_pulse) 
			       2:begin // If symbol_count is 9 and trans_sel is 2
                ns = CRC1; // Transition to CRC_LOW state
                trans_reg = 0; // Set trans_reg output to 0
                crc_en_reg = 1; // Enable CRC
                sbtx_sel_reg = 0; // Set sbtx_sel_reg to 0
                //disconnected_s_reg =1'b0;
            end 
		       endcase
	       end
       end
        
              STX_RESPONSE: begin
                crc_en_reg = 1;
		      if (symbol_count == 9 ) begin
			      case( trans_sel_pulse )
				      3: begin // If symbol_count is 9 and trans_sel is 3
                ns = DATA_READ_RESPONSE_ADDRESS; // Transition to DATA_READ_RESPONSE_ADDRESS state
                trans_reg = {1'b1, 8'd78, 1'b0}; // Set trans_reg output to the address of reg 12
                crc_en_reg = 1; // Enable CRC
                sbtx_sel_reg = 0; // Set sbtx_sel_reg to 0
               // disconnected_s_reg =1'b0;
            end 
			      endcase
		      end
	      end
        
        DATA_READ_RESPONSE_ADDRESS: begin
		if (symbol_count == 9 ) begin
			case(trans_sel_pulse ) 
				3:begin // If symbol_count is 9 and trans_sel is 3
                ns = DATA_READ_RESPONSE_LENGTH; // Transition to DATA_READ_RESPONSE_LENGTH state
		trans_reg = {1'b1,1'b0,7'h3,1'b0}; // Set trans_reg output to the address of reg 12
                crc_en_reg = 1; // Enable CRC
                sbtx_sel_reg = 0; // Set sbtx_sel_reg to 0
               // disconnected_s_reg =1'b0;
            end 
			endcase
		end
	end
			
        DATA_READ_RESPONSE_LENGTH: begin
		if (symbol_count == 9) begin
			case(trans_sel_pulse ) 
				3:begin // If symbol_count is 9 and trans_sel is 3
                ns = DATA_READ_RESPONSE_DATA; // Transition to DATA_READ_RESPONSE_DATA state
                trans_reg = {1'b1, sb_read[7:0], 1'b0}; // Set trans_reg output to sb_read[9:0]
                crc_en_reg = 1; // Enable CRC
                sbtx_sel_reg = 0; // Set sbtx_sel_reg to 0
               // disconnected_s_reg =1'b0;
            end 
			endcase
		end
	end
        
        DATA_READ_RESPONSE_DATA: begin
            if (symbol_count == 9) begin
		    case(trans_sel_pulse ) 
			    3:begin
			    if( data_count ==2) begin // If symbol_count is 9, trans_sel is 3, and data_count is 2
                    ns = CRC1; // Transition to CRC_LOW state
                    trans_reg = 0; // Set trans_reg output to 0
                    crc_en_reg = 1; // Enable CRC
                    sbtx_sel_reg = 0; // Set sbtx_sel_reg to 1
                    //disconnected_s_reg =1'b0;
			    end
	
			    else begin
				    case(data_count )  
                   0: begin
			   ns = DATA_READ_RESPONSE_DATA; // Stay in DATA_READ_RESPONSE_DATA state
                    // Concatenate start bit = 1, end bit = 0, and the 1st 8 bits of sb_read
                    trans_reg = {1'b1, sb_read[15:8], 1'b0};
                    crc_en_reg = 1; // Enable CRC
                    sbtx_sel_reg = 0; // Set sbtx_sel_reg to 0
                   // disconnected_s_reg =1'b0;
                 end
			   1: begin 
                    ns = DATA_READ_RESPONSE_DATA; 
                    // Concatenate start bit = 1, end bit = 0, and the second 8 bits of sb_read
                    trans_reg = {1'b1, sb_read[23:16], 1'b0};
                    crc_en_reg = 1; // Enable CRC
                    sbtx_sel_reg = 0; // Set sbtx_sel_reg to 0
                   // disconnected_s_reg =1'b0;
                end 
			   endcase
	    end
	end
				    endcase
			    end
			    end

				    
       DLE2: begin
         crc_en_reg = 0;
			   sbtx_sel_reg = 0;
            if (symbol_count == 9) begin
		    case(trans_sel_pulse )
			    2: begin // If symbol_count is 9 and trans_sel is 2
                    ns = ETX; // Transition to ETX state
                    trans_reg = {1'b1,8'h40,1'b0}; // Set trans_reg output to ETX symbol
                    crc_en_reg = 0; // Disable CRC
                    sbtx_sel_reg = 0; // Set sbtx_sel_reg to 0
                   // disconnected_s_reg =1'b0;
				    end
		    3:  begin // If symbol_count is 9 and trans_sel is 3
                    ns = ETX; // Transition to ETX state
                    trans_reg = {1'b1,8'h40,1'b0}; // Set trans_reg output to ETX symbol
                    crc_en_reg = 0; // Disable CRC
                    sbtx_sel_reg = 0; // Set sbtx_sel_reg to 0
                    //disconnected_s_reg =1'b0;
                end
				    endcase
			    end
       end
          
		    
        ETX: begin
            if (symbol_count == 9) begin
		    case (trans_sel_pulse )
			   2: begin
                    ns = IDLE; // Transition to IDLE state
                    trans_reg = 10'b1111111111; // Set trans_reg output to all ones
                    crc_en_reg = 0; // Disable CRC
                    sbtx_sel_reg = 0; // Set sbtx_sel_reg to 0
                    //disconnected_s_reg =1'b0;
				   
                end 
			    3: begin
				     ns = IDLE; // Transition to IDLE state
                    trans_reg = 10'b1111111111; // Set trans_reg output to all ones
                    crc_en_reg = 0; // Disable CRC
                    sbtx_sel_reg = 0; // Set sbtx_sel_reg to 0
                    //disconnected_s_reg =1'b0;
            end
		    endcase
	    end
	end
        
        CRC1: begin
          sbtx_sel_reg=1;
            if (symbol_count == 9) begin
                    ns = CRC2; // Transition to CRC_HIGH state
                    trans_reg = 0; // Set trans_reg output to 0
                    crc_en_reg = 1; // Enable CRC
                    sbtx_sel_reg = 1; // Set sbtx_sel_reg to 1
                   // disconnected_s_reg =1'b0;
                end 
              end
                
                
        CRC2: begin
            if (symbol_count == 9) begin
                    ns = DLE2; // Transition to DLE2 state
                    trans_reg = {1'b1,8'hFE,1'b0}; // Set trans_reg output to DLE symbol
                    crc_en_reg = 1; // Disable CRC
                    sbtx_sel_reg = 1; // Set sbtx_sel_reg to 0
                   // disconnected_s_reg =1'b0;
                end 
	end
    endcase
end

        
        
// Counter logic for data_count
always @ (posedge sb_clk or negedge rst) begin
	if (~rst) begin
        data_count <= 0;
    end 
	else if ((cs == DATA_WRITE_COMMAND_DATA || cs == DATA_READ_RESPONSE_DATA) && (data_count!=2) && (symbol_count == 9)) begin
                data_count <= data_count + 1;
            end

         else if ( cs==IDLE ) begin
            data_count <= 0;
        end
      else begin
      data_count <= data_count ; //hold value in other cases
    end
       
    end




// Counter logic
always @ (posedge sb_clk or negedge rst) begin
	if (~rst) begin
        symbol_count <= 0;
    end else begin
	    if (cs != 1 && cs != 0 && symbol_count < 9) begin
            // Increment counter if not in IDLE or DISCONNECT state and count is less than 9
            symbol_count <= symbol_count + 1;
        end else begin
            symbol_count <= 0;
        end
    end
end

always @(posedge sb_clk or negedge rst) begin
    if (!rst) begin
        trans_sel_pulse <= 0;    // Initialize to zero on reset
        trans_sent <= 0;  
	      trans_sent_1 <= 0;
	      trans_sent_2 <= 0;
	      trans_sent_3 <= 0;
	    
    end else if (trans_sel != 0) begin
        // Hold previous value of trans_sel_pulse unless in disconnect state
            trans_sel_pulse <= trans_sel;
	          trans_sent_1 <= 0;
            trans_sent_2 <= trans_sent_1;
	          trans_sent_3 <= trans_sent_2;
	          trans_sent <= trans_sent_3;
        end 

        // Determine if transaction is sent
	else if ((cs == CLSE || cs == ETX) && (symbol_count == 9)) begin
            trans_sent_1 <= 1;
            trans_sel_pulse<= 0; 
	      trans_sent_2 <= trans_sent_1;
		trans_sent_3 <= trans_sent_2;
		trans_sent <= trans_sent_3; // Set trans_sent when in CLSE or ETX and symbol_count = 9
        end else begin
            trans_sent_1 <= 1'b0; // Reset trans_sent otherwise
            trans_sel_pulse <= trans_sel_pulse;
		trans_sent_2 <= trans_sent_1;
		trans_sent_3 <= trans_sent_2;
		trans_sent <= trans_sent_3;
        end
    end
    
    assign disconnected_s = (cs==DISCONNECT);



endmodule
`resetall	



