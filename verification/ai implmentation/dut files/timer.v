`default_nettype none

module timer (
    input wire sb_clk,       // high clock frequency
    input wire clk_b,        // slow clock frequency
    input wire rst,          // reset signal

    input wire disconnected_s,
    input wire fsm_disabled,
    input wire fsm_training,
    input wire ts1_gen4_s,
    input wire ts2_gen4_s,
    input wire sbrx,

    output reg tdisconnect_tx_min,
    output reg tdisconnect_rx_min,
    output reg tconnect_rx_min,
    output reg tdisabled_min,
    output reg ttraining_error_timeout,
    output reg tgen4_ts1_timeout,
    output reg tgen4_ts2_timeout
    );

// Parameter values
parameter TDISCONNECT_TX   = 1;
parameter TDISCONNECT_RX   = 14;
parameter TCONNECT_RX      = 25;
parameter TDISABLED        = 10;
parameter TTRAINING_ERROR  = 500;
parameter TGEN4_TS1        = 400;
parameter TGEN4_TS2        = 200;

// Internal counters
reg [15:0] disconnect_tx_count;
reg [3:0] disconnect_rx_count;
reg [4:0] connect_rx_count;
reg [9:0] disabled_count;
reg [8:0] training_error_count;
reg [8:0] gen4_ts1_count;
reg [7:0] gen4_ts2_count;

// Counter increments for sb_clk
always @(posedge sb_clk or negedge rst) begin
    if (~rst) begin
        disconnect_rx_count <= 0;
        connect_rx_count <= 0;
        training_error_count <= 0;
    end else begin
        if (~sbrx) begin
            if (disconnect_rx_count < TDISCONNECT_RX)
                disconnect_rx_count <= disconnect_rx_count + 1;
            connect_rx_count <= 0;
        end else if (sbrx) begin
            if (connect_rx_count < TCONNECT_RX)
                connect_rx_count <= connect_rx_count + 1;
            disconnect_rx_count <= 0;
        end
    end

    if (fsm_training) begin
        if (training_error_count < TTRAINING_ERROR)
            training_error_count <= training_error_count + 1;
        else
            training_error_count <= 0;
    end

end

// Counter increments for clk_b
always @(posedge clk_b or negedge rst) begin
    if (~rst) begin
        disconnect_tx_count <= 0;
        disabled_count <= 0;
        gen4_ts1_count <= 0;
        gen4_ts2_count <= 0;
    end else begin
        if (disconnected_s) begin
            if (disconnect_tx_count < TDISCONNECT_TX)
                disconnect_tx_count <= disconnect_tx_count + 1;
            else
                disconnect_tx_count <= 0;
        end
        if (fsm_disabled) begin
            if (disabled_count < TDISABLED)
                disabled_count <= disabled_count + 1;
            else
                disabled_count <= 0;
        end
        if (ts1_gen4_s) begin
            if (gen4_ts1_count < TGEN4_TS1)
                gen4_ts1_count <= gen4_ts1_count + 1;
            else
                gen4_ts1_count <= 0;
        end
        if (ts2_gen4_s) begin
            if (gen4_ts2_count < TGEN4_TS2)
                gen4_ts2_count <= gen4_ts2_count + 1;
            else
                gen4_ts2_count <= 0;
        end
    end
end

// Output assignment based on counter values for sb_clk
always @* begin
    tdisconnect_rx_min = (disconnect_rx_count == TDISCONNECT_RX);
    tconnect_rx_min = (connect_rx_count == TCONNECT_RX);
    ttraining_error_timeout = (training_error_count == TTRAINING_ERROR);
end

// Output assignment based on counter values for clk_b
always @* begin
    tdisconnect_tx_min = (disconnect_tx_count == TDISCONNECT_TX);
    tdisabled_min = (disabled_count == TDISABLED);
    tgen4_ts1_timeout = (gen4_ts1_count == TGEN4_TS1);
    tgen4_ts2_timeout = (gen4_ts2_count == TGEN4_TS2);
end

endmodule
