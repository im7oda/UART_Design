graph LR
    subgraph TOP ["top_module (UART Core)"]
        direction TB
        BG["Baud Rate Generator"]
        TX["UART Transmitter (TX)"]
        RX["UART Receiver (RX)"]

        BG -- "s_tick (16x Oversampling)" --> TX
        BG -- "s_tick (16x Oversampling)" --> RX
    end

    CLK["clk (50 MHz)"] --> BG
    RST["rst_n"] --> BG

    START["tx_start"] --> TX
    DATA_IN["tx_data[7:0]"] --> TX

    TX -- "tx_done" --> DONE_TX["tx_done"]
    RX -- "rx_done" --> DONE_RX["rx_done"]
    RX -- "rx_data[7:0]" --> DATA_OUT["rx_data[7:0]"]

    TX -. "tx_out" .-> LOOPBACK["Loopback assign"]
    LOOPBACK -. "rx_in" .-> RX