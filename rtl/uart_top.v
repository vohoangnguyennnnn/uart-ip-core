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
    input  wire        clk,
    input  wire        rst,

    // register interface
    input  wire [1:0]  address,
    input  wire [31:0] write_data,
    input  wire        we,
    input  wire        re,

    // uart pins
    output wire        tx,
    input  wire        rx,

    output reg  [7:0]  read_data
);


    localparam BAUD_DATA = 2'd0;
    localparam ENABLE    = 2'd1;
    localparam TX_DATA   = 2'd2;
    localparam RX_DATA   = 2'd3;


    // Registers
    reg [31:0] baud_division;
    reg        enable;
    reg [7:0]  tx_data;

    wire [7:0] rx_data;
    wire       baud_tick;


    // WRITE DATA
    always @(posedge clk) begin
        if (rst) begin
            baud_division <= 32'd0;
            enable        <= 1'b0;
            tx_data       <= 8'd0;
        end
        else if (we) begin
            case (address)
                BAUD_DATA: baud_division <= write_data;
                ENABLE:    enable        <= write_data[0];
                TX_DATA:   tx_data       <= write_data[7:0];
                default:   ; 
            endcase
        end
    end


    // READ DATA
    always @(posedge clk) begin
        if (rst)
            read_data <= 8'd0;
        else if (re) begin
            case (address)
                RX_DATA: read_data <= rx_data;
                default: read_data <= 8'd0; // default
            endcase
        end
    end


    // Baud generator
    uart_baud_gen baud_gen (
        .clk           (clk),
        .rst           (rst),
        .baud_division (baud_division),
        .en            (enable),
        .baud_tick     (baud_tick)
    );

    // Transmitter
    uart_tx tx_core (
        .clk         (clk),
        .rst         (rst),
        .baud_tick   (baud_tick),
        .ext_data_in (tx_data),
        .en          (enable),
        .tx          (tx)
    );

    // Receiver 
    uart_rx rx_core (
        .clk          (clk),
        .rst          (rst),
        .baud_tick    (baud_tick),
        .rx           (rx),
        .ext_data_out (rx_data)
    );

endmodule

