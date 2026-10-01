module uart_tx (
    input clk, rst_n, 
    input s_tick,
    input tx_start,
    input [7:0] tx_data, // the Byte (8-bit) data that we want to send it
    
    output reg tx, // the output bit that we will send it
    output reg tx_done // a flag that is raised when all the Byte (8-bit) is sent.
);
    // States parameters:
    localparam IDLE = 2'b00;
    localparam START = 2'b01;
    localparam DATA = 2'b10;
    localparam STOP = 2'b11;

    reg [1:0] cs, ns; // Current state , Next state for FSM
    reg [2:0] bit_index;
    reg [7:0] tx_shift_reg; // Register to hold the tx_data

    // s_tick
    reg tick;
    reg [3:0] s_tick_counter;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            s_tick_counter <= 0;
        end
        else if(cs == IDLE) begin
            s_tick_counter <= 0;
        end
        else if(s_tick == 1) begin
            s_tick_counter <= s_tick_counter + 1;
        end
    end

    always @(*) begin
        if (s_tick_counter == 15)
            tick = s_tick;
        else tick = 0;
    end

    // *** FSM ***

    // Current State (State Memory)
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) 
            cs <= IDLE;
        else
            cs <= ns;
    end

    // Next State Logic
    always @(*) begin
        case (cs)
            IDLE: begin
                if(tx_start == 1) ns = START;
                else ns = IDLE;
            end

            START: begin
                if(tick == 1) ns = DATA;
                else ns = START; // Wait at the START-state until the tick=1
            end

            DATA: begin
                if((tick == 1) && (bit_index == 7)) ns = STOP;
                else ns = DATA;
            end

            STOP: begin
                if(tick == 1) ns = IDLE;
                else ns = STOP;
            end

            default: ns = IDLE;
        endcase
    end

    // Output Logic
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            tx <= 1; // default value
            tx_done <= 1'b0; 
            bit_index <= 0;
            tx_shift_reg <= 0;
        end
        else begin
            case (cs)
                IDLE: begin
                    tx <= 1;
                    tx_done <= 0;
                    bit_index <= 0;

                    if(tx_start == 1) begin
                        tx_shift_reg <= tx_data; // we store the tx_data at register to keep the data if tx_data changed then
                    end
                end

                START: begin
                    tx <= 0;
                    tx_done <= 1'b0;
                    
                end

                DATA: begin
                    tx <= tx_shift_reg[bit_index];
                     
                    if(tick == 1) begin
                        bit_index <= bit_index + 1;
                    end
                end

                STOP: begin
                    tx <= 1;
                    if(tick == 1)
                        tx_done <= 1'b1;
                end
                default:begin
                    tx <= 1; // default value
                    tx_done <= 1'b0; 
                    bit_index <= 0;
                    tx_shift_reg <= 0;
                end
                     
            endcase
        end
    end

endmodule