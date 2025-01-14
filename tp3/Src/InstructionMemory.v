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
       // for (i = 0; i < 512; i = i + 1) begin
        //    memory[i] = 2919759884;// Asigna el valor i a cada posición de memoria
       // end

        /*  CASO A 
        add $t0, $t1, $t2 # 000000 01001 01010 01000 00000 100000  -> 0x012A4020 -> 19546144, Registro 08h (08d) = 13h
        add $s1, $s2, $s3 # 000000 10010 10011 10001 00000 100000  -> 0x2538820  -> 39028768, Registro 11h (17d) = 25h
        add $a0, $a1, $a2 # 000000 00101 00110 00100 00000 100000  -> 0xA62020   -> 10887200, Registro 04h (04d) = 0bh
        */
     
        /*
          memory[0] = 19546144; //Registro 08h (08d) = 13h
          memory[1] = 39028768; //Registro 11h (17d) = 25h
          memory[2] = 10887200; //Registro 04h (04d) = 0bh */

        /* CASO B

          sw $t0, 4($s1) =>  sw $8, 0($17) 

          Opcode (6 bits) | Base (5 bits) | Rt (5 bits) | Offset (16 bits)
            101011            10001             01000      0000 0000 0000 0100 = 2921857028

            La posición de memoria 0x15 (21d) contendrá el valor 0x08 
        */
        
          memory[0] = 2921857028; 


        $writememh("Instruction_memory.mem", memory, 0, 511);
    end

    // Bloque always para leer la instrucción y procesar las instrucciones de salto
    always @ * begin
        // Lee la instrucción desde la memoria usando la dirección proporcionada
        Instruction = memory[Address[11:2]]; // Se ignoran los bits menos significativos
    end 

endmodule
