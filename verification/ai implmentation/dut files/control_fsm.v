////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Block: control_fsm
// Author: Seif Hamdy Fadda
// 
// Description: Exchanging of parameters, clock switching, sending and receiving ordered sets orders, enabling the transmission of data
// Note: This block is implemented using AI (chatgpt3.5).
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
`default_nettype none
module control_fsm (
    input wire fsm_clk,
    input wire reset_n,
    input wire sync_busy,
    input wire [3:0] os_in_l0,
    input wire [3:0] os_in_l1,
    input wire [7:0] s_address_i,
    input wire s_read_i,
    input wire s_write_i,
    input wire trans_error,
    input wire t_valid,
    input wire os_sent,
    input wire [31:0] c_data_in,
    input wire disconnect_sbrx,
    input wire [23:0] payload_in,
    input wire lane_disable,
    input wire tdisabled_min,
    input wire tgen4_ts1_timeout,
    input wire tgen4_ts2_timeout,
    input wire ttraining_error_timeout,
    input wire trans_sent,
    input wire new_sym, 
    output reg [3:0] d_sel,
    output reg [2:0] trans_sel,
    output reg [1:0] gen_speed,
    output reg [31:0] c_data_out,
    output reg [7:0] c_address,
    output reg [7:0] s_data_o,
    output reg [7:0] s_address_o,
    output reg disconnect_sbtx,
    output reg fsm_disabled,
    output reg fsm_training,
    output reg ts1_gen4_s,
    output reg ts2_gen4_s,
    output reg c_read,
    output reg c_write,
    output reg s_read_o,
    output reg s_write_o
);

// Define states
parameter DISABLED = 4'b0000;
parameter CLD_CABLE = 4'b0001;
parameter CLD_DETECT = 4'b0010;
parameter CLD_EXCHANGE_1 = 4'b0011;
parameter CLD_EXCHANGE_2 = 4'b0100;
parameter CLD_CLOCK = 4'b0101;
parameter TS1_GEN4 = 4'b0110;
parameter TS2_GEN4 = 4'b0111;
parameter TS3_GEN4 = 4'b1000;
parameter TS4_GEN4 = 4'b1001;
parameter SLOS1_GEN3 = 4'b1010;
parameter SLOS2_GEN3 = 4'b1011;
parameter TS1_GEN3 = 4'b1100;
parameter TS2_GEN3 = 4'b1101;
parameter CL0 = 4'b1110;

localparam GEN4 = 'b00;
localparam GEN3 = 'b01;
localparam GEN2 = 'b10;

// State register
reg [3:0] current_state, next_state;

// Counters for TS1, TS2, TS3, and TS4 sent and received
reg [5:0] os_sent_count;
reg [3:0] os_receive_count_l0;
reg [3:0] os_receive_count_l1;
reg       AT_flag;
reg       AT_flag_is_sent;
reg [1:0] cable_generation;
reg       usb4_detected;
reg [1:0] other_adapter_generation;
reg 	  address_sent;     


//output logic
always @(posedge fsm_clk or negedge reset_n) begin
    if (!reset_n)
	  begin
        d_sel <= 'h9;
        gen_speed <= 0;
        c_data_out <= 'h0;
        c_address <= 'h0;
        c_read <= 0;   
        c_write <= 0;   		
	    os_sent_count <= 'h0;
        os_receive_count_l0 <= 0;
        os_receive_count_l1 <= 0;
		fsm_disabled <= 1;
        fsm_training <= 0;
        ts1_gen4_s <= 0;
        ts2_gen4_s <= 0;
		usb4_detected <= 0;
	    other_adapter_generation <= 0;
		cable_generation <= 0;
		address_sent <=0;
	  end
	  
	else begin
    
    case (current_state)
	    DISABLED: begin
            d_sel <= 'h9; 
            gen_speed <= 0;
            c_data_out <= 'h0;
            c_address <= 'h0;
            c_read <= 0;   
            c_write <= 0;   		
	        os_sent_count <= 'h0;
            os_receive_count_l0 <= 0;
            os_receive_count_l1 <= 0;
		    fsm_disabled <= 1;
            fsm_training <= 0;
            ts1_gen4_s <= 0;
            ts2_gen4_s <= 0;
			usb4_detected <= 0;
			other_adapter_generation <= 0;
			cable_generation <= 0;
			address_sent <=0;
        end
		CLD_CABLE: begin
            d_sel <= 'h9; // Zeros in lanes
            gen_speed <= GEN4; // Default to GEN4
            os_sent_count <= 'h0;
            os_receive_count_l0 <= 0;
            os_receive_count_l1 <= 0;
            c_address <= 18;
            c_write <= 0;
        
            if (next_state != CLD_CABLE) begin
                c_read <= 0;
				address_sent <= 0;
				
            end else begin
			    address_sent <= 1;
                c_read <= !address_sent;
            end
        
            if ((c_data_in[7:0] == 'h40)) 
                usb4_detected <= 1;
            else 
                usb4_detected <= 0;
        
            if(c_data_in[21] == 1)
                cable_generation <= GEN4;
            else if(c_data_in[20] == 1)
                cable_generation<= GEN3;
            else
                cable_generation <= GEN2;
            end
		CLD_DETECT: begin
            d_sel <= 4'h9; // Set d_sel to 4'h9
            // Reset counters of the ordered sets
            os_sent_count <= 0;
            os_receive_count_l0 <= 0;
            os_receive_count_l1 <= 0;
            // Other state-specific logic...
			gen_speed <= GEN4;
			fsm_training <= 0;
            ts1_gen4_s <= 0;
            ts2_gen4_s <= 0;
        end
		CLD_EXCHANGE_1: begin
            // Default values for d_sel and counters of ordered sets
            d_sel <= 4'h9;
            os_sent_count <= 0;
            os_receive_count_l0 <= 0;
            os_receive_count_l1 <= 0;
			c_write <= 0;
			fsm_training <= 0;
            ts1_gen4_s <= 0;
            ts2_gen4_s <= 0;
            // Collect parameters of the other adapter and determine its generation
            if (payload_in[18] == 1)
                other_adapter_generation <= GEN4;
            else if (payload_in[13] == 1)
                other_adapter_generation <= GEN3;
            else
                other_adapter_generation <= GEN2;

            // Determine gen_speed based on cable and other adapter generations
            if ((cable_generation == GEN2) || (other_adapter_generation == GEN2))
                gen_speed <= GEN2;
            else if ((cable_generation == GEN3) || (other_adapter_generation == GEN3))
                gen_speed <= GEN3;
            else
                gen_speed <= GEN4;

            // Other state-specific logic...
        end
		CLD_EXCHANGE_2: begin
            // Default values for d_sel, ordered sets counters, c_write, ts1_gen4s, ts2_gen4_s, and fsm_training
            d_sel <= 4'h9;
            os_sent_count <= 0;
            os_receive_count_l0 <= 0;
            os_receive_count_l1 <= 0;
            c_write <= 0;
            ts1_gen4_s <= 0;
            ts2_gen4_s <= 0;
            fsm_training <= 0;
            // Other state-specific logic...
        end
		CLD_CLOCK : begin
            d_sel <= 4'h9;
            os_sent_count <= 0;
            os_receive_count_l0 <= 0;
            os_receive_count_l1 <= 0;			
			cable_generation <= cable_generation;
			other_adapter_generation <= other_adapter_generation;
        end
		
        TS1_GEN4: begin
            if (next_state == TS1_GEN4) begin
			    if (os_sent)
                os_sent_count <= os_sent_count + 1;
                if (os_in_l0 == 4'h4)
                    os_receive_count_l0 <= os_receive_count_l0 + 1;
                if (os_in_l1 == 4'h4)
                    os_receive_count_l1 <= os_receive_count_l1 + 1;
            end else begin
                os_sent_count <= 4'h0;
                os_receive_count_l0 <= 4'h0;
                os_receive_count_l1 <= 4'h0;
            end
			// Set d_sel to 4, fsm_training to logic high, and ts1_gen4_s to logic high
            d_sel <= 4'h4;
            fsm_training <= 1'b1;
            ts1_gen4_s <= 1'b1;
        end
        TS2_GEN4: begin
            if (next_state == TS2_GEN4) begin
			    if (os_sent)
                os_sent_count <= os_sent_count + 1;
                if (os_in_l0 == 4'h5)
                    os_receive_count_l0 <= os_receive_count_l0 + 1;
                if (os_in_l1 == 4'h5)
                    os_receive_count_l1 <= os_receive_count_l1 + 1;
            end else begin
                os_sent_count <= 4'h0;
                os_receive_count_l0 <= 4'h0;
                os_receive_count_l1 <= 4'h0;
            end
			d_sel <= 4'h5;
            fsm_training <= 1'b1;
            ts2_gen4_s <= 1'b1;
			
        end
        TS3_GEN4: begin
            if (next_state == TS3_GEN4) begin
			    if (os_sent)
                os_sent_count <= os_sent_count + 1;
                if (os_in_l0 == 4'h6)
                    os_receive_count_l0 <= os_receive_count_l0 + 1;
                if (os_in_l1 == 4'h6)
                    os_receive_count_l1 <= os_receive_count_l1 + 1;
            end else begin
                os_sent_count <= 4'h0;
                os_receive_count_l0 <= 4'h0;
                os_receive_count_l1 <= 4'h0;
            end
			d_sel <= 4'h6;
            fsm_training <= 1'b1;
        end
        TS4_GEN4: begin
            if (next_state == TS4_GEN4) begin
			    if (os_sent)
                os_sent_count <= os_sent_count + 1;
                if (os_in_l0 == 4'h7)
                    os_receive_count_l0 <= os_receive_count_l0 + 1;
                if (os_in_l1 == 4'h7)
                    os_receive_count_l1 <= os_receive_count_l1 + 1;
            end else begin
                os_sent_count <= 4'h0;
                os_receive_count_l0 <= 4'h0;
                os_receive_count_l1 <= 4'h0;
            end
			if (next_state == CL0) begin
                 d_sel <= 4'h8;
			end	 
            else begin 
                d_sel <= 4'h7;
			end	
            fsm_training <= 1'b1;
        end
		SLOS1_GEN3 : begin		
			if (next_state == SLOS1_GEN3) begin
				if (os_sent)
				  os_sent_count <= os_sent_count + 1;
				if (os_in_l0 == 'h0)
				  os_receive_count_l0 <= os_receive_count_l0 + 1;
				if (os_in_l1 == 'h0)
				  os_receive_count_l1 <= os_receive_count_l1 + 1;
			end
			else begin
				os_sent_count <= 'h0;
                os_receive_count_l0 <= 0;
                os_receive_count_l1 <= 0;
			end
			fsm_training <= 1;
			d_sel <= 'h0;
        end 
        SLOS2_GEN3 : 
          begin
			if (next_state ==SLOS2_GEN3)
			  begin
				if (os_sent)
				  os_sent_count <= os_sent_count + 1;
				if (os_in_l0 == 'h1)
				  os_receive_count_l0 <= os_receive_count_l0 + 1;
				if (os_in_l1 == 'h1)
				  os_receive_count_l1 <= os_receive_count_l1 + 1;
			  end
			else 
			  begin
				os_sent_count <= 'h0;
                os_receive_count_l0 <= 0;
                os_receive_count_l1 <= 0;
			  end
			fsm_training <= 1;
			d_sel <= 'h1;  
          end
		
        TS1_GEN3: begin // Clock edge sensitive always block for counting sent and received TS1 in TS1_GEN3 state
            if (next_state == TS1_GEN3) begin
			    if (os_sent)
                os_sent_count <= os_sent_count + 1;
                if (os_in_l0 == 4'h2)
                    os_receive_count_l0 <= os_receive_count_l0 + 1;
                if (os_in_l1 == 4'h2)
                    os_receive_count_l1 <= os_receive_count_l1 + 1;
            end else begin
                os_sent_count <= 4'h0;
                os_receive_count_l0 <= 4'h0;
                os_receive_count_l1 <= 4'h0;
            end
			fsm_training <= 1;
			d_sel <= 4'h2;
        end
        TS2_GEN3: begin // Clock edge sensitive always block for counting sent and received TS2 in TS2_GEN3 state
            if (next_state == TS2_GEN3) begin
			    if (os_sent)
                os_sent_count <= os_sent_count + 1;
                if (os_in_l0 == 4'h3)
                    os_receive_count_l0 <= os_receive_count_l0 + 1;
                if (os_in_l1 == 4'h3)
                    os_receive_count_l1 <= os_receive_count_l1 + 1;
            end else begin
                os_sent_count <= 4'h0;
                os_receive_count_l0 <= 4'h0;
                os_receive_count_l1 <= 4'h0;
            end
			if (next_state == CL0) begin
                 d_sel <= 4'h8;
			end	 
            else begin 
                d_sel <= 4'h3;
			end	
            fsm_training <= 1'b1;
        end
		CL0: begin
		    d_sel <= 'h8; 
		end
        default: begin
            d_sel <= 'h9;
            gen_speed <= 0;
            c_data_out <= 'h0;
            c_address <= 'h0;
            c_read <= 0;   
            c_write <= 0;   		
	        os_sent_count <= 'h0;
            os_receive_count_l0 <= 0;
            os_receive_count_l1 <= 0;
            fsm_training <= 0;
            ts1_gen4_s <= 0;
            ts2_gen4_s <= 0;
		    usb4_detected <= 0;
	        other_adapter_generation <= 0;
			cable_generation <= 0;
        end
    endcase
	end
end
//Transactions
always @ (posedge fsm_clk or negedge reset_n) begin
    if (!reset_n) begin
        // Reset condition
        AT_flag <= 0;
        AT_flag_is_sent <= 0;
        trans_sel <= 4'h0;
        s_write_o <= 0;
        s_read_o <= 0;
        s_address_o <= 4'b0;
        s_data_o <= 4'b0;
        disconnect_sbtx <= 1;
    end else begin
        // Non-reset condition
        if (current_state == CLD_EXCHANGE_1) begin
            AT_flag <= 1;
            AT_flag_is_sent <= (trans_sel == 4'h2) ? 1 : AT_flag_is_sent;
        end else begin 
		    AT_flag <= 0;
            AT_flag_is_sent <= 0;
		end	
		if (current_state == DISABLED || current_state == CLD_CABLE) begin
            disconnect_sbtx <= 1;
            trans_sel <= 4'h0;
            s_read_o <= 0;
            s_write_o <= 0;
        end else begin
            if (((AT_flag && !AT_flag_is_sent) || (current_state == CLD_EXCHANGE_1 && trans_error)) && !sync_busy) begin
                trans_sel <= 4'h2;
                s_read_o <= 0;
                s_write_o <= 0;
                disconnect_sbtx <= 0;
            end else if (t_valid && s_write_i) begin
                s_write_o <= 1;
                s_read_o <= 0;
                s_address_o <= s_address_i;
                s_data_o <= payload_in;
            end  else if (t_valid && s_read_i) begin
			    if(!sync_busy)
			        trans_sel <= 'h3;
			        s_read_o <= 1;
			        s_write_o <= 0;
	                s_address_o <= s_address_i;			  
			        disconnect_sbtx <= 0;
	        end else begin
		            trans_sel <= 'h0;
			        disconnect_sbtx <= 0;
			        s_read_o <= 0;
			        s_write_o <= 0;
		        end
            end
        end
    end


// State transition logic
always @(posedge fsm_clk or negedge reset_n) begin
    if (!reset_n)
        current_state <= DISABLED;
    else
        current_state <= next_state;
end

// State-specific logic
always @(*) begin
    case (current_state)
        DISABLED: begin
            if (lane_disable)
                next_state = DISABLED;
		else if (!lane_disable && !tdisabled_min)
                next_state = DISABLED;
            else
                next_state = CLD_CABLE;
        end
        CLD_CABLE: begin
            if (lane_disable)
                next_state = DISABLED;
            else if (usb4_detected)
                next_state = CLD_DETECT;
            else
                next_state = CLD_CABLE;
        end
        CLD_DETECT: begin
            if (lane_disable)
                next_state = DISABLED;
            else if (!disconnect_sbrx)
                next_state = CLD_EXCHANGE_1;
            else
                next_state = CLD_DETECT;
        end
        CLD_EXCHANGE_1: begin
            if (lane_disable)
                next_state = DISABLED;
            else if (disconnect_sbrx)
                next_state = CLD_DETECT;
            else if (t_valid && !trans_error)
                next_state = CLD_EXCHANGE_2;
            else
                next_state = CLD_EXCHANGE_1;
        end
        CLD_EXCHANGE_2: begin
            if (lane_disable)
                next_state = DISABLED;
            else if (disconnect_sbrx)
                next_state = CLD_DETECT;
            else if (trans_sent)
                next_state = CLD_CLOCK;
            else
                next_state = CLD_EXCHANGE_2;
        end
        CLD_CLOCK: begin
            if (lane_disable)
                next_state = DISABLED;
            else if ((gen_speed == 2'b00) && new_sym)
                next_state = TS1_GEN4;
            else if ((gen_speed == 2'b01 || gen_speed == 2'b10) && new_sym)
                next_state = SLOS1_GEN3;
            else
                next_state = CLD_CLOCK;
        end
        TS1_GEN4: begin
            if (lane_disable)
                next_state = DISABLED;
            else if (disconnect_sbrx)
                next_state = CLD_DETECT;
            else if (ttraining_error_timeout || tgen4_ts1_timeout)
                next_state = CLD_EXCHANGE_1;
            else if (os_sent_count == 16 && os_receive_count_l0 == 1 && os_receive_count_l1 == 1)
                next_state = TS2_GEN4;
            else
                next_state = TS1_GEN4;
        end
        TS2_GEN4: begin
            if (lane_disable)
                next_state = DISABLED;
            else if (disconnect_sbrx)
                next_state = CLD_DETECT;
            else if (ttraining_error_timeout || tgen4_ts2_timeout)
                next_state = CLD_EXCHANGE_1;
            else if (os_sent_count == 16 && os_receive_count_l0 == 1 && os_receive_count_l1 == 1)
                next_state = TS3_GEN4;
            else
                next_state = TS2_GEN4;
        end
        TS3_GEN4: begin
            if (lane_disable)
                next_state = DISABLED;
            else if (disconnect_sbrx)
                next_state = CLD_DETECT;
            else if (ttraining_error_timeout)
                next_state = CLD_EXCHANGE_1;
            else if (os_sent_count == 16 && os_receive_count_l0 == 1 && os_receive_count_l1 == 1)
                next_state = TS4_GEN4;
            else
                next_state = TS3_GEN4;
        end
        TS4_GEN4: begin
            if (lane_disable)
                next_state = DISABLED;
            else if (disconnect_sbrx)
                next_state = CLD_DETECT;
            else if (ttraining_error_timeout)
                next_state = CLD_EXCHANGE_1;
            else if (os_sent_count == 16 && os_receive_count_l0 == 1 && os_receive_count_l1 == 1 && new_sym)
                next_state = CL0; // Transition to CL0 after fulfilling the condition
            else
                next_state = TS4_GEN4;
        end
        SLOS1_GEN3: begin
            if (lane_disable)
                next_state = DISABLED;
            else if (disconnect_sbrx)
                next_state = CLD_DETECT;
            else if (ttraining_error_timeout)
                next_state = CLD_EXCHANGE_1;
            else if (os_sent_count == 2 && os_receive_count_l0 == 2 && os_receive_count_l1 == 2)
                next_state = SLOS2_GEN3; // Transition to SLOS2_GEN3 after fulfilling the condition
            else
                next_state = SLOS1_GEN3;
        end
        SLOS2_GEN3: begin
            if (lane_disable)
                next_state = DISABLED;
            else if (disconnect_sbrx)
                next_state = CLD_DETECT;
            else if (ttraining_error_timeout)
                next_state = CLD_EXCHANGE_1;
            else if (os_sent_count == 2 && os_receive_count_l0 == 2 && os_receive_count_l1 == 2)
                next_state = TS1_GEN3; // Transition to TS1_GEN3 after fulfilling the condition
            else
                next_state = SLOS2_GEN3;
        end
        TS1_GEN3: begin
            if (lane_disable)
                next_state = DISABLED;
            else if (disconnect_sbrx)
                next_state = CLD_DETECT;
            else if (ttraining_error_timeout)
                next_state = CLD_EXCHANGE_1;
            else if ((gen_speed == 2'b01 && os_sent_count == 16 && os_receive_count_l0 == 2 && os_receive_count_l1 == 2) ||
                     (gen_speed == 2'b10 && os_sent_count == 32 && os_receive_count_l0 == 2 && os_receive_count_l1 == 2))
                next_state = TS2_GEN3; // Transition to TS2_GEN3 after fulfilling the condition
            else
                next_state = TS1_GEN3;
        end
        TS2_GEN3: begin
            if (lane_disable)
                next_state = DISABLED;
            else if (disconnect_sbrx)
                next_state = CLD_DETECT;
            else if (ttraining_error_timeout)
                next_state = CLD_EXCHANGE_1;
            else if (((gen_speed == 2'b01 && os_sent_count == 8 && os_receive_count_l0 == 2 && os_receive_count_l1 == 2) ||
                     (gen_speed == 2'b10 && os_sent_count == 16 && os_receive_count_l0 == 2 && os_receive_count_l1 == 2))&& new_sym)
                next_state = CL0; // Transition to CL0 after fulfilling the condition
            else
                next_state = TS2_GEN3;
        end
        CL0: begin
            if (lane_disable)
                next_state = DISABLED;
            else if (disconnect_sbrx)
                next_state = CLD_DETECT;
            else
                next_state = CL0;
        end
        default: next_state = DISABLED;
    endcase
end

// Output logic and other state-specific logic...

endmodule
`resetall	
