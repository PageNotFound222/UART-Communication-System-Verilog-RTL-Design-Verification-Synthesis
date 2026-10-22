module uart_top #(
    parameter CLK_FREQ = 50_000_000,
    parameter BAUD_RATE = 115200
)(
    input clk,
    input reset,
    input tx_start,
    input [7:0] tx_data,
    output tx,
    output tx_busy,
    output tx_done
);

    wire baud_tick;

    baud_generator #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) baud_gen (
        .clk(clk),
        .reset(reset),
        .baud_tick(baud_tick)
    );

    uart_tx transmitter (
        .clk(clk),
        .reset(reset),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .baud_tick(baud_tick),
        .tx(tx),
        .tx_busy(tx_busy),
        .tx_done(tx_done),
        .state()
    );

endmodule
