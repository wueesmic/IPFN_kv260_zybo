`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/27/2022 10:53:08 AM
// Design Name: 
// Module Name: scl_delay
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


module scl_delay #(
    // Delay in number of pulses
    parameter DELAY_PULSES = 1)
    (
        input  clk, //at least 5 times faster than scl
        input  scl,
        input  rst_L,
        output scl_del
    );
    
    reg[DELAY_PULSES:0] buffer = 32'b0000;
    
    assign scl_del = buffer[0:0];
     
    //shift register
    always @(posedge clk) begin
        buffer[DELAY_PULSES-1:DELAY_PULSES-1] <= scl;
        buffer[DELAY_PULSES-1:0] = buffer[DELAY_PULSES:1];
    end
    
    
    
endmodule
    