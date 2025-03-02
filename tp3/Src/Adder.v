`timescale 1ns / 1ps

// Definición del módulo Adder, que realiza una operación de suma entre dos números de 32 bits.
module Adder(A, B, AddResult, stall);

    // Entradas del módulo:
    // A: Operando A, un número de 32 bits sin signo.
    // B: Operando B, un número de 32 bits sin signo.
    input [31:0] A, B;
    input stall;  // Entrada adicional: señal de control para bloquear la suma

    // Salida del módulo:
    // AddResult: Resultado de la suma de A y B, un número de 32 bits almacenado como registro.
    output reg [31:0] AddResult;

    // Bloque always que se ejecuta en cada cambio de las señales A, B o stall.
    always @ (A, B, stall) begin
        if (stall == 1'b0) begin
            // Si stall es 0, realizar la suma
            AddResult = A + $signed(B);
        end else begin
            // Si stall es 1, no hacer nada (el valor de AddResult no cambia)
            AddResult = AddResult;  // Mantener el valor anterior
        end
    end

endmodule

