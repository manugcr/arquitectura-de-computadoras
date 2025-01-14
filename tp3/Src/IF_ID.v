`timescale 1ns / 1ps

module IF_ID(
    Clock,         // Señal de reloj para sincronización
    Enable,        // Señal para habilitar la escritura en los registros
    In_Instruction, // Entrada de la instrucción actual
    Out_Instruction, // Salida de la instrucción almacenada
    In_PCAdder,     // Entrada del valor del PC sumado
    Out_PCAdder,    // Salida del valor del PC sumado almacenado
    Out_PrevPCAdder, // Salida del valor anterior del PC sumado
);

    // Declaración de entradas
    input        Clock, Enable;
    input [31:0] In_Instruction;
    input [31:0] In_PCAdder;
    
    // Declaración de salidas
    output reg [31:0] Out_Instruction;     // Almacena la instrucción
    output reg [31:0] Out_PrevPCAdder;     // Almacena el valor anterior del PC sumado
    output reg [31:0] Out_PCAdder;         // Almacena el valor del PC sumado

    // Inicialización de registros
    initial begin
        Out_Instruction <= 32'b0;  // Inicializa la instrucción almacenada a 0
        Out_PCAdder     <= 32'b0;  // Inicializa el valor del PC sumado almacenado a 0
    end

    // Comportamiento del registro sincronizado con el flanco positivo del reloj
    always @(posedge Clock) begin
         if (Enable) begin
            // Si Enable está activo, actualiza los registros con las entradas
            Out_Instruction = In_Instruction;
            Out_PCAdder     = In_PCAdder;
            Out_PrevPCAdder = In_PCAdder;  // Guarda el valor actual del PC sumado como anterior
        end
    end

endmodule
