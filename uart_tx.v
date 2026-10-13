module uart_tx(clk,reset,tx_start,tx_data,baud_tick,tx,tx_busy,tx_done)
input clk,reset,tx_start,baud_tick;
output reg tx,tx_busy,tx_done;
output reg[1:0] state;
reg [1:0] next_state;
input [7:0]tx_data;
reg [7:0] shift_register;
reg [2:0] bit_count;
localparam  IDLE = 2'b00;
localparam  START= 2'b01;
localparam  DATA = 2'b10;
localparam  STOP = 2'b11;
always@(posedge clk)
    begin
            if(reset == 1)
                state<=IDLE;
            else
                state<=next_state;
    end
always@(*)
    begin
            case(state)
                        IDLE:
                             begin
                                    if(tx_start)
                                        next_state = START;
                                    else
                                        next_state = IDLE;
                             end
                        START:
                            begin
                                    if(baud_tick)
                                        next_state = DATA;
                                    else
                                        next_state = START;
                            end
                        DATA:
                            begin
                                    if(baud_tick && bit_count == 3'b111)
                                        next_state = STOP;
                                    else
                                        next_state = DATA;  
                            end
                        STOP:
                            begin
                                    if(baud_tick)
                                        next_state = IDLE;
                                    else
                                        next_state = STOP; 
                            end
            endcase
    end
always @(posedge clk) begin
    if (reset) begin
        tx             <= 1'b1;
        tx_busy        <= 1'b0;
        tx_done        <= 1'b0;
        shift_register <= 8'b0;
        bit_count      <= 3'b000;
    end
    else
    begin
        tx_done <= 1'b0;
        case (state)
            IDLE: begin
                tx      <= 1'b1;
                tx_busy <= 1'b0;
                if (tx_start) begin
                    shift_register <= tx_data;
                    bit_count      <= 3'b000;
                    tx_busy        <= 1'b1;
                end
            end
            START: 
            begin
                tx      <= 1'b0;
                tx_busy <= 1'b1;
                if (baud_tick) begin
                    tx             <= shift_register[0];
                    shift_register <= shift_register >> 1;
                    bit_count      <= 3'b000;
                end
            end
            DATA: 
            begin
                tx      <= tx;
                tx_busy <= 1'b1;

                if (baud_tick) begin
                    if (bit_count == 3'b111) begin
                        tx <= 1'b1;
                    end
                    else begin
                        tx             <= shift_register[0];
                        shift_register <= shift_register >> 1;
                        bit_count      <= bit_count + 1'b1;
                    end
                end
            end
            STOP: 
            begin
                tx      <= 1'b1;
                tx_busy <= 1'b1;

                if (baud_tick) begin
                    tx_busy <= 1'b0;
                    tx_done <= 1'b1;
                end
            end
            default: 
            begin
                tx             <= 1'b1;
                tx_busy        <= 1'b0;
                shift_register <= 8'b0;
                bit_count      <= 3'b000;
            end
        endcase
    end
end
endmodule