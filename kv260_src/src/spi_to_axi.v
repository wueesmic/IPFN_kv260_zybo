// vim: set ts=4 sw=4 tw=0 et
//////////////////////////////////////////////////

`timescale 1ns / 1ps



module spi_to_axi #(
    // Width of data bus in bits
    parameter DATA_WIDTH = 32,
    // Width of wstrb (width of data bus in words)
    parameter STRB_WIDTH = (DATA_WIDTH/8),
    // Width of counter in bits (counts from = to 2^CNT_WIDTH-1 )
    parameter CNT_WIDTH = 9, //( 0- 511)
    // to which number should the counter count?
    parameter CNT_MAX = 511, //( 0 - 511)
    // Width of counter in bits (counts from = to 2^CNT_WIDTH-1 )
    parameter KEEP_WIDTH = 1 //(
    
)
    (
        input  clk,
        input  rst_L,
        
     
        input  i_DV, //data valid
        input  [DATA_WIDTH-1:0] i_data, //CONV
        output o_fifo_en, //invokes next byte from fifo
        
        /*
        * AXI lite master interface
        */
        output m_axis_tvalid,
        input  m_axis_tready,
        output [DATA_WIDTH-1:0] m_axis_tdata,
        output [KEEP_WIDTH-1:0]   m_axis_tkeep,
        
        output [DATA_WIDTH-1:0] o_counter,
        output m_axis_tlast
    );

    assign m_axis_tkeep =  {KEEP_WIDTH{1'b1}};
    reg [DATA_WIDTH-1:0] counter_r = 'h00;
    reg last_r = 1'b0;
    reg valid_r = 1'b0;
    reg zeroflag_r = 1'b1;
    reg [DATA_WIDTH-1:0] data_r;    //CONV
    reg DV_flag_r = 1'b0;
    reg flag_r = 1'b1;
    
    reg tready_flag = 1'b0;
    
    reg fifo_en_r;
    reg [3:0] fifo_en_cnt = 0;
    
    assign o_counter = counter_r;
    assign o_fifo_en = fifo_en_r;
    //assign m_axis_tdata = counter_r;
    assign m_axis_tdata = data_r;   //CONV
    //assign m_axis_tvalid = 1'b1; // Allways valid
    assign m_axis_tvalid = valid_r;
    assign m_axis_tlast = last_r;

     
    always @ (posedge clk or negedge rst_L) 
    begin
        valid_r <= 1'b0;
        //DV_flag_r <= 1'b1; //just a test
        if (~rst_L) begin
            counter_r  <= 32'h00;
            data_r <=  i_data; //CONV
            last_r <= 1'b0;
            valid_r <= 1'b0;
            DV_flag_r = 1'b1;
        end else begin
            //reset fifo_en
            if(fifo_en_r == 1'b1) begin
                fifo_en_r <= 1'b0; //default
            end
            //initiate first trigger when m_axis_tready turns 1 for the first time
            if(m_axis_tready && !tready_flag) begin
                tready_flag <= 1'b0;
                fifo_en_r <= 1'b1;
            end else if(!m_axis_tready && tready_flag)begin
                tready_flag <= 1'b1;
            end
            if(/*axi_tvalid == 1 && */ (m_axis_tready == 1'b1 && i_DV && !DV_flag_r) /*|| (m_axis_tready == 1'b1 && flag_r == 1'b1)*/) begin 
                DV_flag_r <= 1'b1;
                data_r <= i_data;
                if(zeroflag_r == 1'b1) begin
                    //counter_r <= 32'd0;
                    zeroflag_r <= 1'b0;
                    fifo_en_r <= 1'b1; //loads next byte from fifo
                    valid_r <= 1'b1;
                end else begin
                    data_r <=  i_data; //CONV
                    counter_r <=  counter_r + 1'd1;
                    fifo_en_r <= 1'b1; //loads next byte from fifo
                    valid_r <= 1'b1;
                end
                if (counter_r == (CNT_MAX-1)) begin
                    last_r <= 1'b1;
                end else begin
                    last_r <= 1'b0;
                end
                if (counter_r >= (CNT_MAX)) begin
                    last_r <= 1'b0;
                    counter_r <= 32'd0;
                    zeroflag_r <= 1'b1;
                    valid_r <= 1'b0;
                end
            end else if(!i_DV && DV_flag_r) begin
                DV_flag_r <= 1'b0;
            end
        end
     end
        

endmodule