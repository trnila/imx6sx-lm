`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/25/2025 08:38:39 PM
// Design Name: 
// Module Name: blink
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

module blink(
    input wire clk,          // 100 MHz clock from Arty Z7
    output reg led       // LED output
);

    // Divide 100 MHz clock down to ~1 Hz
    localparam integer DIV = 100_000_000 / 2;
    integer counter = 0;

    always @(posedge clk) begin
        if (counter >= DIV) begin
            counter <= 0;
            led <= ~led;
        end else begin
            counter <= counter + 1;
        end
    end

endmodule