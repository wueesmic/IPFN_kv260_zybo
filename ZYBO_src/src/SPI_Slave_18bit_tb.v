`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/11/2022 01:20:06 PM
// Design Name: 
// Module Name: SPI_Slave_tb
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


module SPI_Slave_18bit_tb;
   
   
// Inputs
   reg            i_Rst_L;    // FPGA Reset, active low
   reg            i_Clk;      // FPGA Clock
   reg            i_TX_DV;    // Data Valid pulse to register i_TX_Byte
   reg  [17:0]     i_TX_Byte;  // Byte to serialize to MISO.

   // SPI Interface
   reg      i_SPI_Clk;
   reg      i_SPI_MOSI;
   reg      i_SPI_CS_n;        // active low

// Outputs
    wire  o_SPI_MISO;
    wire  o_RX_DV;    // Data Valid pulse (1 clock cycle)
    wire [17:0] o_RX_Byte;  // Byte received on MOSI

// FPAG Clk gen
	always begin
      i_Clk = 1'b1;
      #5 i_Clk = 1'b0;
      #5;
   end  

// SPI Master Clk gena
    integer i = 0;
    // SPI Master Clk gena
	always begin
      i_SPI_Clk = 1'b0;
      #200;
      for(i = 0; i<=17; i = i+1)begin
          #50 i_SPI_Clk = 1'b1; 
          #50 i_SPI_Clk = 1'b0;
      end
   end  

    SPI_Slave_18bit #(.BIT_PER_TRNASFER(18)) uut (
        .i_Rst_L(i_Rst_L), // i
        .i_Clk(i_Clk), // i
        .i_TX_DV(i_TX_DV), // i
        .i_TX_Byte(i_TX_Byte), // [7:0] i
        .i_SPI_Clk(i_SPI_Clk), // i
        .i_SPI_MOSI(i_SPI_MOSI), // i
        .i_SPI_CS_n(i_SPI_CS_n), // i

        .o_RX_DV(o_RX_DV), // o
        .o_RX_Byte(o_RX_Byte), // o
        .o_SPI_MISO(o_SPI_MISO) // o
        );
    
    initial begin
		// Initialize Inputs
		i_SPI_MOSI = 1'b1;
		i_Rst_L = 1'b0;
		i_SPI_CS_n = 1'b1;
		i_TX_Byte  = 18'h3aaaa;
		i_TX_DV = 1'b0;
		#5;
		i_Rst_L = 1'b1;
		#20;
		i_TX_DV = 1'b1; // Load i_TX_Byte data 
		#50;
		//@(negedge i_SPI_Clk);
		#5;
		i_SPI_CS_n = 1'b0;
		#2000;
		i_Rst_L = 1'b1;
		//i_SPI_CS_n = 1'b1; //cs after first byte
		#10;
		i_TX_DV = 1'b0;
		i_SPI_CS_n = 1'b0;
		#2000;
		i_SPI_CS_n = 1'b1;
		#10;
		i_SPI_CS_n = 1'b0;
		#2000;
		//i_SPI_CS_n = 1'b1;
	end		
endmodule
