`timescale 1ns / 1ps

module InstructionMemory(Address, Instruction );

    // Entradas
    input [31:0] Address; // Dirección de entrada utilizada para acceder a la memoria

    // Salidas
    output reg [31:0] Instruction;   // Instrucción de 32 bits leída desde la memoria

    // Memoria de instrucciones de 32 bits, con capacidad para 512 palabras
    reg [31:0] memory [0:511]; // Cambiado a 0:511 para evitar indices inválidos

    // Variable para el bucle
    integer i;

    // Bloque inicial para cargar las instrucciones desde un archivo
    initial begin
        $readmemh("Instruction_memory.mem", memory, 0, 511); // Carga el contenido desde un archivo hexadecimal

        // Inicializa la memoria
        for (i = 0; i < 512; i = i + 1) begin
            memory[i] = 0;// Asigna el valor i a cada posición de memoria
        end
     
         memory[0] = 21710880;
        $writememh("Instruction_memory.mem", memory, 0, 511);
    end

    // Bloque always para leer la instrucción y procesar las instrucciones de salto
    always @ * begin
        // Lee la instrucción desde la memoria usando la dirección proporcionada
        Instruction = memory[Address[11:2]]; // Se ignoran los bits menos significativos
    end 

endmodule
