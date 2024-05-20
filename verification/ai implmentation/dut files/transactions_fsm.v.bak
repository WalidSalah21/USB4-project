`default_nettype none
module transactions_fsm(

    input           sb_clk,
    input           rst,
    input [9:0]     sbrx,
    input           error,
    input           tdisconnect,
    input           tconnect,

    output reg      t_valid,
    output reg      trans_error,
    output reg [23:0] payload_in,
    output reg      s_read, s_write,
    output reg [7:0] s_address,
    output reg      disconnect,
    output reg      crc_det_en
);

    // State definitions
    localparam DISCONNECT = 3'b000;
    localparam IDLE = 3'b001;
    localparam DLE1 = 3'b010;
    localparam AT = 3'b011;
    localparam LT = 3'b100;
    localparam DLE2 = 3'b101;

    // AT
   localparam DLE_SYMBOL = 8'hFE;
  localparam STX_COMMAND_SYMBOL = 8'b00000101;
  localparam STX_RESPONSE_SYMBOL = 8'b00000100;
  localparam ETX_SYMBOL = 8'h40;


localparam LSE_SYMBOL = 8'b10000000;
localparam CLSE_SYMBOL = ~LSE_SYMBOL;

    // State register and next state logic
    reg [2:0] cs, ns;
    
    // Define maximum data count=69
    reg [6:0] data_count; 
    
    // Define the storing element array
    reg [7:0] storing_element [71:0]; // Considering DLE and ETX symbols along with data symbols
    
    
   // Define registers to hold the output values
reg      t_valid_reg;
reg      trans_error_reg;
reg [23:0] payload_in_reg;
reg      s_read_reg, s_write_reg;
reg [7:0] s_address_reg;
reg      disconnect_reg;
reg      crc_det_en_reg;




// Always block triggered on the positive edge of the clock
always @(posedge sb_clk) begin
    // Update registers with the new output values
    t_valid <= t_valid_reg;
    trans_error <= trans_error_reg;
    payload_in <= (ns == DLE2)? payload_in_reg : payload_in;
    s_read <= s_read_reg&&t_valid_reg;
    s_write <= s_write_reg&&t_valid_reg;
    s_address <= s_address_reg;
    disconnect <= disconnect_reg;
    crc_det_en <= crc_det_en_reg;
  end
    
    
    //State transition and combinational logic
    always @(posedge sb_clk or negedge rst) begin
        if (!rst) begin
            cs <= DISCONNECT;
        end else begin
          		cs <= ns ;
	end
end
          
     always@(*) begin
            case (cs)
              
              
              DISCONNECT: begin
                    // State logic for DISCONNECT state
                    if (tconnect) begin
                        ns = IDLE;
                    end else begin
                        ns = DISCONNECT;
                    end
                end
                IDLE: begin
                    // State logic for IDLE state
                    if (error) begin
                        ns = IDLE;
                    end else if (sbrx[8:1] == DLE_SYMBOL) begin
                        ns = DLE1;
                    end else if (tdisconnect) begin
                        ns = DISCONNECT;
                    end else begin
                        ns = IDLE;
                    end
                end
                
                DLE1: begin
                    // State logic for DLE1 state
                    if (error) begin
                        ns = IDLE;
                    end else if (tdisconnect) begin
                        ns = DISCONNECT;
                    end else if (sbrx[8:1] == DLE_SYMBOL) begin
                        ns = DLE1;
                    end else if (sbrx[8:1] == STX_COMMAND_SYMBOL || sbrx[8:1] == STX_RESPONSE_SYMBOL) begin
                        ns = AT;
                    end else if (sbrx[8:1] == LSE_SYMBOL) begin
                        ns = LT;
                    end else begin
                        ns = IDLE;
                    end
                end

                // LT State
                LT: begin
                    if (error) begin
                        ns = IDLE;
                    end else if (tdisconnect) begin
                        ns = DISCONNECT;
                    end else if (sbrx[8:1] == DLE_SYMBOL) begin
                        ns = DLE1;
                    end else if (sbrx[8:1] == CLSE_SYMBOL) begin
                        ns = IDLE;
                    end else begin
                        ns = LT;
                    end
                end
                // AT State
                AT: begin
                    if (error) begin
                        ns = IDLE;
                    end else if (tdisconnect) begin
                        ns = DISCONNECT;
                    end else if (sbrx[8:1] == DLE_SYMBOL) begin
                        ns = DLE2;
                    end else if (data_count < 69) begin
                        ns = AT;
                    end else begin
                        ns = IDLE;
                    end
                end
                // DLE2 State
                DLE2: begin
                    if (error) begin
                        ns = IDLE;
                    end else if (tdisconnect) begin
                        ns = DISCONNECT;
                    end else if (sbrx[8:1] == DLE_SYMBOL) begin
                        if (data_count < 69) begin
                            ns = DLE2;
                        end else begin
                            ns = IDLE;
                        end
                    end else if (sbrx[8:1] == ETX_SYMBOL) begin
                        ns = IDLE;
                    end else if (sbrx[8:1] == STX_COMMAND_SYMBOL || sbrx[8:1] == STX_RESPONSE_SYMBOL) begin
                        ns = AT;
                    end else begin
                        ns = DLE2;
                    end
                end
                default: begin
                    // Default state transition
                    ns = DLE2;
                end
            endcase
        end
        
        
        // Output logic
   always @(*) begin
    // Update outputs based on cs
       case (cs)
         
        DISCONNECT: begin
            // Initialize all outputs to zero
            t_valid_reg = 0;
            trans_error_reg = 0;
            payload_in_reg = 0;
            s_read_reg = 0;
            s_write_reg = 0;
            s_address_reg = 0;
            // Set disconnect to 0 if tconnect is asserted
            disconnect_reg = tconnect ? 0 : 1;
            crc_det_en_reg = 0; // Assuming CRC detection is disabled in DISCONNECT state
        end
        
        IDLE: begin
            // Initialize all outputs to zero
            t_valid_reg = 0;
            trans_error_reg = 0;
            payload_in_reg = 0;
            s_read_reg = 0;
            s_write_reg = 0;
            s_address_reg = 0;
            crc_det_en_reg = 0; // Assuming CRC detection is disabled in DISCONNECT state

            // Check conditions to update outputs
            if (error) begin
                trans_error_reg = 1;
            end else if (sbrx[8:1] == DLE_SYMBOL) begin
                // Store the value of sbrx[8:1] in some register for future use
                storing_element[0] = sbrx[8:1];
                trans_error_reg=0;
		disconnect_reg=0;
		crc_det_en=1;
            end

            // Set disconnect to 1 if tdisconnect is asserted
            if (tdisconnect) begin
                disconnect_reg = 1;
            end
          end
            
            // Output logic for DLE1 state
            
        DLE1: begin
          t_valid_reg = 0;
			    disconnect_reg = 0;
			    payload_in_reg=1;
			    s_address_reg=0;
			    crc_det_en = 1;

            // Check for error
            if (error) begin
                trans_error_reg = 1;
                crc_det_en = 0;
            end else begin
                trans_error_reg = 0;
                crc_det_en = 0;

                // Check for different symbols and store accordingly
                case (sbrx[8:1])
                    LSE_SYMBOL: begin
                        // Store LSE symbol after DLE
                        storing_element[1] = sbrx[8:1];
                        crc_det_en = 0;

                    end
                    STX_RESPONSE_SYMBOL, STX_COMMAND_SYMBOL: begin
                        // Store STX response/command symbol after DLE
                        storing_element[1] = sbrx[8:1];
                    
                    end
                    default: begin
                        // If none of the above, do nothing
                    end
                endcase
            end

            // Check for tdisconnect
            if (tdisconnect) begin
                disconnect_reg = 1;
            end
            end
            
            // Output logic for LT state

        LT: begin
           t_valid_reg = 0;
            trans_error_reg = 0;
            payload_in_reg = 0;
            s_read_reg = 0;
            s_write_reg = 0;
            s_address_reg = 0;
          disconnect_reg = 0;
          crc_det_en_reg = 0;

            // Check for error
            if (error) begin
                trans_error_reg = 1;
                crc_det_en_reg = 0;
            end else begin
                trans_error_reg = 0;
                crc_det_en_reg = 0;

                /// Check if sbrx[8:1] is DLE_SYMBOL
            if (sbrx[8:1] == DLE_SYMBOL) begin
                // Discard stored LSE
                storing_element[1] = 0;
            end
            // Check if sbrx[8:1] is CLSE_SYMBOL
            else if (sbrx[8:1] == CLSE_SYMBOL) begin
                // Store CLSE symbol after LSE
                storing_element[2] = CLSE_SYMBOL;
                disconnect_reg = 1;
            end
            // If sbrx[8:1] is neither DLE_SYMBOL nor CLSE_SYMBOL, do nothing
        end

            // Check for tdisconnect
            if (tdisconnect) begin
                disconnect_reg = 1;
            end
        end
        
        // Output logic for AT 
      AT: begin
        
         t_valid_reg = 0;
            trans_error_reg = 0;
            payload_in_reg = 0;
            s_read_reg = 0;
            s_write_reg = 0;
            s_address_reg = 0;
          disconnect_reg= 0;
          crc_det_en_reg = 0;

        // Check for error
        if (error) begin
            trans_error_reg = 1;
            crc_det_en_reg = 0;
        end else begin
            trans_error_reg = 0;
            crc_det_en_reg = 0;

            // Check if sbrx[8:1] is DLE_SYMBOL
            if (sbrx[8:1] == DLE_SYMBOL) begin
                // Store the symbol
                 storing_element[2 + data_count] = sbrx[8:1];
            end
            // If sbrx[8:1] is not DLE_SYMBOL and data_count < 69, store the data symbol and activate crc_det_en
            else begin
             if (data_count < 69) begin
                 storing_element[2 + data_count] = sbrx[8:1];
                crc_det_en =1;
                case (storing_element[1])

								STX_COMMAND_SYMBOL: begin 

									if (data_count == 4) begin
										crc_det_en=0;
									end else begin
										crc_det_en=1;
									end  

								end
								STX_RESPONSE_SYMBOL: begin 

									if (data_count == 7) begin
										crc_det_en=0;
									end else begin
										crc_det_en=1;
									end  

	end

         default: begin
            storing_element [72]=0;
							crc_det_en=0;
							end
							endcase
							end
							end
							end
            // If sbrx[8:1] is neither DLE_SYMBOL nor data symbol, do nothing
        // Check for tdisconnect
            if (tdisconnect) begin
                disconnect_reg = 1;
            end
    end
    
   DLE2: begin
        // Initialize t_valid_reg, disconnect_reg, and crc_det_en to zero
        t_valid_reg = 0;
        disconnect_reg = 0;
        crc_det_en_reg = 0;

        // Check for error
        if (error) begin
            trans_error_reg = 1;
        end else begin
            trans_error_reg = 0;

            // Check for tdisconnect
            if (tdisconnect) begin
                disconnect_reg = 1;
            end

            // Check if sbrx[8:1] is ETX_SYMBOL
            if (sbrx[8:1] == ETX_SYMBOL) begin
                // Store the symbol after data and DLE
                storing_element[2 + data_count] = sbrx[8:1];
                t_valid_reg = 1;
            end
            // Check if sbrx[8:1] is DLE_SYMBOL
            else if (sbrx[8:1] == DLE_SYMBOL) begin
             if ( data_count < 69) begin
                // Store the symbol
                storing_element[2 + data_count] = sbrx[8:1];
                // Enable CRC detection
                crc_det_en_reg = 1;
              end
              else begin
            storing_element[72]=0;
          end
              
            end
            // Check if sbrx[8:1] is STX_COMMAND_SYMBOL or STX_RESPONSE_SYMBOL
            else if (sbrx[8:1] == STX_COMMAND_SYMBOL || sbrx[8:1] == STX_RESPONSE_SYMBOL) begin
                // Enable CRC detection
                storing_element[2]=sbrx [8:1];
                crc_det_en_reg = 1;
            end
          
            // If sbrx[8:1] is not ETX_SYMBOL, DLE_SYMBOL, or STX_COMMAND/RESPONSE_SYMBOL, do nothing
        end
        end
        endcase
end 


        
        always @(*) begin
          payload_in_reg = {storing_element[6], storing_element[5], storing_element[4]};

         if (storing_element[1] == STX_RESPONSE_SYMBOL) begin
		s_write_reg=0;
		s_read_reg=0;
        end

        // Extract read/write operation from storing symbol 3 (MSB bit 7)
        else if (storing_element[3][7] == 1'b0) begin
            // Read operation
            s_read_reg = 1;
            s_write_reg = 0;
        end else begin
            // Write operation
            s_read_reg = 0;
            s_write_reg = 1;
        end

        // Extract address from byte 0 of the data symbol
        s_address_reg = storing_element[2];
end

always @(posedge sb_clk or negedge rst) begin
    if (~rst) begin
        // Reset data_count to 0
        data_count <= 0;
    end else begin
        // Increment data_count if conditions are met
        if ((cs == AT || cs == DLE2) && data_count < 69) begin
            data_count <= data_count + 1;
        end else begin
            // Reset data_count to 0 for other states
            data_count <= 0;
        end
    end
end






endmodule
`resetall	

