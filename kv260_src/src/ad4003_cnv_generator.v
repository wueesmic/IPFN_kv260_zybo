`timescale 1ns / 1ps


//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/07/2022 12:35:41 PM
// Design Name: 
// Module Name: ad4003_cov_generator
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

//conv generator for ad4003 in 3wire turbo mode
module ad4003_cov_generator #(parameter MAX_BYTE = 1, 
    parameter CLK_FREQ_MHZ = 200,
    parameter TQUIET1_DELAY_PULSES = 38,
    //parameter TQUIET1_DELAY_NS = 1/CLK_FREQ_MHZ*TQUIET1_DELAY_PULSES,
    parameter TEN_DELAY_PULSES = 2,
    //parameter TEN_DELAY_NS = 1/CLK_FREQ_MHZ*TEN_DELAY_PULSES,
    parameter TQUIET2_DELAY_PULSES = 2
    /*parameter TQUIET2_DELAY_NS = 1/CLK_FREQ_MHZ*TQUIET2_DELAY_PULSES*/)(
    
    input clk,
    input rst_L,
    input i_trig,
    input i_scl,
    //input reg[32:0] i_TX_Data,
    output reg o_start_conv,
    output reg o_end_conv,
    output reg o_DV,
    output reg o_word_sync_n,
    output reg o_cnv,
    
    //debug //state
    output [2:0] o_debug_state,
    output [7:0] o_debug_scl_counter
    );
    
    parameter TCQ = 1; //just for simulation
    
    reg[0:0] trig_flag = 0;
    reg[0:0] ready_flag = 0;
    reg[0:0] scl_flag = 0;
    reg[1:0] DV_flag = 0;
    reg[7:0] byte_count = 0;
    reg[7:0] r_scl_counter = 0;
    reg[31:0] r_delay_counter = 0;
//    reg[$clog2(TQUIET1_DELAY_PULSES+1)-1:0] r_delay_counter = 0;
    
    reg Transfer_flag = 0;
    
    //statemachine
    reg[2:0] state = 3'd0;
    localparam IDLE = 3'd0;
    localparam TQUIET1 = 3'd1;
    localparam TEN = 3'd2;
    localparam TRANSFER = 3'd3;
    localparam TQUIET2 = 3'd4;

    assign o_debug_state = state;
    assign o_debug_scl_counter = r_scl_counter;
    
    always @(posedge clk) begin
        if(!rst_L) begin
            state <= IDLE;
            //r_scl_counter <= #TCQ 8'd0;
            r_delay_counter <= #TCQ 32'd0;
            o_cnv <= #TCQ 1'b0; //start adc conversion
            o_end_conv <= #TCQ 1'b0;
            o_DV <= #TCQ 1'b0;
            o_word_sync_n <= #TCQ 1'b0;
        end 
        else begin
            case(state)
                IDLE:begin
                    //r_scl_counter <= #TCQ 8'd0;
                    r_delay_counter <= #TCQ 32'd0;
                    o_DV <= #TCQ 1'b0;
                    if(i_trig) begin      //MICHI MAYBE REMOVE THE EDGE DETECTION
                        trig_flag <= #TCQ 1'b1;
                        o_cnv <= #TCQ 1'b1; //start adc conversion
                        o_end_conv <= #TCQ 1'b0;
                        o_DV <= #TCQ 1'b0;
                        o_word_sync_n <= #TCQ 1'b0;
                        state <= #TCQ TQUIET1;
                    end else begin
                        //trig_flag <= 1'b0;
                        o_word_sync_n <= #TCQ 1'b1;
                    end
                    
                end
                TQUIET1:begin
                    //start spi master
                    if(r_delay_counter == TQUIET1_DELAY_PULSES-1) begin   //make sure tquiet1 is reached
                        //o_start_conv <= 1'b1;
                        o_end_conv <= #TCQ 1'b0;
                        o_cnv <= 1'b0; //see datasheet ad4003
                        r_delay_counter <= #TCQ 1'b0;
                        state <= #TCQ TEN;
                    end else begin
                        o_start_conv <= #TCQ 1'b0;
                        r_delay_counter <= #TCQ r_delay_counter+1;
                    end
                end
                TEN:begin
                    //start spi master
                    if(r_delay_counter == TEN_DELAY_PULSES-1) begin   //make sure tquiet1 is reached
                        o_start_conv <= #TCQ 1'b1;
                        o_word_sync_n <= #TCQ 1'b0;
                        o_end_conv <= #TCQ 1'b0;
                        o_cnv <= #TCQ 1'b0; //see datasheet ad4003
                        r_delay_counter <= #TCQ 0;
                        scl_flag <= #TCQ 1'b0;
                        state <= #TCQ TRANSFER;
                    end else begin
                        o_start_conv <= #TCQ 1'b0;
                        r_delay_counter <= #TCQ r_delay_counter+1;
                    end     
                end
                TRANSFER:begin
                    //2nd try with always for scl 
//                  //count number of scl edges
                    if(r_scl_counter == 8'd1) begin
                        o_start_conv <= #TCQ 1'b0;
                        Transfer_flag <= 1'b1;
                    end else if(r_scl_counter == 8'd18 && Transfer_flag) begin 
                        Transfer_flag <= 1'b0;
                        o_end_conv <= #TCQ 1'b1;
                        //r_scl_counter <= #TCQ 32'd0;
                        r_delay_counter <= #TCQ 32'd0;
                        state <= #TCQ TQUIET2;
                    end else begin
                        if(r_delay_counter >= 1000) begin //break in case something went wrong in transmission.
                            state <= #TCQ IDLE;
                        end else begin
                            r_delay_counter <= #TCQ r_delay_counter+1;
                        end
                    end
                end
                TQUIET2:begin
                    //start SPI master
                    if(r_delay_counter == TQUIET2_DELAY_PULSES-1) begin   //make sure tquiet2 is reached
                        o_end_conv <= #TCQ 1'b1;
                        o_DV <= #TCQ 1'b1; //Data valid
                        o_word_sync_n <= #TCQ 1'b1;
                        r_delay_counter <= #TCQ 0;
                        state <= #TCQ IDLE;
                    end else begin
                        o_start_conv <= #TCQ 1'b0;
                        r_delay_counter <= #TCQ r_delay_counter+1;
                    end
                end
            endcase
       end
    end
    
    reg reset_start_flag = 0;
    reg set_end_flag = 0;
    
    //count scl edges
    always @(posedge i_scl) begin
    //always @(negedge i_scl) begin   //MICHI
        if(o_start_conv) begin
            set_end_flag <= 1'b0;
            r_scl_counter <= #TCQ 8'd1;
            reset_start_flag <= #TCQ 1'd1;
        end else begin
            r_scl_counter <= #TCQ r_scl_counter + 1;
        end
    end
    
endmodule

