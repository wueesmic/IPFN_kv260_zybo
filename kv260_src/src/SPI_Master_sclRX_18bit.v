///////////////////////////////////////////////////////////////////////////////
// Description: SPI (Serial Peripheral Interface) Master
//              Creates master based on input configuration.
//              Sends a byte one bit at a time on MOSI
//              Will also receive byte data one bit at a time on MISO.
//              Any data on input byte will be shipped out on MOSI.
//
//              To kick-off transaction, user must pulse i_TX_DV.
//              This module supports multi-byte transmissions by pulsing
//              i_TX_DV and loading up i_TX_Byte when o_TX_Ready is high.
//
//              This module is only responsible for controlling Clk, MOSI, 
//              and MISO.  If the SPI peripheral requires a chip-select, 
//              this must be done at a higher level.
//
// Note:        i_Clk must be at least 2x faster than i_SPI_Clk
//
// Parameters:  SPI_MODE, can be 0, 1, 2, or 3.  See above.
//              Can be configured in one of 4 modes:
//              Mode | Clock Polarity (CPOL/CKP) | Clock Phase (CPHA)
//               0   |             0             |        0
//               1   |             0             |        1
//               2   |             1             |        0
//               3   |             1             |        1
//              More: https://en.wikipedia.org/wiki/Serial_Peripheral_Interface_Bus#Mode_numbers
//              CLKS_PER_HALF_BIT - Sets frequency of o_SPI_Clk.  o_SPI_Clk is
//              derived from i_Clk.  Set to integer number of clocks for each
//              half-bit of SPI data.  E.g. 100 MHz i_Clk, CLKS_PER_HALF_BIT = 2
//              would create o_SPI_CLK of 25 MHz.  Must be >= 2
//
///////////////////////////////////////////////////////////////////////////////

