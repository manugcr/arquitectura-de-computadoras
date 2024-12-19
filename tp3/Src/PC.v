`timescale 1ns / 1ps

// almacena y actualiza la dirección de la instrucción
// actual basada en las señales de entrada.

module PC(PC_In, PCResult, Enable, Reset, Clock);

    // Entradas
    input [31:0] PC_In; // Dirección de entrada al contador de programa
    input Reset;        // Señal de reinicio (Reset)
    input Clock;        // Señal de reloj (Clock)
    input Enable;       // Señal de habilitación (Enable)

    // Salidas
    output reg [31:0] PCResult; // Dirección actual del contador de programa

    // Bloque inicial para establecer el valor inicial del contador de programa
    initial begin
        PCResult <= 32'h00000000; // Valor inicial del PC
    end

    // Bloque always sensitivo al flanco positivo del reloj o la señal de reinicio
    always @(posedge Clock, posedge Reset) begin
        if (Reset) begin
            // Si se activa el reinicio, establecer el PC a 0
            PCResult <= 32'h00000000;
        end else if (Enable) begin
            // Si Enable está activo, actualizar el PC con el valor de entrada
            PCResult <= PC_In;
        end
    end

endmodule
