`timescale 1ns / 1ps

module uart_tx (
    input            clk,
    input            reset,
    input            tx_start,
    input      [7:0] tx_data,
    input            baud_tick,
    output reg       tx,
    output reg       tx_busy,
    output reg       tx_done,
    output reg [1:0] state
);

    localparam IDLE  = 2'b00;
    localparam START = 2'b01;
    localparam DATA  = 2'b10;
    localparam STOP  = 2'b11;

    reg [7:0] shift_register;
    reg [3:0] bit_count;

    always @(posedge clk) begin
        if (reset) begin
            state          <= IDLE;
            tx             <= 1'b1;
            tx_busy        <= 1'b0;
            tx_done        <= 1'b0;
            shift_register <= 8'b0;
            bit_count      <= 4'd0;
        end
        else begin
            tx_done <= 1'b0;

            case (state)

                IDLE: begin
                    tx      <= 1'b1;
                    tx_busy <= 1'b0;
                    if (tx_start) begin
                        shift_register <= tx_data;
                        bit_count      <= 4'd0;
                        tx             <= 1'b0;
                        tx_busy        <= 1'b1;
                        state          <= START;
                    end
                end

                START: begin
                    tx      <= 1'b0;
                    tx_busy <= 1'b1;
                    if (baud_tick) begin
                        tx             <= shift_register[0];
                        shift_register <= shift_register >> 1;
                        bit_count      <= 4'd1;
                        state          <= DATA;
                    end
                end

                DATA: begin
                    tx_busy <= 1'b1;
                    if (baud_tick) begin
                        if (bit_count < 4'd8) begin
                            tx             <= shift_register[0];
                            shift_register <= shift_register >> 1;
                            bit_count      <= bit_count + 1'b1;
                        end
                        else begin
                            tx    <= 1'b1;
                            state <= STOP;
                        end
                    end
                end

                STOP: begin
                    tx      <= 1'b1;
                    tx_busy <= 1'b1;
                    if (baud_tick) begin
                        tx_busy <= 1'b0;
                        tx_done <= 1'b1;
                        state   <= IDLE;
                    end
                end

                default: begin
                    state          <= IDLE;
                    tx             <= 1'b1;
                    tx_busy        <= 1'b0;
                    tx_done        <= 1'b0;
                    shift_register <= 8'b0;
                    bit_count      <= 4'd0;
                end

            endcase
        end
    end

endmodule