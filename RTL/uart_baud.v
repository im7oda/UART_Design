module uart_baud (
    input clk, rst_n,
    output reg tick
);
    parameter SYSTEM_CLOCK = 50_000_000; // 50MHz
    parameter BAUD_RATE = 9600;
    localparam CLKS_PER_BIT = SYSTEM_CLOCK / (BAUD_RATE * 16); // 50MHZ / 9600 *16 = 325
    localparam COUNTER_WIDTH = $clog2(CLKS_PER_BIT); // here = 13

    reg [COUNTER_WIDTH-1 : 0] baud_counter;


    // Counter --> countes until (CLKS_PER_BIT - 1) and raise (tick) to (1) for clk cycle
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            baud_counter <= 0;
            tick <= 0;
        end

        else if (baud_counter == (CLKS_PER_BIT - 1)) begin
            baud_counter <= 0;
            tick <= 1;
        end

        else begin
            baud_counter <= baud_counter + 1;
            tick <= 0;
        end
        
    end
endmodule