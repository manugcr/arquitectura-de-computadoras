`timescale 1ns/1ps

module tb_ALU;

parameter NB_DATA = 8;
parameter NB_OP = 6;

// localparam AND = 100100;

// Señales
reg signed [NB_DATA-1:0] i_data_a;
reg signed [NB_DATA-1:0] i_data_b;
reg [NB_OP-1:0] i_op;
wire signed [NB_DATA-1:0] o_data;

// Instanciar la ALU
ALU #(
    .NB_DATA(NB_DATA),
    .NB_OP(NB_OP)
) uut (
    .i_data_a(i_data_a),
    .i_data_b(i_data_b),
    .i_op(i_op),
    .o_data(o_data)
);

// Archivo para el VCD
initial begin
    $dumpfile("alu.vcd");
    $dumpvars(0, tb_ALU);

    // Prueba 1: ADD
    i_data_a = 8'd10;
    i_data_b = 8'd15;
    i_op = 6'b100000; // ADD
    #10;

    // Prueba 2: SUB
    i_data_a = 8'd20;
    i_data_b = 8'd5;
    i_op = 6'b100010; // SUB
    #10;

    // Prueba 3: AND
    i_data_a = 8'b10101010;
    i_data_b = 8'b11001100;
    i_op = 6'b100100; // AND
    #10;

    // Prueba 4: OR
    i_data_a = 8'b10101010;
    i_data_b = 8'b11001100;
    i_op = 6'b100101; // OR
    #10;

    // Prueba 5: XOR
    i_data_a = 8'b10101010;
    i_data_b = 8'b11001100;
    i_op = 6'b100110; // XOR
    #10;

    // Prueba 6: SRA
    i_data_a = 8'b10101010;
    i_op = 6'b000011; // SRA
    #10;

    // Prueba 7: SRL
    i_data_a = 8'b10101010;
    i_op = 6'b000010; // SRL
    #10;

    // Prueba 8: NOR
    i_data_a = 8'b10101010;
    i_data_b = 8'b11001100;
    i_op = 6'b100111; // NOR
    #10;

    $finish;
end

endmodule
