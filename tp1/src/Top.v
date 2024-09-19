
`timescale 1ns / 1ps


module Top #(
    parameter NB_SW   = 8,  // switch numbers
    parameter NB_BTN  = 3,  // buttons numbers
    parameter NB_LEDS = 8,  // LEDS numbers
    parameter NB_DATA = 8,  // size of operands handled by the 8-bit ALU
    parameter NB_OP   = 6   // operating signal size
) (
    input wire [NB_SW-1:0] i_sw,    // 8 bit bus for input switches
    input wire [NB_BTN-1:0] i_btn,  // 8 bit bus for buttons
    input wire i_clk,               // clock signal for synchronization
    input wire i_reset,             // signal for reset
    output wire o_test_led,         // output to check reset status
    output wire signed [NB_LEDS-1:0] o_led // output to represent the result of the ALU
);

  reg  [  NB_OP - 1 : 0] store_operation;     //Register to store the operation to be performed in the ALU
  reg  [NB_DATA - 1 : 0] operand_A;
  reg  [NB_DATA - 1 : 0] operand_B;
  wire [NB_DATA - 1 : 0] wire_result_output;  // cable that connects the output of the ALU with other modules

  // instantiating the ALU module, with the NB_OP and NB_DATA parameters set to 6 and 8 bits
  alu #(
      .NB_OP  (NB_OP),
      .NB_DATA(NB_DATA)
  ) alu1 (
      .i_op(store_operation),
      .i_data_a(operand_A),
      .i_data_b(operand_B),
      .o_data(o_led)
  );

//Each time a rising edge of the clock signal occurs:
//If i_reset is active, the operator (alu_op) is set to 0.
//If the i_btn[2] button is pressed, the value of the switches (i_sw) is loaded into alu_op, i.e. it selects the operation that the ALU will perform based on the switches.
 
  always @(posedge i_clk) begin
    if (i_reset) store_operation <= {(NB_OP) {1'b0}};
    else if (i_btn[2]) store_operation <= i_sw[NB_OP-1:0];
  end

  // Carga de operandos
  always @(posedge i_clk) begin
    if (i_reset) // negado porque creo que es un reset activo en bajo
    begin
      operand_A <= {(NB_DATA) {1'b0}};
      operand_B <= {(NB_DATA) {1'b0}};
    end else if (i_btn[0]) operand_A <= i_sw[NB_DATA-1:0];
    else if (i_btn[1]) operand_B <= i_sw[NB_DATA-1:0];
  end

  assign o_test_led = i_reset;

endmodule
