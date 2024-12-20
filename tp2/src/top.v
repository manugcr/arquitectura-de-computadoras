module top#
(
    parameter NB_DATA = 8,
    parameter N_TICKS = 16,
    parameter COUNTER_LIMIT = 326,
    parameter NB_COUNTER = 9,
    parameter PTR_LEN = 2,
    parameter NB_OPCODE = 6     
)
( 
    input wire i_clk,
    input wire i_reset,
    input wire i_uartRx,
    output wire o_uartTx,
    output wire [NB_DATA-1:0] result_leds
);


wire tx_full;
wire rx_empty;
wire [NB_DATA-1:0] data_to_read;


wire rx_read;
wire tx_write;
wire [NB_DATA-1:0] data_to_write;
wire [NB_OPCODE-1:0] alu_opcode;
wire [NB_DATA-1:0] alu_op_A;
wire [NB_DATA-1:0] alu_op_B;

wire [NB_DATA-1:0] alu_result;

assign result_leds = alu_result;

uart_interface#
(
    .NB_DATA(NB_DATA),
    .N_TICKS(N_TICKS),
    .COUNTER_LIMIT(COUNTER_LIMIT),
    .NB_COUNTER(NB_COUNTER),
    .PTR_LEN(PTR_LEN)        
) uartUnit
(
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_read_uart(rx_read),
    .i_write_uart(tx_write),
    .i_rx(i_uartRx),
    .i_data_to_write(data_to_write),

    .o_tx_full(tx_full),
    .o_rx_empty(rx_empty),
    .o_tx(o_uartTx),
    .o_data_to_read(data_to_read)
);

alu_uart_interface#
(
    .NB_DATA(NB_DATA),
    .NB_OPCODE(NB_OPCODE)     
) alu_uart_interfaceUnit
(
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_alu_result(alu_result),
    .i_data_to_read(data_to_read),
    .i_fifo_rx_empty(rx_empty),
    .i_fifo_tx_full(tx_full),

    .o_fifo_rx_read(rx_read),
    .o_fifo_tx_write(tx_write),
    .o_data_to_write(data_to_write),
    .o_alu_opcode(alu_opcode),
    .o_alu_op_A(alu_op_A),
    .o_alu_op_B(alu_op_B),
    .o_is_valid()
);

alu#
(
    .NB_DATA(NB_DATA),
    .NB_OP(NB_OPCODE)
) aluUnit
( 
    .i_data_a(alu_op_A),
    .i_data_b(alu_op_B),
    .i_op(alu_opcode),
    .o_alu_result(alu_result)
); 

endmodule
