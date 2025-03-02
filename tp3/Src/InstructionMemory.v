`timescale 1ns / 1ps

module InstructionMemory(Address, Instruction ,stall ,TargetOffset, Branch);

    // Entradas
    input [31:0] Address; // Dirección de entrada utilizada para acceder a la memoria

    // Salidas
    output reg [31:0] Instruction;   // Instrucción de 32 bits leída desde la memoria


    output reg [31:0] TargetOffset;
    output reg Branch;

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

                    memory[0] = 4364320;  // add $s1, $t1, $t6
                  memory[1] = 2388918292;  // lw  a0 , 20(s3)
                  memory[2] = 2389835792; //  lw  s2 , 16(s3)
                  memory[3] = 278003740;  // BEQ a0,s2, 00011000
                  memory[4] = 21710880;  // add $t1, $t2, $t3
                  memory[5] = 23875616;  // add $t2, $t3, $t4  Registro 09d  =  9   NO MODIFICADO   SINO   Registro 9d   =  15h NO MODIFICADO
                  memory[6] = 26040352;  // add $t3, $t4, $t5  Registro 11d  =  11  NO MODIFICADO   SINO   Registro 9d   =  15h NO MODIFICADO
                  memory[7] = 28205088;  // add $t4, $t5, $t6  Registro 12d  =  27d = 1Bh
                  memory[8] = 19556384;  // add $t5, $t1, $t2  Registro 13d  =  9 + 10 d = 13h =    SINO   Registro 12d =  15h + 13h = 28 h  */

        $writememh("Instruction_memory.mem", memory, 0, 511);
    end

        // Bloque always para leer la instrucción y procesar las instrucciones de salto
    always @ (*) begin
        if (stall == 1'b0) begin
            // Si stall es 0, leer la instrucción desde la memoria
            Instruction = memory[Address[11:2]]; // Ignora los 2 bits menos significativos de la dirección
        
             // Verificar si la instrucción es de tipo branch
             //                     BEQ                                 BNE
        if (Instruction[31:26] == 6'b000100 || Instruction[31:26] == 6'b000101) begin

            Branch = 1'b1;     // Flag que indica que es un branch 

            if (Instruction[15] == 1) 
                TargetOffset = {16'hFFFF, Instruction[15:0]};  // Desplazamiento con signo
            else  
                TargetOffset = {16'h0000, Instruction[15:0]};  // Desplazamiento sin signo
            
        end
        else begin
            Branch = 1'b0;
            TargetOffset = 32'd0;
        end

        
        
        
        end else begin
            // Si stall es 1, mantener la instrucción actual
            Instruction = Instruction; // No cambiar la instrucción, mantener la actual
        end
    end

endmodule

