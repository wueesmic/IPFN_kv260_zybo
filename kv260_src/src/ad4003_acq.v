`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 		IPFN-IST
// Engineer: 		A. Torres
//
// Create Date:    11:50:58 08/04/2021
// Design Name: 	 atca-iop-stream
// Module Name:    ad4003_acq
// Project Name:	 ATCA IOP
// Target Devices: Virtex-6
// Tool versions:  ISE14.7
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

module ad4003_acq #(
	parameter ADC_DATA_WIDTH = 18,
	parameter ADC_CHANNELS = 2,
	parameter ADC_MODULES = 1
	)
	(
	input clk_100,
	input clk_200,
	input clk_77,
	input word_sync_n,
	input adc_start_conv,
	input reset,
	input [1:0] mode,
	input  [(ADC_CHANNELS  - 1):0] adc_data_p,
	input  [(ADC_CHANNELS  - 1):0] adc_data_n,
	output  [(ADC_CHANNELS  - 1):0] adc_clk_p,
	output  [(ADC_CHANNELS  - 1):0] adc_clk_n,
	output [ADC_DATA_WIDTH*ADC_CHANNELS -1:0] adc_array_data,
	output [(ADC_MODULES  - 1):0] adc_config_status,
	//debug
	output  [(ADC_CHANNELS  - 1):0] serial_datas,
	output  [(ADC_MODULES  - 1):0] serial_clocks,
	output  [(ADC_MODULES  - 1):0] serial_sdis,
	output  [(ADC_MODULES  - 1):0] cnt_77_lsb
	);

	//Input delay for data
	//Values taken from ATCA IOP PROCESSOR INESC Project
	/*
	localparam integer IDELAY_IVAL_ARRAY [47:0] = {19, 16, 31, 23, 31, 31, 11, 12,  // positive value to delay data path
	                                         22, 31, 31, 11, 13, 26, 20, 19,  // negative value to delay clock path
	                                         17, 21, 11, 12, 12, 31, 19, 11,  // -32/32 to bypass the corresponding IDELAY block
	                                         13, 27, 11, 31, 11, 20, 18, 16,
	                                         12, 12, 11, 23, 19, 15, 29, 13,
	                                         11, 11, 15, 13, 12, 15, 11, 15};
	*/
	localparam integer IDELAY_IVAL_ARRAY [47:0] = {0, 0, 12, 12, 12, 12, 11, 12,  // positive value to delay data path
	                                         22, 31, 31, 11, 13, 26, 20, 19,  // negative value to delay clock path
	                                         17, 21, 11, 12, 12, 31, 19, 11,  // -32/32 to bypass the corresponding IDELAY block
	                                         13, 27, 11, 31, 11, 20, 18, 16,
	                                         12, 12, 11, 23, 19, 15, 29, 13,
	                                         11, 11, 15, 13, 12, 15, 11, 15};
	
	/*
	(* IODELAY_GROUP = "iodelay_group_adc" *) // Specifies group name for associated IODELAYs and IDELAYCTRL
	  IDELAYCTRL IDELAYCTRL_inst (
	     .RDY(),       // 1-bit Ready output
	     .REFCLK(clk_200), // Reference clock input (must be 200MHz)
	     .RST(reset)
	  );
	*/
	genvar k;
	generate
		for (k = 0; k < ADC_MODULES; k = k + 1)
		begin: ADCS
			ad4003_deserializer # (
				.IDELAY_VAL_A(IDELAY_IVAL_ARRAY[(2*k)]),
				.IDELAY_VAL_B(IDELAY_IVAL_ARRAY[(2*k+1)])
			)
			AD4003_DESER (
				.clk_100(clk_100),
				.clk_77(clk_77),
				.word_sync_n(word_sync_n),
				.adc_start_conv(adc_start_conv),
				.mode(mode),
				.serial_data_a_p(adc_data_p[(2*k)]),
				.serial_data_a_n(adc_data_n[(2*k)]),
				.serial_data_b_p(adc_data_p[(2*k+1)]),
				.serial_data_b_n(adc_data_n[(2*k+1)]),
				.serial_clock_p(adc_clk_p[(2*k)]),
				.serial_clock_n(adc_clk_n[(2*k)]),
				.serial_sdi_p(adc_clk_p[(2*k+1)]),
				.serial_sdi_n(adc_clk_n[(2*k+1)]),
				.parallel_data_a(adc_array_data[(ADC_DATA_WIDTH * (2 * k + 1) - 1):(ADC_DATA_WIDTH * 2 * k) ]),
				.parallel_data_b(adc_array_data[(ADC_DATA_WIDTH * (2 * k + 1 + 1) - 1):(ADC_DATA_WIDTH * (2 * k + 1)) ]),
				.adc_config_status(adc_config_status[k]),
				//debug
				.serial_data_a_o(serial_datas[(2*k)]),
				.serial_data_b_o(serial_datas[(2*k+1)]),
				.serial_clock_o(serial_clocks[k]),
				.serial_sdi_o(serial_sdis[k]),
				.cnt_77_lsb_o(cnt_77_lsb[k])
			);
		end
	endgenerate

endmodule