module SPI_Master_sclRX_18bit
  #(parameter SPI_MODE = 0,
    parameter CLKS_PER_HALF_BIT = 2,
    parameter BIT_PER_TRANSFER = 18) //max 64 bit
  (
   // Control/Data Signals,
   input        i_Rst_L,     // FPGA Resetr_RX_Bit_Count
   input        i_Clk,       // FPGA Clock
   input        i_sclRX,     // delayd scl for RX byte
     
   // TX (MOSI) Signals
   input [BIT_PER_TRANSFER-1:0]  i_TX_Byte,        // Byte to transmit on MOSI
   input        i_TX_DV,          // Data Valid Pulse with i_TX_Byte
   output reg   o_TX_Ready,       // Transmit Ready for next byte
   
   // RX (MISO) Signals
   output reg       o_RX_DV,     // Data Valid pulse (1 clock cycle)
   output reg [BIT_PER_TRANSFER-1:0] o_RX_Byte,   // Byte received on MISO

   // SPI Interface
   output reg o_SPI_Clk,
   input      i_SPI_MISO,
   output reg o_SPI_MOSI,
   
   
   output [5:0] debug_RXcounter, //DEBUG
   output [5:0] debug_TXcounter //DEBUG
   );
    
  //DEBUG------
  assign debug_RXcounter = r_RX_Bit_Count;
  assign debug_TXcounter = r_TX_Bit_Count;
    
  // SPI Interface (All Runs at SPI Clock Domain)
  wire w_CPOL;     // Clock polarity
  wire w_CPHA;     // Clock phase

  reg [$clog2(CLKS_PER_HALF_BIT*2)-1:0] r_SPI_Clk_Count;
  reg r_SPI_Clk;
  reg [10:0] r_SPI_Clk_Edges;
  reg r_Leading_Edge;
  reg r_Trailing_Edge;
  reg       r_TX_DV;
  reg [BIT_PER_TRANSFER-1:0] r_TX_Byte;

  reg [5:0] r_RX_Bit_Count = 0; //max 64 bit
  reg [5:0] r_TX_Bit_Count = 0;
  
  reg RX_DV_r = 0;
  
  reg r_sclRX_flag = 0;
  
  // CPOL: Clock Polarity
  // CPOL=0 means clock idles at 0, leading edge is rising edge.
  // CPOL=1 means clock idles at 1, leading edge is falling edge.
  assign w_CPOL  = (SPI_MODE == 2) | (SPI_MODE == 3);

  // CPHA: Clock Phase
  // CPHA=0 means the "out" side changes the data on trailing edge of clock
  //              the "in" side captures data on leading edge of clock
  // CPHA=1 means the "out" side changes the data on leading edge of clock
  //              the "in" side captures data on the trailing edge of clock
  assign w_CPHA  = (SPI_MODE == 1) | (SPI_MODE == 3);



  // Purpose: Generate SPI Clock correct number of times when DV pulse comes
  always @(posedge i_Clk or negedge i_Rst_L)
  begin
    if (~i_Rst_L)
    begin
      o_TX_Ready      <= 1'b0;
      r_SPI_Clk_Edges <= 0;
      r_Leading_Edge  <= 1'b0;
      r_Trailing_Edge <= 1'b0;
      r_SPI_Clk       <= w_CPOL; // assign default state to idle state
      r_SPI_Clk_Count <= 0;
    end
    else
    begin

      // Default assignments
      r_Leading_Edge  <= 1'b0;
      r_Trailing_Edge <= 1'b0;
      
      if (i_TX_DV)
      begin
        o_TX_Ready      <= 1'b0;
        r_SPI_Clk_Edges <= (BIT_PER_TRANSFER * 2);  // Total # edges in one byte ALWAYS 16  //MICHI 16 changed to BIT_PER_TRANSFER * 2
      end
      else if (r_SPI_Clk_Edges > 0)
      begin
        o_TX_Ready <= 1'b0;
        
        if (r_SPI_Clk_Count == CLKS_PER_HALF_BIT*2-1)
        begin
          r_SPI_Clk_Edges <= r_SPI_Clk_Edges - 1'b1;
          r_Trailing_Edge <= 1'b1;
          r_SPI_Clk_Count <= 0;
          r_SPI_Clk       <= ~r_SPI_Clk;
        end
        else if (r_SPI_Clk_Count == CLKS_PER_HALF_BIT-1)
        begin
          r_SPI_Clk_Edges <= r_SPI_Clk_Edges - 1'b1;
          r_Leading_Edge  <= 1'b1;
          r_SPI_Clk_Count <= r_SPI_Clk_Count + 1'b1;
          r_SPI_Clk       <= ~r_SPI_Clk;
        end
        else
        begin
          r_SPI_Clk_Count <= r_SPI_Clk_Count + 1'b1;
        end
      end  
      else
      begin
        o_TX_Ready <= 1'b1;
      end
      
      
    end // else: !if(~i_Rst_L)
  end // always @ (posedge i_Clk or negedge i_Rst_L)


  // Purpose: Register i_TX_Byte when Data Valid is pulsed.
  // Keeps local storage of byte in case higher level module changes the data
  always @(posedge i_Clk or negedge i_Rst_L)
  begin
    if (~i_Rst_L)
    begin
      r_TX_Byte <= 64'h00;
      r_TX_DV   <= 1'b0;
    end
    else
      begin
        r_TX_DV <= i_TX_DV; // 1 clock cycle delay
        if (i_TX_DV)
        begin
          r_TX_Byte <= i_TX_Byte;
        end
      end // else: !if(~i_Rst_L)
  end // always @ (posedge i_Clk or negedge i_Rst_L)


  // Purpose: Generate MOSI data
  // Works with both CPHA=0 and CPHA=1
  always @(posedge i_Clk or negedge i_Rst_L)
  begin
    if (~i_Rst_L)
    begin
      o_SPI_MOSI     <= 1'b0;
      r_TX_Bit_Count <= BIT_PER_TRANSFER-1; // send MSb first   //MICHI 3'b111; change to BIT_PER_TRANSFER-1
    end
    else
    begin
      // If ready is high, reset bit counts to default
      if (o_TX_Ready)
      begin
        r_TX_Bit_Count <= BIT_PER_TRANSFER-1;       //MICHI 3'b111; change to BIT_PER_TRANSFER-1
      end
      // Catch the case where we start transaction and CPHA = 0
      else if (r_TX_DV & ~w_CPHA)
      begin
        o_SPI_MOSI     <= r_TX_Byte[ BIT_PER_TRANSFER - 1];            //MICHI 3'b111; change to BIT_PER_TRANSFER - 1
        r_TX_Bit_Count <= (BIT_PER_TRANSFER - 2);       //MICHI 3'b110; change to BIT_PER_TRANSFER - 2
      end
      else if ((r_Leading_Edge & w_CPHA) | (r_Trailing_Edge & ~w_CPHA))
      begin
        r_TX_Bit_Count <= r_TX_Bit_Count - 1'b1;
        o_SPI_MOSI     <= r_TX_Byte[r_TX_Bit_Count];
      end
    end
  end


  // Purpose: Read in MISO data. MICHI--------------------------------------------
  always @(posedge i_Clk or negedge i_Rst_L)    //changed scl to i_clk
  begin
    if (!i_Rst_L) begin //reset
      o_RX_Byte      <= 64'h0000;
      o_RX_DV        <= 1'b0;
      r_RX_Bit_Count <= (BIT_PER_TRANSFER-1);         //MICHI 3'b111; change to BIT_PER_TRANSFER-1
    end else begin
        if(o_RX_DV)begin    //reset o_RX_DV to make it 1 clk plulse
            o_RX_DV <= 1'b0;
        end
        if(i_sclRX && !r_sclRX_flag) begin
            r_sclRX_flag <= 1'b1;
            //o_RX_DV   <= 1'b0; // Default Assignments //to make sure DV is only 1 clk puls
    //      if (o_TX_Ready) // Check if ready is high, if so reset bit count to default
    //      begin
    //        r_RX_Bit_Count <= 3'b111;
    //      end else begin
            o_RX_Byte[r_RX_Bit_Count] <= i_SPI_MISO;  // Sample data
            if (r_RX_Bit_Count == 6'h000) begin
              o_RX_DV   <= 1'b1;   // Byte done, pulse Data Valid
              RX_DV_r <= 1;
              r_RX_Bit_Count <= (BIT_PER_TRANSFER-1);    //MICHI 3'b111; change to BIT_PER_TRANSFER-1
            end 
            else begin
                o_RX_DV   <= 1'b0; // Default Assignments
                r_RX_Bit_Count <=  r_RX_Bit_Count - 1'b1;
            end
    //      end if o_TX_Ready
        end else if(!i_sclRX && r_sclRX_flag) begin  //to make sure only the sclRX posedge is detected
            r_sclRX_flag <= 1'b0;
        end
     end
   
  end //always
  
  //MICHI MAKE SURE o_RX_DV is only on for 1 clk cycle
  always @(posedge i_Clk) begin
    if(RX_DV_r == 1'b1) begin
        RX_DV_r <= 1'b0;
    end
  end
  
//  // Purpose: Read in MISO data. ORIGINAL
//  always @(posedge i_Clk or negedge i_Rst_L)
//  begin
//    if (~i_Rst_L)
//    begin
//      o_RX_Byte      <= 8'h00;
//      o_RX_DV        <= 1'b0;
//      r_RX_Bit_Count <= 3'b111;
//    end
//    else
//    begin

//      // Default Assignments
//      o_RX_DV   <= 1'b0;

//      if (o_TX_Ready) // Check if ready is high, if so reset bit count to default
//      begin
//        r_RX_Bit_Count <= 3'b111;
//      end
//      else if ((r_Leading_Edge & ~w_CPHA) | (r_Trailing_Edge & w_CPHA))
//      begin
//        o_RX_Byte[r_RX_Bit_Count] <= i_SPI_MISO;  // Sample data
//        r_RX_Bit_Count            <= r_RX_Bit_Count - 1'b1;
//        if (r_RX_Bit_Count == 3'b000)
//        begin
//          o_RX_DV   <= 1'b1;   // Byte done, pulse Data Valid
//        end
//      end
//    end
//  end
  
  // Purpose: Add clock delay to signals for alignment.
  always @(posedge i_Clk or negedge i_Rst_L)
  begin
    if (~i_Rst_L)
    begin
      o_SPI_Clk  <= w_CPOL;
    end
    else
      begin
        o_SPI_Clk <= r_SPI_Clk;
      end // else: !if(~i_Rst_L)
  end // always @ (posedge i_Clk or negedge i_Rst_L)
  

endmodule // SPI_Master