`timescale 1ns / 1ps

module InstructionMemory(Address, Instruction ,stall );

    // Entradas
    input [31:0] Address; // Dirección de entrada utilizada para acceder a la memoria

    // Salidas
    output reg [31:0] Instruction;   // Instrucción de 32 bits leída desde la memoria

    // Memoria de instrucciones de 32 bits, con capacidad para 512 palabras
    reg [31:0] memory [0:511]; // Cambiado a 0:511 para evitar indices inválidos

    // Variable para el bucle
    integer i;

    input  stall;

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
            
              memory[2] = 39028768; //Registro 11h (17d) = 25h
              memory[0] = 19546144; //Registro 08h (08d) = 13h
              memory[1] = 10887200; //Registro 04h (04d) = 0bh //*/
              

        /* CASO B: STORE

          sw  $s0 , 14($s1) ->   sw 8, 14(10)   La posición de memoria 0x18 (24d) contendrá el valor 0x08 

          Opcode (6 bits) | Base (5 bits) | Rt (5 bits) | Offset (16 bits)
            101011            10001             10000     0000 0000 0000 1110 = 2922381326

            CODIGO CASO B:
                memory[0] = 2922381326; 


        /* CASO C: LOAD

          lw  $s2 , 16 ($s3) -> lw [18] , 16 [19]
          100011   10011  10010  0000 0000 0001 0000 -> 2389835792


            Cargar un valor de 32 bits (1 palabra) desde la memoria a un registro.

            CODIGO CASO C:
                memory[0] = 2389835792;
        


        /*  CASO D: RIESGO DE DATOS - LDE

        add $s1, $s2, $s3 -> 000000 10010 10011 10001 00000 100000  -> 0x02538820 -> 39028768
        add $a0, $a1, $a2 -> 000000 00101 00110 00100 00000 100000  -> 0x00A62020 -> 10887200
        add $t1, $t2, $t3 -> 000000 01010 01011 01001 00000 100000  -> 0X014B4820 -> 21710880
        add $t4, $t1, $t2 -> 000000 01001 01010 01100 00000 100000  -> 0X012A6020 -> 19554336 
        add $t0, $t1, $t2 -> 000000 01001 01010 01000 00000 100000  -> 0x012A4020 -> 19546144
        add $t0, $t1, $t2 -> 000000 01001 01010 01000 00000 100000  -> 0x012A4020 -> 19546144
        add $t0, $t1, $t2 -> 000000 01001 01010 01000 00000 100000  -> 0x012A4020 -> 19546144
        add $t0, $t1, $t2 -> 000000 01001 01010 01000 00000 100000  -> 0x012A4020 -> 19546144
        add $t1, $t2, $t3 -> 000000 01010 01011 01001 00000 100000  -> 0X014B4820 -> 21710880
        add $t2, $t0, $t3 -> 000000 01000 01011 01010 00000 100000  -> 0x010B5020 -> 17518624
        add $t4, $t1, $t2 -> 000000 01001 01010 01100 00000 100000  -> 0X012A6020 -> 19554336  */



        /*
          CODIGO CASO D:
          memory[0] = 39028768; //Registro 11h (17d) = 25h
          memory[1] = 10887200; //Registro 04h (04d) = 0bh 
          memory[2] = 21710880; // t1 = 20 + 30 = 50d = 32h
          memory[3] = 19554336; // t4 = 50 + 20 = 70d = 46h
          memory[4] = 19546144; //Registro 11h (17d) = 25h
          memory[5] = 19546144; //Registro 08h (08d) = 13h
          memory[6] = 19546144; //Registro 08h (08d) = 13h 
          memory[7] = 19546144;
          memory[8] = 21710880;
          memory[9] = 17518624;
          memory[10] = 17518624;
          memory[11] = 19554336;*/

          /*  CASO E: LOAD USE HAZARD
            CON v0 = 2d
          add s3, v0, v0 -> 0x00439020 -> 000000 00010 00010 10011 00000 100000  -> 4364320     -> s3 = 2d + 2d = 4d
          lw s2, 16(s3)  -> 0x8E520010 -> 10001110011100100000000000010000       -> 2389835792  -> s2 = 10d (16d nivel 5)
          add v1,s2,s3   -> 0x02531820 -> 000000 10010 10011 00011 00000 100000  -> 39000096    -> v1 = 10 + 4 = 14d = Eh
         
      
         
          CODIGO CASO E:
         /*memory[0] = 4364320;  //     add s3,v0,v0
         memory[1] = 2389835792;    //    lw  $s2 , 16 ($s3)
         memory[2] = 39000096 ;     //    add v1,s2,s3*/
  

         /* CASO F: RIESGOS, LOAD Y STORE
          add s3 , v0 , v0    -> 0x00429820 -> 00000000010000101001100000100000 -> 4364320     -> s3 = 2d + 2d = 4d
          lw  s2 , 16(s3)     -> 0x8E520010 -> 10001110011100100000000000010000 -> 2389835792  -> s2 = 10d (16d nivel 5)
          sw  s3 , 14(s2)     -> 0xAE53000E -> 10101110010100110000000000001110 -> 2924675086  -> nivel 6 = 4d 
          lw  $t1 , 16($t0)   -> 0x8D090010 -> 10001101000010010000000000010000 -> 2366177296  -> t1 = 8d 
          add $v0 , $s3 , $s2 -> 0x02721020 -> 00000010011100100001000000100000 -> 41029664    -> v0 = 14d
          add $t2 , $t1 , $v0 -> 0x1225020  -> 00000001001000100101000000100000 -> 19025952    -> t2 = 22d = 16h*/

          /* CODIGO CASO F:*/

        /*  memory[0] = 4364320;      //  add s3 , v0 , v0
          memory[1] = 2389835792;   //  lw  s2 , 16(s3)
          memory[2] = 2924675086 ;  //  sw  s3 , 14(s2) 
          memory[3] = 2366177296 ;  //  lw  $t1 , 16($t0)
          memory[4] = 41029664 ;    //  add $v0 , $s3 , $s2
          memory[5] = 19025952 ;  //  add $t2 , $t1 , $v0*/

          /////////// AVANCE III: JUMPS & BRANCH

          /*  CASO G: J
          
            PC                  |   Instrucción   
            00000000   (00)         add $s1, $s2, $s3 -> 000000 10010 10011 10001 00000 100000  -> 0x02538820 -> 39028768
            00000100   (04)         add $a0, $a1, $a2 -> 000000 00101 00110 00100 00000 100000  -> 0x00A62020 -> 10887200
            00001000   (08)         j 00011000        -> 000010 00000 00000 00000 00000 000110  -> 0x08000006 -> 134217734
            00001100   (12)         add $t1, $t2, $t3 -> 000000 01010 01011 01001 00000 100000  -> 0X014B4820 -> 21710880
            00010000   (16)         add $t2, $t3, $t4 -> 000000 01011 01100 01010 00000 100000  -> 0X016C5020 -> 23875616 
            00010100   (20)         add $t3, $t4, $t5 -> 000000 01100 01101 01011 00000 100000  -> 0X018D5820 -> 26040352
            00011000   (24)         add $t4, $t5, $t6 -> 000000 01101 01110 01100 00000 100000  -> 0x01AE6020 -> 28205088
            00100000   (28)         add $t5, $t1, $t2 -> 000000 01001 01010 01101 00000 100000  -> 0X012A6820 -> 19556384 
           */

          memory[0] = 39028768;  // Registro 11h (17d) = 25h
          memory[1] = 10887200;  // Registro 04h (04d) = 0bh 
          memory[2] = 134217734; // SALTO A instruccion memory[6]
          memory[3] = 21710880;  // Registro 09d  =  9   NO MODIFICADO   SINO   Registro 9d   =  15h NO MODIFICADO
          memory[4] = 23875616;  // Registro 10d  =  10  NO MODIFICADO  SINO   Registro 12d  =  15h + ah = 1F NO MODIFICADO
          memory[5] = 26040352;  // Registro 11d  =  11  NO MODIFICADO   SINO   Registro 9d   =  15h NO MODIFICADO
          memory[6] = 28205088;  // Registro 12d  =  27d = 1Bh
          memory[7] = 19556384;  // Registro 13d  =  9 + 10 d = 13h =    SINO   Registro 12d =  15h + 13h = 28 h 

        

   



        $writememh("Instruction_memory.mem", memory, 0, 511);
    end

    // Bloque always para leer la instrucción y procesar las instrucciones de salto
    always @ (*) begin
        if (stall == 1'b0) begin
            // Si stall es 0, leer la instrucción desde la memoria
            Instruction = memory[Address[11:2]]; // Ignora los 2 bits menos significativos de la dirección
        end else begin
            // Si stall es 1, mantener la instrucción actual
            Instruction = Instruction; // No cambiar la instrucción, mantener la actual
        end
    end

endmodule
