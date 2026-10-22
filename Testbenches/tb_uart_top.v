
`timescale 1ns/1ps

module tb_uart_top;

    reg clk;
    reg reset;
    reg tx_start;
    reg [7:0] tx_data;

    wire tx;
    wire tx_busy;
    wire tx_done;

    // Instantiate the complete UART design
    uart_top #(
        .CLK_FREQ(100),
        .BAUD_RATE(10)
    ) uut (
        .clk(clk),
        .reset(reset),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx(tx),
        .tx_busy(tx_busy),
        .tx_done(tx_done)
    );

    // 10 ns clock period
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // Generate waveform
    initial begin
        $dumpfile("uart_top.vcd");
        $dumpvars(0, tb_uart_top);
    end

    // Apply inputs and test transmission
    initial begin
        reset = 1'b1;
        tx_start = 1'b0;
        tx_data = 8'hA5;

        repeat (4) @(negedge clk);
        reset = 1'b0;

        repeat (2) @(negedge clk);
        tx_start = 1'b1;
        @(negedge clk);
        tx_start = 1'b0;

        // Wait for transmission to complete
        wait (tx_done == 1'b1);

        $display("PASS: UART transmission completed.");
        $display("Transmitted data: 0x%h", tx_data);

        repeat (3) @(negedge clk);
        $finish;
    end

    // Monitor important signals
    initial begin
        $monitor(
            "Time=%0t | TX=%b | Busy=%b | Done=%b | Data=%h",
            $time, tx, tx_busy, tx_done, tx_data
        );
    end

    // Prevent simulation from hanging forever
    initial begin
        #20000;
        $display("ERROR: Simulation timed out.");
        $finish;
    end

endmodule
