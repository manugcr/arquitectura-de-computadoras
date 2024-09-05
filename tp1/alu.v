// iverilog -o tb_alu tb_alu.v          iverilog -o tb_alu tb_alu.v alu.v     Me anduvo asi no c porque
// vvp tb_alu
// gtkwave alu.vcd                 (en el testbench vas a tener que definir que se cree el test.vcd)

// Implementar en FPGA una ALU:
//  - La ALU debe ser parametrizable (bus de datos) para poder ser utilizada posteriormente
//  - Validar el desarrollo con test bench
//      - Debe incluir generacion de entradas aleatorias y codigo de chequeo
//  - Simular el diseno usando vivado con analisis de tiempo

//  ADD     100000
//  SUB     100010
//  AND     100100
//  OR      100101
//  XOR     100110
//  SRA     000011
//  SRL     000010
//  NOR     100111  

module ALU 
#(
    parameter NB_DATA = 8,
    parameter NB_OP = 6
)
(
    input wire signed [NB_DATA - 1 : 0] i_data_a,   // 8 bits para a
    input wire signed [NB_DATA - 1 : 0] i_data_b,   // 8 bits para b
    input wire signed [NB_DATA - 1 : 0] i_op,       // 8 bits para operador
    // input        FALTAN LOS SW 1 2 3
    output wire signed [NB_OP - 1 : 0] o_data       // Salida de la alu
);

reg [NB_DATA - 1 : 0] tmp ;     // Registro para almacenar calculo, y despues pasarlo a la salida

//always @(posedge sw_1) begin
always @(*) 
begin
    case (i_op)
        6'b100000: tmp = i_data_a + i_data_b;       // Operación ADD
        6'b100010: tmp = i_data_a - i_data_b;       // Operación SUB
        6'b100100: tmp = i_data_a & i_data_b;       // Operación AND
        6'b100101: tmp = i_data_a | i_data_b;       // Operación OR
        6'b100110: tmp = i_data_a ^ i_data_b;       // Operación XOR
        6'b000011: tmp = i_data_a >>> 1;            // Operación SRA
        6'b000010: tmp = i_data_a >> 1;             // Operación SRL
        6'b100111: tmp = ~(i_data_a | i_data_b);    // Operación NOR
        default: tmp = 0;
    endcase
end

assign o_data = tmp;        // esto conecta el registro tmp con la salida o_data (imagina que son cables, registro a puerto)
    
endmodule