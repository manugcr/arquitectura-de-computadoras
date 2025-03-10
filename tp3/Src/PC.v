`timescale 1ns / 1ps

// almacena y actualiza la dirección de la instrucción
// actual basada en las señales de entrada.

module PC(PC_In, PCResult, Enable, Reset, Clock,i_halt,i_enable, i_flush);

//module PC(PC_In, PCResult, Enable, Reset, Clock,stall);
    // Entradas
    input [31:0] PC_In; // Dirección de entrada al contador de programa
    input Reset;        // Señal de reinicio (Reset)
    input Clock;        // Señal de reloj (Clock)
    input Enable;       // Señal de habilitación (Enable)
    input i_halt;
    input i_enable;
    input i_flush;

    // Salidas
    output reg [31:0] PCResult; // Dirección actual del contador de programa

    // Valor límite para bloquear cambios en PCResult
    localparam [31:0] LIMIT = 32'h000007FF; // 000111111111 en hexadecimal

    // Bloque always sensitivo al flanco positivo del reloj o la señal de reinicio
       always @(posedge Clock or posedge Reset) begin
        if (Reset || i_flush) begin
            PCResult <= 32'h00000000;
        end else if (Enable && !i_halt  && i_enable) begin
                PCResult <= PC_In;
      

        end
    end

    //NOTA: La memoria de instrucciones, funciona como un arreglo ciclico, apenas se termine de recorrer
    // comienza de nuevo
    

endmodule
