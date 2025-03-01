`timescale 1ns / 1ps

// almacena y actualiza la dirección de la instrucción
// actual basada en las señales de entrada.

module PC(PC_In, PCResult, Enable, Reset, Clock,stall);

    // Entradas
    input [31:0] PC_In; // Dirección de entrada al contador de programa
    input Reset;        // Señal de reinicio (Reset)
    input Clock;        // Señal de reloj (Clock)
    input Enable;       // Señal de habilitación (Enable)

    // Salidas
    output reg [31:0] PCResult; // Dirección actual del contador de programa

    output reg stall;

    reg [1:0] cycle_count; // Contador de ciclos de reloj (2 bits para contar 0, 1 y 2 ciclos)


    // Valor límite para bloquear cambios en PCResult
    localparam [31:0] LIMIT = 32'h000007FF; // 000111111111 en hexadecimal


    // Bloque inicial para establecer el valor inicial del contador de programa
    initial begin
         PCResult = 32'h00000000; // Valor inicial del PC
        stall = 1'b1;             // Stall inicialmente habilitado
        cycle_count = 2'b00;      // Inicializamos el contador de ciclos
    end

    // Bloque always sensitivo al flanco positivo del reloj o la señal de reinicio
       always @(posedge Clock or posedge Reset) begin
        if (Reset) begin
            // Si se activa el reinicio, establecer el PC a 0 y el contador a 0
            PCResult <= 32'h00000000;
            stall <= 1'b1;         // Reset stall a 1
            cycle_count <= 2'b00;  // Reset contador de ciclos
        end else if (Enable) begin
            // Si Enable está activo, y stall es 0, actualizar el PC
            if (stall == 1'b0 && PC_In < LIMIT) begin
                PCResult <= PC_In;
            end

            // Si ya pasaron 2 ciclos de reloj, el stall se pone a 0
            if (cycle_count == 1) begin
                stall <= 1'b0;      // Después de 2 ciclos, el stall se pone a 0
            end else begin
                cycle_count <= cycle_count + 1; // Incrementar el contador de ciclos
            end
        end
    end

    //NOTA: La memoria de instrucciones, funciona como un arreglo ciclico, apenas se termine de recorrer
    // comienza de nuevo

endmodule
