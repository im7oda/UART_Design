module uart_rx (
    input clk, rst_n,
    input s_tick,
    input rx_in,
    output reg rx_done,  // a flag to announce that the all Byte (8-bits) is done.
    output reg [7:0] rx_data
);


// States parameters
localparam IDLE = 2'b00;
localparam START = 2'b01;
localparam DATA = 2'b10;
localparam STOP = 2'b11;

reg [1:0] cs, ns;

reg [3:0] s_tick_counter;
reg [2:0] bit_index;
reg [7:0] rx_shift_reg; // register to store the rx_data

reg rx_sync1;
reg rx;     // rx after the 2-stage synchronizer

// the 2-Stage Synchronizer
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        // default state is 1
        rx_sync1 <= 1'b1;
        rx <= 1'b1;
    end
    
    else begin
        rx_sync1 <= rx_in;
        rx <= rx_sync1;
    end
end

// State Memory (cs)
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cs <= IDLE;
    end
    else begin
        cs <= ns;
    end
end

// Next State
always @(*) begin
    case (cs)
        IDLE: begin
            if(rx == 1'b0)
                ns = START;
            else
                ns = IDLE;
        end 

        START: begin
            if((s_tick == 1'b1) && (s_tick_counter == 4'd7)) begin
                if(rx == 0) 
                    ns = DATA;
                else 
                    ns = IDLE; // Glitch state
            end

            else
                ns = START;
            
        end

        DATA: begin
            if((s_tick == 1'b1) && (s_tick_counter == 4'd15) && (bit_index == 3'd7))
                ns = STOP;
            
            else
                ns = DATA;
            
        end 

        STOP: begin
            if((s_tick == 1'b1) && (s_tick_counter == 4'd15))
                ns = IDLE;
            else 
                ns = STOP;
        end 

        default: ns = IDLE;
    endcase
end

// Output Logic
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        rx_data <= 8'd0;
        rx_done <= 1'b0;
        rx_shift_reg <= 8'd0;
        s_tick_counter <= 4'd0;
        bit_index <= 3'd0;
    end

    else begin
        case (cs)
            IDLE: begin
                rx_done <= 1'b0;
                s_tick_counter <= 4'd0;
                bit_index <= 3'd0;

            end

            START: begin
                if(s_tick == 1'b1) begin
                    if(s_tick_counter == 4'd7) begin
                        s_tick_counter <= 4'd0;
                    end
                    else
                        s_tick_counter <= s_tick_counter + 1;
                    
                end
            end

            DATA: begin
                if(s_tick == 1'b1) begin
                    if(s_tick_counter == 4'd15) begin
                        rx_shift_reg[bit_index] <= rx;
                        
                        if(bit_index == 3'd7) begin
                            bit_index <= 3'd0;
                        end
                        else begin
                            bit_index <= bit_index + 1;
                        end

                        s_tick_counter <= 4'd0;
                    end

                    else
                        s_tick_counter <= s_tick_counter + 1;
                    
                end
            end

            STOP: begin
                if(s_tick == 1'b1) begin
                    if(s_tick_counter == 4'd15) begin
                    
                        rx_done <= 1'b1;
                        rx_data <= rx_shift_reg;

                        s_tick_counter <= 4'd0;
                    end

                    else
                        s_tick_counter <= s_tick_counter + 1;
                    
                end
            end

            default: begin
                rx_done <= 1'b0;
                s_tick_counter <= 4'd0;
                bit_index <= 3'd0;
            end
        endcase
    end
end
    
endmodule
