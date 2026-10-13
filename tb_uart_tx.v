
`timescale 1ns/1ps

module tb_uart;

    
    reg clk;
    reg reset;
    reg tx_start;
    reg [7:0] tx_data;
    reg baud_tick;

    
    wire tx;
    wire tx_busy;
    wire tx_done;
    wire [1:0] state;

    
    integer baud_counter;

    
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

    
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    
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

    
    initial begin
        $dumpfile("uart_tx.vcd");
        $dumpvars(0, tb_uart);

        reset = 1'b1;
        tx_start = 1'b0;
        tx_data = 8'hA5;
        baud_tick = 1'b0;
        baud_counter = 0;

        
        repeat (4) @(negedge clk);
        reset = 1'b0;

        
        @(negedge clk);
        tx_start = 1'b1;

        @(negedge clk);
        tx_start = 1'b0;

        
        wait (tx_done == 1'b1);
        $display("Transmission completed at time %0t", $time);

    
        repeat (3) @(negedge clk);

        $finish;
    end

    
    initial begin
        $monitor("Time=%0t | State=%b | TX=%b | Busy=%b | Done=%b | Data=%h",
                 $time, state, tx, tx_busy, tx_done, tx_data);
    end


    initial begin
        #5000;
        $display("ERROR: Simulation timed out; check UART state and timing logic.");
        $finish;
    end

endmodule
