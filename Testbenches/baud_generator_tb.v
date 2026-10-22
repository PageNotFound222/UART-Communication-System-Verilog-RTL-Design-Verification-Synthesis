
`timescale 1ns/1ps

module baud_generator_tb;

    reg clk;
    reg reset;
    wire baud_tick;

    // Instantiate the baud generator
    baud_generator #(
        .CLK_FREQ(50_000_000),
        .BAUD_RATE(115200)
    ) uut (
        .clk(clk),
        .reset(reset),
        .baud_tick(baud_tick)
    );

    // 50 MHz clock: 20 ns period
    always #10 clk = ~clk;

    // Simulation and waveform
    initial begin
        $dumpfile("baud_generator.vcd");
        $dumpvars(0, baud_generator_tb);

        clk = 1'b0;
        reset = 1'b1;

        #100;
        reset = 1'b0;

        #200000;
        $finish;
    end

    // Monitor baud ticks
    always @(posedge baud_tick) begin
        $display("Baud tick at time %0t ns", $time);
    end

endmodule
