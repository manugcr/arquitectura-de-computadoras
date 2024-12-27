`timescale 1ns / 1ps

module InstructionMemory(Address, Instruction );

    // Entradas
    input [31:0] Address; // Dirección de entrada utilizada para acceder a la memoria

    // Salidas
    output reg [31:0] Instruction;   // Instrucción de 32 bits leída desde la memoria
   // output reg [31:0] TargetOffset; // Desplazamiento de 32 bits para instrucciones de salto condicional
   // output reg Branch;              // Señal que indica si la instrucción actual es de salto condicional

    // Memoria de instrucciones de 32 bits, con capacidad para 512 palabras
    reg [31:0] memory [0:512];

    // Bloque inicial para cargar las instrucciones desde un archivo
    initial begin
        $readmemh("Instruction_memory.mem", memory, 0,512); // Carga el contenido desde un archivo hexadecimal
   
        for (integer i = 0; i < 512; i = i + 1) begin
            memory[i] = i; // Asigna el valor i a cada posición de memoria
        ends
        $writememh("Instruction_memory.mem", memory, 0, 511);
    end

    // Bloque always para leer la instrucción y procesar las instrucciones de salto
    always @ * begin
        // Lee la instrucción desde la memoria usando la dirección proporcionada
        Instruction = memory[Address[11:2]]; // Se ignoran los bits menos significativos

    end 

endmodule
