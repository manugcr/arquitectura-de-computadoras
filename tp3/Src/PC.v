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

    // Valor límite para bloquear cambios en PCResult
    localparam [31:0] LIMIT = 32'h000007FF; // 000111111111 en hexadecimal




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
            // Si Enable está activo y PC_In es menor que el límite, actualizar el PC
            if (PC_In < LIMIT) begin
                PCResult <= PC_In;
            end
            // Si no, mantener el valor actual de PCResult (implícito al no cambiarlo)
        end
    end

    //NOTA: La memoria de instrucciones, funciona como un arreglo ciclico, apenas se termine de recorrer
    // comienza de nuevo

endmodule
