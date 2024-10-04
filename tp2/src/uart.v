module uart
   #( 
      parameter DBIT = 8,    
                TICKS_END = 16,           
                DVSR = 163,   
                DVSR_BIT = 8, 
                FIFO_W = 2   
   )
   (
    input wire clk, reset,
    input wire rd_uart, wr_uart, rx,
    input wire [7:0] w_data,
    output wire tx_full, rx_empty, tx,
    output wire [7:0] r_data
   );

   // signal declaration
   wire tick, rx_done_tick, tx_done_tick;
   wire tx_empty, tx_fifo_not_empty;
   wire [7:0] tx_fifo_out, rx_data_out;

   baud_rate #(.M(DVSR), .N(DVSR_BIT)) baud_rate_unit
      (.clk(clk), .reset(reset), .q(), .tick(tick));

   receiver #(.DBIT(DBIT), .TICKS_END(TICKS_END)) receiver_unit
      (.clk(clk), .reset(reset), .rx(rx), .tick(tick),
       .data_ready(rx_done_tick), .data_out(rx_data_out));

   fifo #(.B(DBIT), .W(FIFO_W)) fifo_rx_unit
      (.clk(clk), .reset(reset), .rd(rd_uart),
       .wr(rx_done_tick), .write_data(rx_data_out),
       .empty(rx_empty), .full(), .read_data(r_data));

   fifo #(.B(DBIT), .W(FIFO_W)) fifo_tx_unit
      (.clk(clk), .reset(reset), .rd(tx_done_tick),
       .wr(wr_uart), .write_data(w_data), .empty(tx_empty),
       .full(tx_full), .read_data(tx_fifo_out));

   transmitter #(.DBIT(DBIT), .TICKS_END(TICKS_END)) transmitter_unit
      (.clk(clk), .reset(reset), .tx_go(tx_fifo_not_empty),
       .pulse_tick(tick), .din(tx_fifo_out),
       .tx_done_tick(tx_done_tick), .tx(tx));

   assign tx_fifo_not_empty = ~tx_empty;

endmodule