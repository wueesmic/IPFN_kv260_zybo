`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:52:59 08/16/2021
// Design Name:   ad4003_deserializer
// Module Name:   /home/agtorres/repos/atca-iop-stream/sim/ADC_testBench.v
// Project Name:  atca-iop-stream
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: ad4003_deserializer
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module ad4003_deserializer_tb;

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
  
	
	
	
	//other
	reg config_adc_i; //using the dma enable register

	// Instantiate the Unit Under Test (UUT)
	ad4003_deserializer uut (
		.clk_100(clk_100), 
		.clk_77(clk_77), 
		.word_sync_n(word_sync_n), 
		.adc_start_conv(adc_start_conv), 
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
		clk_100 = 0;
		clk_200 = 0;
		clk_77 = 0;
		word_sync_n = 0;
		adc_start_conv = 0;
		mode = 0;
		serial_data_a_p = 0;
		serial_data_a_n = 1;
		serial_data_b_p = 0;
		serial_data_b_n = 1;
		
		config_adc_i =0;

		// Wait 100 ns for global reset to finish
		#1200;
		config_adc_i <= 1'b1;
        
		// Add stimulus here

	end
	
	//Timming and clocks
	always clk_100 = #5 ~clk_100;
	always clk_200 = #2.5 ~clk_200;
	always clk_77 = #6.5 ~clk_77;
	
	reg [5:0] cnt_100_r = 6'd0;

	 always @ (posedge clk_100)
		begin
			cnt_100_r <= cnt_100_r + 1'b1;
			case(cnt_100_r)
            6'd00:  begin
					adc_start_conv <= 1'b1;
				end
            6'd19:  begin
					adc_start_conv <= 1'b0; // tquiet1 min 190 ns for turbo mode
					//word_sync_n <= 1'b0;
				end
				6'd20:  word_sync_n <= 1'b0; 
				6'd47:  word_sync_n <= 1'b1;
            6'd49:  cnt_100_r <= 0;
            default: ;

        endcase
    end
	 
	//ADC mode and configuration
	
  reg config_adc_dly; //https://www.chipverify.com/verilog/verilog-positive-edge-detector

  /*ADC Config as pulse from Edge Detection of DMA_enable */
  always @ (posedge adc_start_conv) begin
    config_adc_dly <= config_adc_i;
  end
  assign config_adc = config_adc_i & ~config_adc_dly;

  //2MHz ADC Mode state parse
  always @ (posedge adc_start_conv) begin
    if (config_adc == 1'b1) begin    //Configure ADC
      mode 	<= #1 2'b10;
    end
    else if (mode == 2'b10) begin //Config done, read register
      mode 	<= #1 2'b11;
    end
    else if (mode == 2'b11) begin //Register read, acquire
      mode 	<= #1 2'b01;
    end
  end
      
endmodule