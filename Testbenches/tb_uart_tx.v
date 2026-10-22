
`timescale 1ns/1ps

module tb_uart;

    // Inputs to UART TX
    reg clk;
    reg reset;
    reg tx_start;
    reg [7:0] tx_data;
    reg baud_tick;

    // Outputs from UART TX
    wire tx;
    wire tx_busy;
    wire tx_done;
    wire [1:0] state;

    integer baud_counter;

    // Instantiate the UART transmitter
    uart_tx uut (
        .clk(clk),
        .reset(reset),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .baud_tick(baud_tick),
        .tx(tx),
        .tx_busy(tx_busy),
        .tx_done(tx_done),
        .state(state)
    );

    // 100 MHz clock: 10 ns period
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // Generate baud_tick every 10 clock cycles
    always @(posedge clk) begin
        if (reset) begin
            baud_counter <= 0;
            baud_tick <= 1'b0;
        end
        else if (baud_counter == 9) begin
            baud_counter <= 0;
            baud_tick <= 1'b1;
        end
        else begin
            baud_counter <= baud_counter + 1;
            baud_tick <= 1'b0;
        end
    end

    // Test sequence
    initial begin
        $dumpfile("uart_tx.vcd");
        $dumpvars(0, tb_uart);

        reset = 1'b1;
        tx_start = 1'b0;
        tx_data = 8'hA5;
        baud_tick = 1'b0;
        baud_counter = 0;

        // Reset the transmitter
        repeat (4) @(negedge clk);
        reset = 1'b0;

        // Request transmission
        @(negedge clk);
        tx_start = 1'b1;

        @(negedge clk);
        tx_start = 1'b0;

        // Wait for completion
        wait (tx_done == 1'b1);
        $display("PASS: Transmission completed at time %0t", $time);

        repeat (3) @(negedge clk);
        $finish;
    end

    // Display signals in Terminal
    initial begin
        $monitor("Time=%0t | State=%b | TX=%b | Busy=%b | Done=%b",
                 $time, state, tx, tx_busy, tx_done);
    end

    // Timeout protection
    initial begin
        #5000;
        $display("ERROR: Simulation timed out.");
        $finish;
    end

endmodule
