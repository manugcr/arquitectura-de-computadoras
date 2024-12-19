// Define la unidad de tiempo y la precisión de la simulación.
// 1ns significa que la unidad de tiempo es 1 nanosegundo, y 1ps define la precisión como 1 picosegundo.
`timescale 1ns / 1ps

// Definición del módulo Adder, que realiza una operación de suma entre dos números de 32 bits.
module Adder(A, B, AddResult);

    // Entradas del módulo:
    // A: Operando A, un número de 32 bits sin signo.
    // B: Operando B, un número de 32 bits sin signo.
    input [31:0] A, B;

    // Salida del módulo:
    // AddResult: Resultado de la suma de A y B, un número de 32 bits almacenado como registro.
    output reg [31:0] AddResult;

    // Bloque always que se ejecuta en cada cambio de las señales A o B.
    always @ (A, B) begin
        // Realiza la suma de A y B. El operando B se interpreta como un número con signo ($signed).
        // El resultado de la suma se almacena en la salida AddResult.
        AddResult <= A + $signed(B);
    end

endmodule
