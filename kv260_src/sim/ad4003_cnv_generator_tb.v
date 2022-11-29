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


module ad4003_cnv_generator_tb;
    
    //CONV_GENERATOR
    //input
    reg clk;
    reg i_trig;
    reg i_scl;
    //input reg[32:0] i_TX_Data,
    //OUTPUT
    wire o_start_conv;
    wire o_end_conv;
    wire o_DV;
    wire o_cnv;
    wire o_word_sync_n;
    
    //DESERIALIZER
    // Inputs
	reg clk_100;
	reg clk_200;
	reg clk_77;
	reg word_sync_n;
	reg adc_start_conv;
	reg [1:0] mode;
	reg serial_data_a_p;
	reg serial_data_a_n;
	reg serial_data_b_p;
	reg serial_data_b_n;

	// Outputs
	wire serial_clock_p;
	wire serial_clock_n;
	wire serial_sdi_p;
	wire serial_sdi_n;
	wire [17:0] parallel_data_a;
	wire [17:0] parallel_data_b;
	wire serad4003_deserializerial_data_a_o;
    wire serial_data_b_o;
	wire serial_clock_o;
	wire serial_sdi_o;
	wire cnt_77_lsb_o;
	wire [5:0] cnt_clk_o;
	wire [7:0] mosi_1_o;
	wire cnt_done_o;
	wire adc_config_status;

	wire config_adc;
      

    // FPAG Clk gen
	always begin
      clk = 1'b1;
      #5 clk = 1'b0;
      #5;
   end  
   
   //clk deserializer
    //Timming and clocks
    always begin clk_100 = 1'b1; #5 clk_100 = 1'b0;; #5; end
    always begin clk_200 = 1'b1; #2.5 clk_200 = 1'b0; #2.5; end
    always begin clk_77 = 1'b1; #6.5 clk_77 = 1'b0; #6.5; end 
   
    integer i = 0;
    // SPI Master Clk gena
   always begin
      i_scl = 1'b0;
      #200;
      #200;
      for(i = 0; i<=17; i = i+1)begin
          #50 i_scl = 1'b1; 
          #50 i_scl = 1'b0;
      end
    end 
    
    

    ad4003_cov_generator #(.MAX_BYTE(1), 
        .CLK_FREQ_MHZ(200),
        .TQUIET1_DELAY_PULSES(38),
        .TEN_DELAY_PULSES(2),
        .TQUIET2_DELAY_PULSES(5)) uut1 (
        .clk(clk_200), // i
        .i_trig(i_trig), // i
        .i_scl(serial_clock_o), // i //scl from desirializer
        .o_start_conv(o_start_conv), //o
        .o_end_conv(o_end_conv), // o
        .o_DV(o_DV), // o
        .o_word_sync_n(o_word_sync_n), // o
        .o_cnv(o_cnv) // o
        );
    
    	// Instantiate the Unit Under Test (UUT)
	ad4003_deserializer uut2 (
		.clk_100(clk_100), 
		.clk_77(clk_77), 
		.word_sync_n(o_word_sync_n), 
		.adc_start_conv(o_start_conv), //o_stat_conv from cov_generator
		.mode(mode), 
		.serial_data_a_p(serial_data_a_p), 
		.serial_data_a_n(serial_data_a_n), 
		.serial_data_b_p(serial_data_b_p), 
		.serial_data_b_n(serial_data_b_n), 
		.serial_clock_p(serial_clock_p), 
		.serial_clock_n(serial_clock_n), 
		.serial_sdi_p(serial_sdi_p), 
		.serial_sdi_n(serial_sdi_n), 
		.parallel_data_a(parallel_data_a), 
		.parallel_data_b(parallel_data_b), 
		.adc_config_status(adc_config_status),
		.serial_data_a_o(serial_data_a_o),
		.serial_data_b_o(serial_data_b_o),
		.serial_clock_o(serial_clock_o), 
		.serial_sdi_o(serial_sdi_o),
		.cnt_77_lsb_o(cnt_77_lsb_o)
		//.cnt_clk_o(cnt_clk_o),
		//.mosi_1_o(mosi_1_o),
		//.cnt_done_o(cnt_done_o)
	);
        
    initial begin
		// Initialize Inputs
		i_trig = 1'b0;
		mode = 2'b1;
		
		//to make sure clk works
		clk_100 = 0;
		clk_200 = 0;
		clk_77 = 0;
		
		#10;
		i_trig = 1'b0;
		#1800;
		i_trig = 1'b1;
		#1000;
		i_trig = 1'b0;
		#2000;
		#200;
		i_trig = 1'b1;
		#100;
		i_trig = 1'b0;


	end	
	
	
		
endmodule