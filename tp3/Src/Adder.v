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

    // Bloque always que se ejecuta en cada cambio de las señales A, B o stall.
    always @ (A, B) begin
            // Si stall es 0, realizar la suma
            AddResult = A + $signed(B);
    end

endmodule

