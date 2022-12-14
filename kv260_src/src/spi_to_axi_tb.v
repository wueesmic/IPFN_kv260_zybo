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


module spi_to_axi_tb;
    
    //input
    reg  clk;
    reg  rst_L;
    reg  m_axis_tready;
    reg  i_DV; //data valid
    reg  [32-1:0] i_data; //CONV
    
    wire o_fifo_en; //invokes next byte from fifo
    //output
    wire m_axis_tvalid;
    wire [32-1:0] m_axis_tdata;
    wire [1-1:0]   m_axis_tkeep;
    wire m_axis_tlast;
    wire [32-1:0] o_counter;

// FPAG Clk gen
	always begin
      clk = 1'b1;
      #5 clk = 1'b0;
      #5;
   end  
   //i_DV generation
   always begin
        #40;
        i_DV = 1'b0;
        
		#80;
		i_data <= i_data+1;
		i_DV = 1'b1;
   end 

// SPI Master Clk gena
//	always begin
//      i_SPI_Clk = 1'b1;
//      #50 i_SPI_Clk = 1'b0;
//      #50;
//   end  

    spi_to_axi #(.DATA_WIDTH(32), 
                .CNT_WIDTH(5),
                .CNT_MAX(511),
                .KEEP_WIDTH(1)) uut (
        .clk(clk), // i
        .rst_L(rst_L), // i
        .m_axis_tready(m_axis_tready), // i
        .m_axis_tvalid(m_axis_tvalid), //o
        .m_axis_tdata(m_axis_tdata), // o
        .m_axis_tkeep(m_axis_tkeep), // o
        .m_axis_tlast(m_axis_tlast), // o
        .i_DV(i_DV), // o
        .i_data(i_data), // o
        .o_fifo_en(o_fifo_en), // o
        .o_counter(o_counter) // o
        );
    
    initial begin
		// Initialize Inputs
		rst_L = 1'b1;
		i_data = 32'h555;
		#10;
		rst_L = 1'b0;
		#10;
		rst_L = 1'b1;
		m_axis_tready = 1'b0;
		#10;
		m_axis_tready = 1'b1;
		i_data = 32'h444;
		#100;
		i_data = 32'h333;
//		#10;
//		i_DV = 1'b1;
//		#10;
//		i_DV = 1'b0;
//		#40;
//		i_DV = 1'b1;
//		#10;
//		i_DV = 1'b0;
//		#40;
//		i_DV = 1'b1;
//		#10;
//		i_DV = 1'b0;
//		#40;
//		i_DV = 1'b1;
//		#10;
//		i_DV = 1'b0;
//		#40;
//		i_DV = 1'b1;
//		#10;
//		i_DV = 1'b0;

	end		
endmodule