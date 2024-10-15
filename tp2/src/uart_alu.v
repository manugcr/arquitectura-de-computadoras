module uart_alu #(
    parameter NB_DATA   = 8,
    parameter NB_ALU_OP = 6
) (
    input  wire i_clk,
    input  wire i_reset,
    input  wire i_rx,
    output wire o_tx,
    output wire o_test_led
);

  // wire clk_50;
  // UART
  wire o_tick;
  wire [NB_DATA-1:0] rx_data;
  wire [NB_DATA-1:0] tx_data;
  wire rx_done;
  wire tx_done;
  wire tx_start;

  // ALU
  wire [NB_DATA-1:0] alu_data_out;
  wire [NB_DATA-1:0] alu_data_A;
  wire [NB_DATA-1:0] alu_data_B;
  wire [NB_ALU_OP-1:0] alu_op;


  baud_rate #(
  ) baud_rate1 (
      .i_reset(i_reset),
      .i_clk  (i_clk),
      .o_tick (o_tick)
  );

  receiver #(
      .NB_DATA(NB_DATA),
      .NB_STOP(1)
  ) receiver1 (
      .i_reset(i_reset),
      .i_tick(o_tick),
      .i_rx(i_rx),
      .i_clk(i_clk),
      .o_rx_array(rx_data),
      .o_rx_end(rx_done)
  );

  transmitter #(
      .NB_DATA(NB_DATA)
  ) transmitter1 (
      .i_reset(i_reset),
      .i_tx_array(tx_data),  // envio la misma data que recibo
      .i_tx_start(tx_start),  // cuando termino de recibir, empiezo a enviar
      .i_tick(o_tick),
      .i_clk(i_clk),
      .o_tx(o_tx),
      .o_tx_end(tx_done)
  );


  uart #(
      .NB_DATA  (NB_DATA),
      .NB_ALU_OP(NB_ALU_OP)
  ) uart1 (
      .i_clk(i_clk),
      .i_reset(i_reset),
      .i_rx_end(rx_done),
      .i_rx_array(rx_data),
      .i_result_alu(alu_data_out),
      .o_tx_array(tx_data),
      .o_operation(alu_op),
      .o_operator_A(alu_data_A),
      .o_operator_B(alu_data_B),
      .o_tx_start(tx_start)
  );


  alu #(
      .NB_OP  (NB_ALU_OP),
      .NB_DATA(NB_DATA)
  ) alu1 (
      .i_op(alu_op),
      .i_data_a(alu_data_A),
      .i_data_b(alu_data_B),
      .o_data(alu_data_out)
  );

  assign o_test_led = i_reset;

endmodule