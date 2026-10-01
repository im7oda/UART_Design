module tb ();
    // I/P
    reg clk, rst_n;
    reg tx_start;
    reg [7:0] tx_data;

    wire rx_in;

    // O/P
    wire tx_out;
    wire tx_done;
    wire [7:0] rx_data;
    wire rx_done;

    // Loopback Setup
    assign rx_in = tx_out;

    // Top Module Instantiation
    top_module DUT(
        .clk(clk), .rst_n(rst_n),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .rx_in(rx_in),
        
        .tx_out(tx_out),
        .tx_done(tx_done),
        .rx_data(rx_data),
        .rx_done(rx_done)
    );

    // Clk generation
    initial begin
        clk = 1'b0;
        forever begin
            // 50-MHz CLK 
            #10 clk = ~clk;
        end
    end

    // Test
    initial begin
        // *** Reset-Check ***
        rst_n = 1'b0;
        tx_start = 1'b0;
        tx_data = 8'h00;

        repeat(2) @(negedge clk);   // Wait 2 negative edge of CLK

        if (tx_done == 1) begin
            $display(" [%0t ns]: !! Error, tx_done = 1 (should be 0).",$time);
            $stop;
        end

        if (rx_done == 1) begin
            $display(" [%0t ns]: !! Error, rx_done = 1 (should be 0).",$time);
            $stop;
        end

        if (tx_out == 0) begin
            $display(" [%0t ns]: !! Error, tx_out = 0 (should be 1).",$time);
            $stop;
        end
        
        rst_n = 1'b1;
        $display(" [%0t ns]: Reset Verification is done Successfully.", $time);
        @(negedge clk);

        // *** Single Byte Loopback test ***
        tx_data = 8'hA5;    // tx_data = 8'b10100101
        tx_start = 1;
        @(negedge clk);     
        tx_start = 0;       // active tx_start for 1-clk cycle then deActive it

        @(posedge rx_done);  // wait when rx_done = 1
        if (rx_data == 8'hA5) begin
            $display(" [%0t ns]: Single Byte Loopback test is done Successfully.", $time);
        end
        else begin
            $display(" [%0t ns]: !!! Error in Single Byte Loopback test. actual rx_data = 8'h%0h , while rx_data should = 8'hA5", $time, rx_data);
            $stop;
        end

        
        // *** Back to Back Test ***  send 2 Byte consecutively.

        fork
            // TX thread.
            begin
                // Sending the first Byte
                @(posedge tx_done);     // wait until the tx finishes sending the last byte.
                @(negedge clk);

                tx_data = 8'h35;    // tx_data = 8'b00110101
                tx_start = 1;
                @(negedge clk);     
                tx_start = 0;

                // Sending the second Byte
                @(posedge tx_done);     // wait until the tx finishes sending the last byte.
                @(negedge clk);

                tx_data = 8'hFF;    // tx_data = 8'b11111111
                tx_start = 1;
                @(negedge clk);     
                tx_start = 0;
            end

            // RX thread
            begin

                 @(posedge rx_done); // Wating for the first Byte (8'h35) to be received successfully then check.
                if (rx_data == 8'h35) begin
                    $display(" [%0t ns]: Back to Back - Byte 1 passed.", $time);
                end
                else begin
                    $display(" [%0t ns]: !!! Error in Back to Back - Byte 1 test. actual rx_data = 8'h%0h , while rx_data should = 8'h35", $time, rx_data);
                    $stop;
                end

                @(posedge rx_done); // Wating for the second Byte (8'hFF) to be received successfully then check.
                if (rx_data == 8'hFF) begin
                    $display(" [%0t ns]: Back to Back - Byte 2 passed.", $time);
                end
                else begin
                    $display(" [%0t ns]: !!! Error in Back to Back - Byte 2 test. actual rx_data = 8'h%0h , while rx_data should = 8'hFF", $time, rx_data);
                    $stop;
                end
            end

        join


        $display("All the tests done successfully");
        $stop;

    end

endmodule