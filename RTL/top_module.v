module top_module (
    input clk, rst_n,

    // Tx Ports
    input tx_start,
    input [7:0] tx_data,
    output tx_out, 
    output tx_done,

    // Rx Ports
    input rx_in,
    output [7:0] rx_data,
    output rx_done
);

// Tick internal signal
wire s_tick;
    
    // *** Modules instantiations ***

    // Baud-rate 
    uart_baud BAUD_INST(
        .clk(clk),
        .rst_n(rst_n),
        .tick(s_tick)
    );

    // Tx
    uart_tx TX_INST(
        .clk(clk),
        .rst_n(rst_n),
        .s_tick(s_tick),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx(tx_out),
        .tx_done(tx_done)
    );

    // Rx
    uart_rx RX_INST(
        .clk(clk),
        .rst_n(rst_n),
        .s_tick(s_tick),
        .rx_in(rx_in),
        .rx_done(rx_done),
        .rx_data(rx_data)
    ); 


endmodule