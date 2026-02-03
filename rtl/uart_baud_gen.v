`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/02/2026 06:36:55 PM
// Design Name: 
// Module Name: uart_baud_gen
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


module uart_baud_gen (
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] baud_division,
    input  wire        en,
    output reg         baud_tick
);

    reg [31:0] baud_count;
    reg        en_d;

    // edge detect
    always @(posedge clk) begin
        if (rst)
            en_d <= 0;
        else
            en_d <= en;
    end

    wire en_q = en & ~en_d;

    // baud counter
    always @(posedge clk) begin
        if (rst) begin
            baud_count <= 0;
            baud_tick  <= 0;
        end
        else begin
            baud_tick <= 0;   // default 

            if (!en || baud_division == 0) begin
                baud_count <= 0;
            end
            else if (en_q) begin
                baud_count <= 0;
            end
            else if (baud_count == baud_division - 1) begin
                baud_count <= 0;
                baud_tick  <= 1;
            end
            else begin
                baud_count <= baud_count + 1;
            end
        end
    end

endmodule
