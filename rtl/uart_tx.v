`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/02/2026 06:36:55 PM
// Design Name: 
// Module Name: uart_tx
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module uart_tx (
    input  wire       clk,
    input  wire       rst,
    input  wire       baud_tick,
    input  wire [7:0] ext_data_in,
    input  wire       en,
    output reg        tx
);

    // FSM states
    localparam IDLE  = 2'd0;
    localparam START = 2'd1;
    localparam DATA  = 2'd2;
    localparam STOP  = 2'd3;

    reg [1:0] state, next_state;


    // counters
    reg [3:0] bit_tick_cnt;
    reg [2:0] bit_cnt;
    reg [7:0] shift_reg;


    wire bit_tick_done = (bit_tick_cnt == 4'd15);
    wire byte_done     = (bit_cnt == 3'd7);


    // state register
    always @(posedge clk) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end


    // Combinational logic (state)
    always @(*) begin
        next_state = IDLE;

        case (state)
            IDLE:  if (en) next_state = START;

            START: if (baud_tick && bit_tick_done) next_state = DATA;

            DATA:  if (baud_tick && bit_tick_done && byte_done) next_state = STOP;

            STOP:  if (baud_tick && bit_tick_done) next_state = IDLE;

            default: next_state = IDLE;
        endcase
    end


    // Sequential logic (counters + shift register)
    always @(posedge clk) begin
        if (rst) begin
            bit_tick_cnt <= 0;
            bit_cnt      <= 0;
            shift_reg    <= 0;
        end
        else if (baud_tick) begin

            if (state == IDLE && en) begin
                bit_tick_cnt <= 0;
                bit_cnt      <= 0;
                shift_reg    <= ext_data_in;
            end
            else begin
                if (bit_tick_done) begin
                    bit_tick_cnt <= 0;

                    if (state == DATA) begin
                        bit_cnt   <= bit_cnt + 1;
                        shift_reg <= {shift_reg[6:0], 1'b0};
                    end
                end
                else begin
                    bit_tick_cnt <= bit_tick_cnt + 1;
                end
            end
        end
    end


    // registered output 
    always @(posedge clk) begin
        if (rst)
            tx <= 1'b1;
        else begin
            case (state)
                IDLE:  tx <= 1'b1;
                START: tx <= 1'b0;
                DATA:  tx <= shift_reg[7];
                STOP:  tx <= 1'b1;
                default: tx <= 1'b1;
            endcase
        end
    end

endmodule
