////////////////////////////////////////////////////////////////////////////////////
// Block: logical_layer - Top Module
//
// Author: Ahmed Zakaria
// Project Contributers: Ahmed Zakaria, Ahmed Tarek, Seif Hamdy, Hager Walid
//
// Description: Top module of the USB4 Logical Layer 
//
/////////////////////////////////////////////////////////////////////////////////////

`default_nettype none

module logical_layer_no_scr
(
  input  wire        local_clk, 
  input  wire        sb_clk, 
  input  wire        rst, 
  input  wire        lane_disable, 
  input  wire        sbrx, 
  input  wire [31:0] c_data_in, 
  input  wire [7:0]  transport_layer_data_in, 
  input  wire        lane_0_rx_i, 
  input  wire        lane_1_rx_i,
  input  wire        enable_deser,
  output wire [7:0]  transport_layer_data_out,
  output wire        sbtx, 
  output wire        lane_0_tx_o, 
  output wire        lane_1_tx_o,  
  output wire        c_read, 
  output wire        c_write,  
  output wire [7:0]  c_address,
  output wire [31:0] c_data_out,
  output wire        enable_scr,
  output wire        cl0_s,
  output wire        transport_data_flag
);


wire         fsm_clk, 
             ser_clk, 
			 enc_clk,
			 ms_clk;

wire [1:0]   gen_speed;

wire [3:0]   d_sel;
wire [3:0]   os_in_l0,
             os_in_l1;
wire         os_sent;

wire         tx_lanes_on;
wire         rx_lanes_on;
wire         enable_ser;
wire         enable_enc;
wire         enable_dec;
wire         enable_deskew;

wire [2:0]   trans_sel, 
             trans_sel_pul;
wire         busy;
wire         trans_sent;

wire         disconnect_sbtx;
wire         disconnected_s;

wire [1:0]   trans_state;
wire [23:0]  payload_in;
wire [7:0]   s_address_i;
wire         s_read_lvl, 
             s_read_pul,
             s_write_lvl, 
			 s_write_pul,
             t_valid_lvl, 
			 t_valid_pul,
             trans_error_lvl, 
			 trans_error_pul,
             disconnect;

wire [7:0]   s_data_o;
wire [7:0]   s_address_o;
wire         s_read_o;
wire         s_write_o;

wire         tdisabled_min,
             ttraining_error_timeout,
             tgen4_ts1_timeout,
             tgen4_ts2_timeout, 			
             fsm_disabled,
             fsm_training,
             ts1_gen4_s,
             ts2_gen4_s;

wire [7:0]   lane_0_tx_bus_dis, 
             lane_1_tx_bus_dis,
             lane_0_rx_bus_dis,
             lane_1_rx_bus_dis;

wire [7:0]   lane_0_tx_dis_enc, lane_1_tx_dis_enc,
             lane_0_rx_dis_enc, lane_1_rx_dis_enc;

wire [131:0] lane_0_tx_enc_ser, lane_1_tx_enc_ser,
             lane_0_rx_enc_ser, lane_1_rx_enc_ser;

wire [23:0]  sb_read;

wire         sbtx_sel,
             crc_en;
wire [9:0]   trans;

wire         trans_ser;

wire         parity;

wire         crc_det_en, 
             crc_error;
			
wire [9:0]   sbrx_parallel;
			
wire         tdisconnect_tx_min,
             tdisconnect_rx_min,
             tconnect_rx_min;

wire         scr_rst,
             descr_rst;

wire         data_os;
wire         data_os_bus;

wire         new_sym, new_sym_pul;


control_fsm ctrl_fsm
(
  .fsm_clk                 ( fsm_clk                 ), 
  .reset_n                 ( rst                     ),
  .os_in_l0                ( os_in_l0                ),
  .os_in_l1                ( os_in_l1                ),
  .disconnect_sbrx         ( disconnect              ),
  .s_write_i               ( s_write_pul             ),
  .s_read_i                ( s_read_pul              ),
  .s_address_i             ( s_address_i             ),
  .payload_in              ( payload_in              ),
  .trans_error             ( trans_error_pul         ),
  .t_valid                 ( t_valid_pul             ),
  .os_sent                 ( os_sent                 ),
  .c_data_in               ( c_data_in               ),
  .c_data_out              ( c_data_out              ),
  .lane_disable            ( lane_disable            ),
  .sync_busy               ( busy                    ),
  .tdisabled_min           ( tdisabled_min           ),
  .ttraining_error_timeout ( ttraining_error_timeout ),
  .tgen4_ts1_timeout       ( tgen4_ts1_timeout       ),
  .tgen4_ts2_timeout       ( tgen4_ts2_timeout       ), 
  .trans_sel               ( trans_sel               ),
  .trans_sent              ( trans_sent              ),
  .disconnect_sbtx         ( disconnect_sbtx         ),
  .fsm_disabled            ( fsm_disabled            ),
  .fsm_training            ( fsm_training            ),
  .ts1_gen4_s              ( ts1_gen4_s              ),
  .ts2_gen4_s              ( ts2_gen4_s              ),
  .d_sel                   ( d_sel                   ),
  .new_sym                 ( new_sym_pul             ),
  .gen_speed               ( gen_speed               ),
  .c_address               ( c_address               ),
  .c_read                  ( c_read                  ),
  .c_write                 ( c_write                 ),
  .s_data_o                ( s_data_o                ),
  .s_address_o             ( s_address_o             ),
  .s_read_o                ( s_read_o                ),
  .s_write_o               ( s_write_o               ),
  .cl0_s                   ( cl0_s                   )
);

data_bus bus
(
  .rst                     ( rst                     ), 
  .fsm_clk                 ( fsm_clk                 ),
  .d_sel                   ( d_sel                   ),
  .lane_0_rx               ( lane_0_rx_bus_dis       ),
  .lane_1_rx               ( lane_1_rx_bus_dis       ),
  .os_in_l0                ( os_in_l0                ),
  .os_in_l1                ( os_in_l1                ),
  .lane_0_tx               ( lane_0_tx_bus_dis       ),
  .lane_1_tx               ( lane_1_tx_bus_dis       ),
  .os_sent                 ( os_sent                 ),
  .transport_layer_data_in ( transport_layer_data_in ),
  .transport_layer_data_out( transport_layer_data_out),
  .data_os                 ( data_os_bus             ),
  .tx_lanes_on             ( tx_lanes_on             ),
  .lane_rx_on              ( rx_lanes_on             )
);                                                   
												     
lane_distributer lane_dist                           
(                                                    
  .clk                     ( fsm_clk                     ),             
  .rst                     ( rst                         ),                   
  .enable_t                ( tx_lanes_on                 ),           
  .enable_r                ( enable_deskew               ),         
  .data_os_i               ( data_os                     ),         
  .data_os_o               ( data_os_bus                 ),         
  .d_sel                   ( d_sel                       ),         
  .lane_0_tx_in            ( lane_0_tx_bus_dis           ), 
  .lane_1_tx_in            ( lane_1_tx_bus_dis           ), 
  .lane_0_rx_in            ( lane_0_rx_dis_enc           ), 
  .lane_1_rx_in            ( lane_1_rx_dis_enc           ), 
  .lane_0_tx_out           ( lane_0_tx_dis_enc           ), 
  .lane_1_tx_out           ( lane_1_tx_dis_enc           ), 
  .lane_0_rx_out           ( lane_0_rx_bus_dis           ),
  .lane_1_rx_out           ( lane_1_rx_bus_dis           ),
  .enable_enc              ( enable_enc                  ),
  .rx_lanes_on             ( rx_lanes_on                 ),
  .transport_data_flag     ( transport_data_flag         )
);

encoding_block enc_block
(
  .enc_clk                 ( enc_clk                 ),
  .rst                     ( rst                     ), 
  .enable                  ( enable_enc              ),    
  .lane_0_tx               ( lane_0_tx_dis_enc       ),
  .lane_1_tx               ( lane_1_tx_dis_enc       ),
  .d_sel                   ( d_sel                   ),
  .gen_speed               ( gen_speed               ),    
  .lane_0_tx_enc_old       ( lane_0_tx_enc_ser       ),
  .lane_1_tx_enc_old       ( lane_1_tx_enc_ser       ),
  .enable_ser              ( enable_ser              ),
  .new_sym                 ( new_sym                 )
);

pul_gen new_symbol
(
.clk(fsm_clk), 
.reset_n(rst),
.lvl_sig(new_sym),
.pulse_sig(new_sym_pul)
);

decoding_block dec_block
(
  .enc_clk                 ( enc_clk                 ),
  .rst                     ( rst                     ),     
  .enable_dec              ( enable_dec              ),     
  .lane_0_rx_enc           ( lane_0_rx_enc_ser       ),
  .lane_1_rx_enc           ( lane_1_rx_enc_ser       ),
  .d_sel                   ( d_sel                   ),
  .gen_speed               ( gen_speed               ),
  .lane_0_rx               ( lane_0_rx_dis_enc       ),
  .lane_1_rx               ( lane_1_rx_dis_enc       ),
  .data_os                 ( data_os                 ),
  .enable_deskew           ( enable_deskew           )
);

lanes_ser_deser #(.WIDTH(132)) lanes_serializer_deserializer
(
  .clk                     ( ser_clk                 ), 
  .rst                     ( rst                     ),
  .enable_ser              ( enable_ser              ),
  .enable_deser            ( enable_deser           ),
  .lane_0_tx_parallel      ( lane_0_tx_enc_ser       ),
  .lane_1_tx_parallel      ( lane_1_tx_enc_ser       ),
  .gen_speed               ( gen_speed               ),
  .lane_0_rx_ser           ( lane_0_rx_i             ),
  .lane_1_rx_ser           ( lane_1_rx_i             ),
  .lane_0_tx_ser           ( lane_0_tx_o             ),
  .lane_1_tx_ser           ( lane_1_tx_o             ),
  .scr_rst                 ( scr_rst                 ),
  .enable_scr              ( enable_scr              ),
  .lane_0_rx_parallel      ( lane_0_rx_enc_ser       ), 
  .lane_1_rx_parallel      ( lane_1_rx_enc_ser       ),
  .descr_rst               ( descr_rst               ), 
  .enable_dec              ( enable_dec              ) 
);

sb_registers sb_reg
(
  .fsm_clk                 ( fsm_clk                 ), 
  .rst                     ( rst                     ), 
  .s_read                  ( s_read_o                ), 
  .s_write                 ( s_write_o               ),
  .s_data                  ( s_data_o                ), 
  .s_address               ( s_address_o             ),
  .sb_read                 ( sb_read                 )
);

pulse_sync_3bit pul_sync_fsm_gen
(
  .sig_3bit                ( trans_sel               ), 
  .rst                     ( rst                     ), 
  .clk_a                   ( fsm_clk                 ), 
  .clk_b                   ( sb_clk                  ), 
  .sig_sync_3bit           ( trans_sel_pul           ), 
  .busy                    ( busy                    )
);

transactions_gen_fsm trans_gen 
(
  .sb_clk                  ( sb_clk                  ),                           
  .rst                     ( rst                     ),                              
  .sb_read                 ( sb_read                 ),    
  .trans_sel               ( trans_sel_pul           ), 
  .trans_sent              ( trans_sent              ), 
  .trans_state             ( trans_state             ), 
  .disconnect_sbtx         ( disconnect_sbtx         ),    
  .disconnected_s          ( disconnected_s          ),    
  .tdisconnect_tx_min      ( tdisconnect_tx_min      ),    
  .trans                   ( trans                   ),               
  .crc_en                  ( crc_en                  ),              
  .sbtx_sel                ( sbtx_sel                )            
);

serializer /*#(.WIDTH(10))*/ sbtx_serializer
(
  .clk                     ( sb_clk                  ), 
  .rst                     ( rst                     ),
  .parallel_in             ( trans                   ),
  .ser_out                 ( trans_ser               ),
  .trans_state             ( trans_state             )
);

crc_16 #(.SEED('hFFFF)) crc_gen
( 
  .sb_clk                  ( sb_clk                  ),          
  .rst                     ( rst                     ),          
  .trans_ser               ( trans_ser               ),    
  .crc_en                  ( crc_en                  ),       
  .crc_active              ( sbtx_sel                ),   
  .parity                  ( parity                  )        
);

sbtx_mux crc_trans_mux
(
  .sb_clk                  ( sb_clk                  ), 
  .rst                     ( rst                     ), 
  .parity                  ( parity                  ), 
  .sbtx_sel                ( sbtx_sel                ), 
  .trans_ser               ( trans_ser               ),
  .sbtx                    ( sbtx                    )	
);

crc_16_rec #(.SEED('hFFFF)) crc_rec
( 
  .sb_clk                  ( sb_clk                  ),          
  .rst                     ( rst                     ),          
  .trans_ser               ( sbrx                    ),    
  .crc_en                  ( crc_det_en              ),          
  .error                   ( crc_error               )        
);

deserializer #(.WIDTH(10)) sbrx_deser
(
  .clk                     ( sb_clk                  ), 
  .rst                     ( rst                     ),
  .in_bit                  ( sbrx                    ),
  .parallel_data           ( sbrx_parallel           ) 
);

transactions_fsm trans_rec
(
  .sb_clk                  ( sb_clk                  ),
  .rst                     ( rst                     ),
  .sbrx                    ( sbrx_parallel           ),
  .error                   ( crc_error               ),
  .tdisconnet              ( tdisconnect_rx_min      ),
  .tconnect                ( tconnect_rx_min         ),
  .t_valid                 ( t_valid_lvl             ),
  .trans_error             ( trans_error_lvl         ),
  .payload_in              ( payload_in              ),
  .s_read                  ( s_read_lvl              ),
  .s_write                 ( s_write_lvl             ),
  .s_address               ( s_address_i             ),
  .disconnect              ( disconnect              ),
  .crc_det_en              ( crc_det_en              )
);

pulse_generator pul_gen
(
  .clk                     ( fsm_clk                 ), 
  .reset_n                 ( rst                     ),
  .s_read                  ( s_read_lvl              ),
  .s_write                 ( s_write_lvl             ),
  .trans_error             ( trans_error_lvl         ),
  .t_valid                 ( t_valid_lvl             ),
  .s_read_pul              ( s_read_pul              ),
  .s_write_pul             ( s_write_pul             ),
  .trans_error_pul         ( trans_error_pul         ),
  .t_valid_pul             ( t_valid_pul             )
);

timer timer
(
  .sb_clk                  ( sb_clk                  ), 
  .clk_b                   ( ms_clk                  ), 
  .rst                     ( rst                     ), 
  .disconnected_s          ( disconnected_s          ),
  .fsm_disabled            ( fsm_disabled            ),
  .fsm_training            ( fsm_training            ),
  .ts1_gen4_s              ( ts1_gen4_s              ),
  .ts2_gen4_s              ( ts2_gen4_s              ),
  .sbrx                    ( sbrx                    ),
  .tdisconnect_tx_min      ( tdisconnect_tx_min      ),
  .tdisconnect_rx_min      ( tdisconnect_rx_min      ),
  .tconnect_rx_min         ( tconnect_rx_min         ),
  .tdisabled_min           ( tdisabled_min           ),
  .ttraining_error_timeout ( ttraining_error_timeout ),
  .tgen4_ts1_timeout       ( tgen4_ts1_timeout       ),
  .tgen4_ts2_timeout       ( tgen4_ts2_timeout       )      
);

clock_div clk_div
(
  .local_clk               ( local_clk               ), 
  .rst                     ( rst                     ), 
  .gen_speed               ( gen_speed               ),
  .ser_clk                 ( ser_clk                 ), 
  .enc_clk                 ( enc_clk                 ), 
  .fsm_clk                 ( fsm_clk                 )
);

ms_clock_div ms_clk_div 
(
  .sb_clk                  ( sb_clk                  ), 
  .rst                     ( rst                     ), 
  .ms_clk                  ( ms_clk                  )
);

endmodule

`resetall
