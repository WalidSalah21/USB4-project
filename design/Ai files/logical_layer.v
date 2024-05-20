////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Block: logical_layer
// Author: Seif Hamdy Fadda
// 
// Description: the top module combining all blocks of usb4 logical layer.
// Note: This block is implemented using AI (chatgpt3.5).
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

`default_nettype none

module logical_layer(
    input wire local_clk, sb_clk, rst, lane_disable, sbrx, enable_deser,
    input wire [31:0] c_data_in,
    input wire [7:0] transport_layer_data_in,
    input wire lane_0_rx_i, lane_1_rx_i,
    output wire [7:0] transport_layer_data_out,
    output wire sbtx,
    output wire lane_0_tx_o, lane_1_tx_o,
    output wire c_read, c_write,
    output wire [7:0] c_address,
    output wire [31:0] c_data_out,
    output wire enable_scr,
	output wire cl0_s,
    output wire transport_data_flag
);
wire [3:0]   d_sel;
wire [3:0]   os_in_l0, os_in_l1;
wire         os_sent;
wire         tx_lanes_on;
wire         rx_lanes_on;
wire         data_os_i;
wire         data_os_o;
wire [7:0]   lane_0_tx_parallel, lane_1_tx_parallel, lane_0_rx_parallel,lane_1_rx_parallel;
wire [7:0]   lane_0_rx_encoder,lane_1_rx_encoder, lane_0_tx_out_encoder, lane_1_tx_out_encoder;
wire         fsm_clk, ser_clk, enc_clk,ms_clk;
wire         disconnect_sbrx;
wire         s_write_i, s_read_i, t_valid, trans_error, sync_busy;
wire [7:0]   s_address_i;
wire [23:0]  payload_in;
wire         tdisabled_min, ttraining_error_timeout, tgen4_ts1_timeout, tgen4_ts2_timeout, fsm_disabled, fsm_training, ts1_gen4_s, ts2_gen4_s;
wire [2:0]   trans_sel;
wire         trans_sent;
wire         disconnect_sbtx;
wire         new_sym;
wire         enable_enc;
wire [1:0]   gen_speed;
wire [7:0]   s_data_o;
wire [7:0]   s_address_o;
wire         s_read_o;
wire         s_write_o;
wire [131:0] lane_0_tx_enc_old, lane_1_tx_enc_old, lane_0_rx_enc_old, lane_1_rx_enc_old;
wire         new_sym_level;
wire         enable_deskew;
wire         enable_ser;
wire         lane_0_tx_ser_out, lane_1_tx_ser_out, lane_0_rx_ser_out, lane_1_rx_ser_out;
wire         scr_rst;
wire         enable_dec;
wire         descr_rst;
wire [23:0]  sb_read;
wire [2:0]   trans_sel_pulse;
wire [1:0]   trans_state;
wire         disconnected_s;
wire         tdisconnect_tx_min, tdisconnect_rx_min, tconnect_rx_min;
wire [9:0]   trans;
wire         sbtx_sel, crc_en;
wire [9:0]   sbrx_parallel_in;
wire         crc_det_en, crc_error;
wire         t_valid_level, trans_error_level;
wire         s_read_level, s_write_level;
wire         trans_ser;
wire         parity;
data_bus data_bus_inst(
    .rst(rst),
    .fsm_clk(fsm_clk),
    .lane_0_rx(lane_0_rx_parallel),
    .lane_1_rx(lane_1_rx_parallel),
    .d_sel(d_sel),
    .transport_layer_data_in(transport_layer_data_in),
    .tx_lanes_on(tx_lanes_on),   // Connects to tx_lanes_on
    .os_in_l0(os_in_l0),
    .os_in_l1(os_in_l1),
    .lane_0_tx(lane_0_tx_parallel),
    .lane_1_tx(lane_1_tx_parallel),
    .os_sent(os_sent),     // Connects to data_incoming
    .transport_layer_data_out(transport_layer_data_out),
    .rx_lanes_on(rx_lanes_on),   // Connects to rx_lanes_on
    .data_os(data_os_o)            // Connects to data_os_i
);
control_fsm ctrl_fsm(
    .fsm_clk(fsm_clk),
    .reset_n(rst),
    .os_in_l0(os_in_l0),
    .os_in_l1(os_in_l1),
    .disconnect_sbrx(disconnect_sbrx),
    .s_write_i(s_write_i),
    .s_read_i(s_read_i),
    .s_address_i(s_address_i),                   // Connects to s_address_i
    .payload_in(payload_in),                     // Connects to payload_in
    .trans_error(trans_error),               // Connects to trans_error_pul
    .t_valid(t_valid),                       // Connects to t_valid_pul
    .os_sent(os_sent),                           // Connects to os_sent
    .c_data_in(c_data_in),
    .lane_disable(lane_disable),
    .sync_busy(sync_busy),                            // Connects to busy
    .tdisabled_min(tdisabled_min),               // Connects to tdisabled_min
    .ttraining_error_timeout(ttraining_error_timeout),  // Connects to ttraining_error_timeout
    .tgen4_ts1_timeout(tgen4_ts1_timeout),      // Connects to tgen4_ts1_timeout
    .tgen4_ts2_timeout(tgen4_ts2_timeout),      // Connects to tgen4_ts2_timeout
    .trans_sel(trans_sel),                       // Connects to trans_sel
    .trans_sent(trans_sent),                     // Connects to trans_sent
    .disconnect_sbtx(disconnect_sbtx),           // Connects to disconnect_sbtx
    .fsm_disabled(fsm_disabled),                 // Connects to fsm_disabled
    .fsm_training(fsm_training),                 // Connects to fsm_training
    .ts1_gen4_s(ts1_gen4_s),                     // Connects to ts1_gen4_s
    .ts2_gen4_s(ts2_gen4_s),                     // Connects to ts2_gen4_s
    .d_sel(d_sel),                               // Connects to d_sel
    .new_sym(new_sym),                       // Connects to new_sym_pul
    .gen_speed(gen_speed),                       // Connects to gen_speed
    .c_address(c_address),                       // Connects to c_address
    .c_read(c_read),                             // Connects to c_read
    .c_write(c_write),                           // Connects to c_write
    .s_data_o(s_data_o),                         // Connects to s_data_o
    .s_address_o(s_address_o),                   // Connects to s_address_o
    .s_read_o(s_read_o),                         // Connects to s_read_o
    .s_write_o(s_write_o),                        // Connects to s_write_o
	.c_data_out(c_data_out),
	.cl0_s     ( cl0_s)
    // Add other connections here
);

clock_div clk_div_inst(
    .local_clk(local_clk),
    .rst(rst),
    .gen_speed(gen_speed),
    .ser_clk(ser_clk),
    .enc_clk(enc_clk),
    .fsm_clk(fsm_clk),
	.sb_clk(sb_clk),
	.ms_clk(ms_clk)
);



lane_distributer lane_dist_inst(
    .clk(fsm_clk),
    .rst(rst),
    .enable_t(tx_lanes_on),
    .enable_r(enable_deskew),
    .data_os_i(data_os_i),
    .data_os_o(data_os_o),
    .d_sel(d_sel),
    .lane_0_tx_in(lane_0_tx_parallel),
    .lane_1_tx_in(lane_1_tx_parallel),
    .lane_0_rx_in(lane_0_rx_encoder),
    .lane_1_rx_in(lane_1_rx_encoder),
    .lane_0_tx_out(lane_0_tx_out_encoder),
    .lane_1_tx_out(lane_1_tx_out_encoder),
    .lane_0_rx_out(lane_0_rx_parallel),
    .lane_1_rx_out(lane_1_rx_parallel),
    .enable_enc(enable_enc),
    .rx_lanes_on(rx_lanes_on),
	.transport_data_flag(transport_data_flag)
);
encoding_block encoding_block_inst(
    .enc_clk(enc_clk),
    .rst(rst),
    .enable(enable_enc),
    .lane_0_tx(lane_0_tx_out_encoder),
    .lane_1_tx(lane_1_tx_out_encoder),
    .d_sel(d_sel),
    .gen_speed(gen_speed),
    .lane_0_tx_enc_old(lane_0_tx_enc_old),
    .lane_1_tx_enc_old(lane_1_tx_enc_old),
    .enable_ser(enable_ser),
    .new_sym(new_sym_level)
);

decoding_block decoding_block_inst(
  .enc_clk                 (enc_clk),
  .rst                     (rst),     
  .enable_dec              (enable_dec),     
  .lane_0_rx_enc           (lane_0_rx_enc_old),
  .lane_1_rx_enc           (lane_1_rx_enc_old),
  .d_sel                   (d_sel),
  .gen_speed               (gen_speed),
  .enable_deskew           (enable_deskew),
  .lane_0_rx               (lane_0_rx_encoder),
  .lane_1_rx               (lane_1_rx_encoder),
  .data_os                 (data_os_i)
);
lanes_ser_deser  lanes_serializer_deserializer_inst(
  .clk                     ( ser_clk), 
  .rst                     ( rst),
  .enable_ser              ( enable_ser),
  .enable_deser            ( enable_deser),
  .lane_0_tx_parallel      ( lane_0_tx_enc_old),
  .lane_1_tx_parallel      ( lane_1_tx_enc_old),
  .gen_speed               ( gen_speed),
  .lane_0_rx_ser           ( lane_0_rx_i),
  .lane_1_rx_ser           ( lane_1_rx_i),
  .lane_0_tx_ser           ( lane_0_tx_o),
  .lane_1_tx_ser           ( lane_1_tx_o),
  .scr_rst                 ( scr_rst),
  .enable_scr              ( enable_scr),
  .lane_0_rx_parallel      ( lane_0_rx_enc_old), 
  .lane_1_rx_parallel      ( lane_1_rx_enc_old),
  .descr_rst               ( descr_rst), 
  .enable_dec              ( enable_dec) 
);
pul_gen pul_gen_inst(
.clk(fsm_clk), 
.reset_n(rst),
.lvl_sig(new_sym_level),
.pulse_sig(new_sym)
);

serializer serializer_inst(
  .clk                     (sb_clk), 
  .rst                     (rst),
  .parallel_in             (trans),
  .ser_out                 (trans_ser),
  .trans_state             (trans_state)
);

transactions_gen_fsm transactions_gen_fsm_inst (
  .sb_clk                  (sb_clk),                           
  .rst                     (rst),                              
  .sb_read                 (sb_read),    
  .trans_sel               (trans_sel_pulse), 
  .trans_sent              (trans_sent), 
  .trans_state             (trans_state), 
  .disconnect_sbtx         (disconnect_sbtx),    
  .disconnected_s          (disconnected_s),    
  .tdisconnect_tx_min      (tdisconnect_tx_min),    
  .trans                   (trans),               
  .crc_en                  (crc_en),              
  .sbtx_sel                (sbtx_sel)            
);

sb_registers sb_registers_inst (
    .fsm_clk(fsm_clk),
    .rst(rst),
    .s_read(s_read_o),
    .s_write(s_write_o),
    .s_data(s_data_o),
    .s_address(s_address_o),
    .sb_read(sb_read)
);
pulse_sync_3bit pulse_sync_3bit_inst (
  .sig_3bit                ( trans_sel), 
  .rst                     ( rst), 
  .clk_a                   ( fsm_clk), 
  .clk_b                   ( sb_clk), 
  .sig_sync_3bit           ( trans_sel_pulse), 
  .busy                    ( sync_busy)
);

transactions_fsm transactions_fsm_inst (
  .sb_clk                  (sb_clk),
  .rst                     (rst),
  .sbrx                    (sbrx_parallel_in),
  .error                   (crc_error),
  .tdisconnect              (tdisconnect_rx_min),
  .tconnect                (tconnect_rx_min),
  .t_valid                 (t_valid_level),
  .trans_error             (trans_error_level),
  .payload_in              (payload_in),
  .s_read                  (s_read_level),
  .s_write                 (s_write_level),
  .s_address               (s_address_i),
  .disconnect              (disconnect_sbrx),
  .crc_det_en              (crc_det_en)
);
sbtx_mux sbtx_mux_inst (
    .sb_clk(sb_clk),
    .rst(rst),
    .parity(parity),
    .sbtx_sel(sbtx_sel),
    .trans_ser(trans_ser),
    .sbtx(sbtx)
);

crc_16_rec  crc_16_rec_inst ( 
  .sb_clk                  (sb_clk),          
  .rst                     (rst),          
  .trans_ser               (sbrx),    
  .crc_en                  (crc_det_en),          
  .error                   (crc_error)        
);

deserializer  deserializer_inst (
  .clk                     (sb_clk), 
  .rst                     (rst),
  .in_bit                  (sbrx),
  .parallel_data           (sbrx_parallel_in) 
);

crc_16  crc_16_inst
( 
  .sb_clk                  ( sb_clk),          
  .rst                     ( rst),          
  .trans_ser               ( trans_ser),    
  .crc_en                  ( crc_en),       
  .crc_active              ( sbtx_sel),   
  .parity                  ( parity)        
);

pulse_generator pulse_generator_inst (
  .clk                     ( fsm_clk), 
  .reset_n                 ( rst),
  .s_read                  ( s_read_level),
  .s_write                 ( s_write_level),
  .trans_error             ( trans_error_level),
  .t_valid                 ( t_valid_level),
  .s_read_pul              ( s_read_i),
  .s_write_pul             ( s_write_i),
  .trans_error_pul         ( trans_error),
  .t_valid_pul             ( t_valid)
);

timer timer
(
  .sb_clk                  ( sb_clk), 
  .clk_b                   ( ms_clk), 
  .rst                     ( rst), 
  .disconnected_s          ( disconnected_s),
  .fsm_disabled            ( fsm_disabled),
  .fsm_training            ( fsm_training),
  .ts1_gen4_s              ( ts1_gen4_s),
  .ts2_gen4_s              ( ts2_gen4_s),
  .sbrx                    ( sbrx),
  .tdisconnect_tx_min      ( tdisconnect_tx_min),
  .tdisconnect_rx_min      ( tdisconnect_rx_min),
  .tconnect_rx_min         ( tconnect_rx_min),
  .tdisabled_min           ( tdisabled_min),
  .ttraining_error_timeout ( ttraining_error_timeout),
  .tgen4_ts1_timeout       ( tgen4_ts1_timeout),
  .tgen4_ts2_timeout       ( tgen4_ts2_timeout)      
);
endmodule

`resetall	
