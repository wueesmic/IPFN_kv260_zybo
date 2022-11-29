`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 		IPFN-IST
// Engineer: 		A. Torres
//
// Create Date:    16:30:41 08/04/2021
// Design Name: 	 atca-iop-stream
// Module Name:    ad4003_deserializer
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
module ad4003_deserializer#(
  parameter	ADC_DATA_WIDTH = 18,
	parameter	IDELAY_VAL_A = 10,
  parameter	IDELAY_VAL_B = 10)
  (
    input clk_100,
    input clk_77,
    input word_sync_n,
    input adc_start_conv,
    input [1:0] mode,
    input serial_data_a_p,
    input serial_data_a_n,
    input serial_data_b_p,
    input serial_data_b_n,
    output serial_clock_p,
    output serial_clock_n,
    output serial_sdi_p,
    output serial_sdi_n,
    output [ADC_DATA_WIDTH-1:0] parallel_data_a,
    output [ADC_DATA_WIDTH-1:0] parallel_data_b,
    output adc_config_status,
    //debug
    output serial_data_a_o,
    output serial_data_b_o,
    output serial_clock_o,
    output serial_sdi_o,
	 output cnt_77_lsb_o
	 //SYM
	 //output [5:0] cnt_clk_o,
	 //output [7:0] mosi_1_o,
	 //output cnt_done_o
  );

  //IO BUFS
  (* KEEP="TRUE" *) wire serial_data_a_i, serial_data_b_i, serial_data_a_ibuf, serial_data_b_ibuf, serial_clock_i, serial_sdi_i;
  reg serial_sdi_r;
  assign serial_sdi_i = serial_sdi_r;
  OBUFDS #(
        .IOSTANDARD("DEFAULT")     // Specify the input I/O standard
     ) BUF_adc_clk (
        .I(serial_clock_i),  // Buffer input
        .O(serial_clock_p),  // Diff_p buffer output
        .OB(serial_clock_n) // Diff_n buffer output
     );
   OBUFDS #(
         .IOSTANDARD("DEFAULT")     // Specify the input I/O standard
      ) BUF_adc_sdi (
         .I(serial_sdi_i),  // Buffer input
         .O(serial_sdi_p),  // Diff_p buffer output
         .OB(serial_sdi_n) // Diff_n buffer output
      );

  IBUFDS #(
    //.DIFF_TERM("TRUE"),       // Differential Termination //MICHI UNCOMMENTED
    //.IBUF_LOW_PWR("TRUE"),     // Low power="TRUE", Highest performance="FALSE"  //MICHI UNCOMMENTED
    //.IOSTANDARD("LVDS_25")     // Specify the input I/O standard
    //.IOSTANDARD("DIFF_HSTL_I_18")     // Specify the input I/O standard //MICHIII
 ) IBUFDS_adc_data_a (
    .O(serial_data_a_ibuf),  // Buffer output adc_data_i
    .I(serial_data_a_p),  // Diff_p buffer input (connect directly to top-level port)
    .IB(serial_data_a_n) // Diff_n buffer input (connect directly to top-level port)
 );

 IBUFDS #(
   //.DIFF_TERM("TRUE"),       // Differential Termination //MICHI UNCOMMENTED
   //.IBUF_LOW_PWR("TRUE"),     // Low power="TRUE", Highest performance="FALSE"   //MICHI UNCOMMENTED
   //.IOSTANDARD("LVDS_25")     // Specify the input I/O standard
   //.IOSTANDARD("DIFF_HSTL_I_18")     // Specify the input I/O standard //MICHIII
) IBUFDS_adc_data_b (
   .O(serial_data_b_ibuf),  // Buffer output adc_data_i
   .I(serial_data_b_p),  // Diff_p buffer input (connect directly to top-level port)
   .IB(serial_data_b_n) // Diff_n buffer input (connect directly to top-level port)
);


//Input Delay for the data
/*
 (* IODELAY_GROUP = "iodelay_group_adc" *) // Specifies group name for associated IODELAYs and IDELAYCTRL
 IODELAYE1 #(
    .CINVCTRL_SEL("FALSE"),          // Enable dynamic clock inversion ("TRUE"/"FALSE")
    .DELAY_SRC("I"),                 // Delay input ("I", "CLKIN", "DATAIN", "IO", "O")
    .HIGH_PERFORMANCE_MODE("FALSE"), // Reduced jitter ("TRUE"), Reduced power ("FALSE")
    .IDELAY_TYPE("FIXED"),         // "DEFAULT", "FIXED", "VARIABLE", or "VAR_LOADABLE"
    .IDELAY_VALUE(IDELAY_VAL_A),                // Input delay tap setting (0-32) -- 1/(64f) @ tap (200MHz => 78ps/tap)
    .ODELAY_TYPE("FIXED"),           // "FIXED", "VARIABLE", or "VAR_LOADABLE"
    .ODELAY_VALUE(0),                // Output delay tap setting (0-32)
    .REFCLK_FREQUENCY(200.0),        // IDELAYCTRL clock input frequency in MHz
    .SIGNAL_PATTERN("DATA")          // "DATA" or "CLOCK" input signal
 )
 IODELAYE1_a_inst (
    .CNTVALUEOUT(), // 5-bit output - Counter value for monitoring purpose
    .DATAOUT(serial_data_a_i),         // 1-bit output - Delayed data output
    .C(1'b0),                     // 1-bit input - Clock input
    .CE(1'b0),                   // 1-bit input - Active high enable increment/decrement function
    .CINVCTRL(),       // 1-bit input - Dynamically inverts the Clock (C) polarity
    .CLKIN(1'b0),             // 1-bit input - Clock Access into the IODELAY
    .CNTVALUEIN(5'h0),   // 5-bit input - Counter value for loadable counter application
    .DATAIN(1'b0),           // 1-bit input - Internal delay data
    .IDATAIN(serial_data_a_ibuf),         // 1-bit input - Delay data input
    .INC(1'b0),                 // 1-bit input - Increment / Decrement tap delay
    .ODATAIN(1'b0),         // 1-bit input - Data input for the output datapath from the device
    .RST(1'b0),                 // 1-bit input - Active high, synchronous reset, resets delay chain to IDELAY_VALUE/
                               // ODELAY_VALUE tap. If no value is specified, the default is 0.
    .T(1'b1)                      // 1-bit input - 3-state input control. Tie high for input-only
 );
 
 
 (* IODELAY_GROUP = "iodelay_group_adc" *) // Specifies group name for associated IODELAYs and IDELAYCTRL
 IODELAYE1 #(
    .CINVCTRL_SEL("FALSE"),          // Enable dynamic clock inversion ("TRUE"/"FALSE")
    .DELAY_SRC("I"),                 // Delay input ("I", "CLKIN", "DATAIN", "IO", "O")
    .HIGH_PERFORMANCE_MODE("FALSE"), // Reduced jitter ("TRUE"), Reduced power ("FALSE")
    .IDELAY_TYPE("FIXED"),         // "DEFAULT", "FIXED", "VARIABLE", or "VAR_LOADABLE"
    .IDELAY_VALUE(IDELAY_VAL_B),                // Input delay tap setting (0-32) -- 1/(64f) @ tap (200MHz => 78ps/tap)
    .ODELAY_TYPE("FIXED"),           // "FIXED", "VARIABLE", or "VAR_LOADABLE"
    .ODELAY_VALUE(0),                // Output delay tap setting (0-32)
    .REFCLK_FREQUENCY(200.0),        // IDELAYCTRL clock input frequency in MHz
    .SIGNAL_PATTERN("DATA")          // "DATA" or "CLOCK" input signal
 )
 IODELAYE1_b_inst (
    .CNTVALUEOUT(), // 5-bit output - Counter value for monitoring purpose
    .DATAOUT(serial_data_b_i),         // 1-bit output - Delayed data output
    .C(1'b0),                     // 1-bit input - Clock input
    .CE(1'b0),                   // 1-bit input - Active high enable increment/decrement function
    .CINVCTRL(),       // 1-bit input - Dynamically inverts the Clock (C) polarity
    .CLKIN(1'b0),             // 1-bit input - Clock Access into the IODELAY
    .CNTVALUEIN(5'h0),   // 5-bit input - Counter value for loadable counter application
    .DATAIN(1'b0),           // 1-bit input - Internal delay data
    .IDATAIN(serial_data_b_ibuf),         // 1-bit input - Delay data input
    .INC(1'b0),                 // 1-bit input - Increment / Decrement tap delay
    .ODATAIN(1'b0),         // 1-bit input - Data input for the output datapath from the device
    .RST(1'b0),                 // 1-bit input - Active high, synchronous reset, resets delay chain to IDELAY_VALUE/
                               // ODELAY_VALUE tap. If no value is specified, the default is 0.
    .T(1'b1)                      // 1-bit input - 3-state input control. Tie high for input-only
 );
 */
 assign serial_data_a_i = serial_data_a_ibuf;
 assign serial_data_b_i = serial_data_b_ibuf;
 
 //debug signals
 assign serial_clock_o =  serial_clock_i ;
 assign serial_data_a_o =  serial_data_a_i;
 assign serial_data_b_o =  serial_data_b_i; //buf;
 assign serial_sdi_o =  serial_sdi_i;
 assign cnt_77_lsb_o = cnt_clk[0];
 //SYM SIGNALS
 //assign cnt_clk_o = cnt_clk;
 //assign mosi_1_o = mosi_1;
 //assign cnt_done_o=cnt_done;

 /* ADC configure / acquire engine */
 //DEFINITIONS
 wire [7:0] read_reg_cmd =  8'b01010100;
 wire [7:0]write_reg_cmd =  8'b00010100;
 wire [7:0]write_reg_map =  8'b00000011; //registermap for turbo mode and ~OVclamp
 reg [4:0]    adc_reg_a =  8'b00000;
 reg [4:0]    adc_reg_b =  8'b00000;
 wire [4:0]   adc_reg_ok =  8'b00011;
 reg [7:0]       mosi_1 =  8'b11111111;
 reg [7:0]       mosi_2 =  8'b11111111;
 reg [ADC_DATA_WIDTH-1:0] miso_a;
 reg [ADC_DATA_WIDTH-1:0] miso_b;
 
 //MODE SWITCH
 //always @ (negedge adc_start_conv or posedge adc_start_conv) begin
 always @ (posedge adc_start_conv) begin
	case(mode)
		2'd0: begin		//IDLE
			mosi_1 <= 8'b11111111;
			mosi_2 <= 8'b11111111;
		end
		2'd1: begin		//ACQUIRE
		 mosi_1 <= 8'b11111111;
		 mosi_2 <= 8'b11111111;
		end
		2'd2: begin		//REGISTER WRITE
		 mosi_1 <= write_reg_cmd;
		 mosi_2 <= write_reg_map;
		end
		2'd3: begin		//REGISTER READ
		 mosi_1 <= read_reg_cmd;
		 mosi_2 <= 8'b11111111;
		end
	 endcase
 end

 // ADC status
 assign adc_config_status = (adc_reg_a == adc_reg_ok) && (adc_reg_b == adc_reg_ok);

 reg [5:0] cnt_clk = 6'd0;
 reg cnt_done=1'b1;
 reg sdi_done=1'b1;
 reg count_en = 1'b0;
 

 //First pass word_sync_n to the 77MHz domain
 reg sync_aux_reg = 1'b1;
 wire word_sync_77_n;
 always @ (negedge clk_77) begin
   sync_aux_reg <= word_sync_n;
 end
 assign word_sync_77_n = sync_aux_reg;

 //Clockout SCLK >10ns after CNVSRT goes low and while count (to 18) is not done
 assign serial_clock_i =  (clk_77 & !cnt_done);


reg [0:0] word_sync_flag = 1;

 always @ (posedge clk_77) begin      //Sync with 77MHz
//	if (word_sync_77_n) begin
//		if (adc_start_conv) begin
//			sdi_done<=1'b0;
//			//cnt_clk <= 6'b0;
//		end
//		cnt_clk <= 6'b0;
//		//cnt_clk <= 6'd19; //MICHI
//		//cnt_done<=1'b0;
//	end


    //check for negedge word_sync
    if(!word_sync_n && word_sync_flag)begin //MICHI make sure to stop any transmission before starting a new one
        word_sync_flag <= 1'b0;
        cnt_done <= 1'b1;
        cnt_clk <= 6'd21;
    end else if(word_sync_n && !word_sync_flag)begin
        word_sync_flag <= 1'b1;
    end
    if(adc_start_conv && cnt_done) begin
        cnt_done <= 1'b0;
        cnt_clk <= 6'd0;
    end else if(!adc_start_conv && cnt_done) begin
        cnt_clk <= 6'd21;
    end
    else begin   
		cnt_clk <= cnt_clk + 1'b1;		//If not done counting counts
		case (cnt_clk)
			6'd0:	 cnt_done<=1'b0;
			6'd17: begin         //MICHI changed 6'd18: to 17
				cnt_done<= 1'b1;
				sdi_done<=1'b1;
			end
			//6'd20: cnt_clk <= 6'd0;
		endcase
	end
  end //always


  //77MHz neg edge cycle for SCK
  always @ (negedge clk_77 ) begin//Sync with 77MHz //Original
  //always @ (posedge clk_77 ) begin//Sync with 77MHz //MICHI posedge because ZYBO is programed to read at posedge and write at negedge 
    case (cnt_clk)
      6'd0: begin //should catch negedge of adc_start_conv
        serial_sdi_r <= (adc_start_conv | sdi_done) ? 1'b1 : mosi_1[7];
        end
      6'd1: begin
       //miso_a[17] <= serial_data_a_i;
       //miso_b[17] <= serial_data_b_i;
       serial_sdi_r <= mosi_1[6];
       if (mode == 2'd3) begin
         adc_reg_a[4:0] <= 8'b00000;
         adc_reg_b[4:0] <= 8'b00000;
       end
      end
      6'd2: begin
       //Reset
		  miso_a <= 18'd0;
        miso_b <= 18'd0;
       serial_sdi_r <= mosi_1[5];
      end
      6'd3: begin
       miso_a[17] <= serial_data_a_i;
       miso_b[17] <= serial_data_b_i;
       serial_sdi_r <= mosi_1[4];
      end
      6'd4: begin
       miso_a[16] <= serial_data_a_i;
       miso_b[16] <= serial_data_b_i;
       serial_sdi_r <= mosi_1[3];
      end
      6'd5: begin
       miso_a[15] <= serial_data_a_i;
       miso_b[15] <= serial_data_b_i;
       serial_sdi_r <= mosi_1[2];
      end
      6'd6: begin
       miso_a[14] <= serial_data_a_i;
       miso_b[14] <= serial_data_b_i;
       serial_sdi_r <= mosi_1[1];
      end
      6'd7: begin
       miso_a[13] <= serial_data_a_i;
       miso_b[13] <= serial_data_b_i;
       serial_sdi_r <= mosi_1[0];
      end
      6'd8: begin
       miso_a[12] <= serial_data_a_i;
       miso_b[12] <= serial_data_b_i;
       serial_sdi_r <= mosi_2[7];
      end
      6'd9: begin
       miso_a[11] <= serial_data_a_i;
       miso_b[11] <= serial_data_b_i;
       serial_sdi_r <= mosi_2[6];
      end
      6'd10: begin
        miso_a[10] <= serial_data_a_i;
        miso_b[10] <= serial_data_b_i;
        serial_sdi_r <= mosi_2[5];
      end
      6'd11: begin
        miso_a[9] <= serial_data_a_i;
        miso_b[9] <= serial_data_b_i;
        serial_sdi_r <= mosi_2[4];
      end
      6'd12: begin
        miso_a[8] <= serial_data_a_i;
        miso_b[8] <= serial_data_b_i;
        serial_sdi_r <= mosi_2[3];
      end
      6'd13: begin
        miso_a[7] <= serial_data_a_i;
        miso_b[7] <= serial_data_b_i;
        serial_sdi_r <= mosi_2[2];
      end
      6'd14: begin
        miso_a[6] <= serial_data_a_i;
        miso_b[6] <= serial_data_b_i;
        serial_sdi_r <= mosi_2[1];
      end
      6'd15: begin
        miso_a[5] <= serial_data_a_i;
        miso_b[5] <= serial_data_b_i;
        serial_sdi_r <= mosi_2[0];
      end
      6'd16: begin
        miso_a[4] <= serial_data_a_i;
        miso_b[4] <= serial_data_b_i;
        serial_sdi_r <= 1'b1;
      end
      6'd17: begin
        miso_a[3] <= serial_data_a_i;
        miso_b[3] <= serial_data_b_i;
        serial_sdi_r <= 1'b1;
      end
      6'd18: begin
        miso_a[2] <= serial_data_a_i;
        miso_b[2] <= serial_data_b_i;
        serial_sdi_r <= 1'b1;
      end
      6'd19: begin
        miso_a[1] <= serial_data_a_i;
        miso_b[1] <= serial_data_b_i;
        serial_sdi_r <= 1'b1;
      end
      6'd20: begin
        miso_a[0] <= serial_data_a_i;
        miso_b[0] <= serial_data_b_i;
        serial_sdi_r <= 1'b1;
        if (mode == 2'd3) begin
          adc_reg_a[4:0] <= miso_a[6:2];
          adc_reg_b[4:0] <= miso_b[6:2];
        end
      end
      default: begin
        serial_sdi_r <= 1'b1;
      end
    endcase
  end //always
  
  assign parallel_data_a =  miso_a ;
  assign parallel_data_b =  miso_b ;

endmodule