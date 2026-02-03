`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/02/2026 06:36:11 PM
// Design Name: 
// Module Name: uart_top
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


module uart_top (
    input wire clk,
    input wire rst,
    input wire [1:0] address,
    input wire [31:0] write_data,
    input wire we,
    output wire tx,
    input wire rx,
    input wire re,
    output reg [7:0] read_data
);
    
    // Register Interface

    localparam BAUD_DATA = 0;
    localparam ENABLE = 1;
    localparam TX_DATA = 2;
    localparam RX_DATA = 3;

    reg [31:0] baud_division;
    reg enable;
    reg [7:0] data_out;
    wire [7:0] data_in;

    always @(*) begin
        if (rst) begin
            baud_division <= 0;
            enable <= 0;
            data_out <= 0;
        end
        else begin
            casex (address)
                BAUD_DATA: begin
                    if (we) begin
                        baud_division = write_data;
                    end
                end
                ENABLE: begin
                    if (we) begin
                        enable = write_data[0];
                    end
                end
                TX_DATA: begin
                    if (we) begin
                        data_out = write_data[7:0];
                    end
                end
                RX_DATA: begin
                    if (re) begin
                        read_data = data_in;
                    end
                end
                // default: 
            endcase
        end
    end

    // Baud Rate Generator

    wire baud_tick;

    uart_baud_gen baud_gen (
        .clk (clk),
        .rst (rst),
        .baud_division (baud_division),
        .en (enable),
        .baud_tick (baud_tick)
    );

    // Transmitter

    uart_tx tx_core (
        .clk (clk),
        .rst (rst),
        .baud_tick (baud_tick),
        .ext_data_in (data_out),
        .en (enable),
        .tx (tx)
    );

    // Receiver

    uart_rx rx_core (
        .clk (clk),
        .rst (rst),
        .baud_tick (baud_tick),
        .rx (rx),
        .ext_data_out (data_in)
    );
    
endmodule
