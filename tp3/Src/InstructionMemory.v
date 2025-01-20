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

        /*  CASO A: Sin riesgos, multiples instrucciones
        add $t0, $t1, $t2 # 000000 01001 01010 01000 00000 100000  -> 0x012A4020 -> 19546144, Registro 08h (08d) = 13h
        add $s1, $s2, $s3 # 000000 10010 10011 10001 00000 100000  -> 0x2538820  -> 39028768, Registro 11h (17d) = 25h
        add $a0, $a1, $a2 # 000000 00101 00110 00100 00000 100000  -> 0xA62020   -> 10887200, Registro 04h (04d) = 0bh

        CODIGO CASO A:
              memory[0] = 19546144; //Registro 08h (08d) = 13h
              memory[1] = 39028768; //Registro 11h (17d) = 25h
              memory[2] = 10887200; //Registro 04h (04d) = 0bh 

        /* CASO B: STORE

          sw  $s0 , 14($s1) ->   sw 8, 14(10)   La posición de memoria 0x18 (24d) contendrá el valor 0x08 

          Opcode (6 bits) | Base (5 bits) | Rt (5 bits) | Offset (16 bits)
            101011            10001             10000     0000 0000 0000 1110 = 2922381326

            CODIGO CASO B:
                memory[0] = 2922381326; */


        /* CASO C: LOAD

          lw  $s2 , 16 ($s3) -> lw [18] , 16 [19]
          100011   10011  10010  0000 0000 0001 0000 -> 2389835792


            Cargar un valor de 32 bits (1 palabra) desde la memoria a un registro.

            CODIGO CASO C:
                memory[0] = 2389835792;
        */


        /*  CASO D: RIESGO DE DATOS - LDE

        ADD $t1, $t2, $t3 -> 000000 01010 01011 01001 00000 100000 -> 0X14B4820
        ADD $t4, $t1, $t2 -> 000000 01001 01010 01100 00000 100000 -> 0X12A6020


        */
        
          
          memory[0] = 21710880; // t1 = 20 + 30 = 50d = 32h
          memory[1] = 19554336; // t4 = 50 + 20 = 70d = 46h*/
   
       

   






        $writememh("Instruction_memory.mem", memory, 0, 511);
    end

    // Bloque always para leer la instrucción y procesar las instrucciones de salto
    always @ * begin
        // Lee la instrucción desde la memoria usando la dirección proporcionada
        Instruction = memory[Address[11:2]]; // Se ignoran los bits menos significativos
    end 

endmodule
