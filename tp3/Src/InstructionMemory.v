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

            Branch <= 1'b1;     // Flag que indica que es un branch 

            /* beq  y bne  utilizan
             un desplazamiento de 16 bits (Instruction[15:0]). Este desplazamiento es un valor con signo 
             en complemento a dos, lo que significa que si Instruction[15] es 1, el número es negativo; 
             si es 0, el número es positivo.
             
              ej: 0x00400010 : beq $t0, $t1, target
                  0x00400014 : addi $t2, $zero, 1
                  0x00400018 : j end
                  0x0040001C : target: addi $t2, $zero, 2
                                                                                         signo
               beq $t0, $t1, target  # opcode = 000100, rs = 01000, rt = 01001, offset = (0)000000000000011 
             */

            if (Instruction[15] == 1) 
                TargetOffset <= {16'hFFFF, Instruction[15:0]};  // Desplazamiento con signo
            else  
                TargetOffset <= {16'h0000, Instruction[15:0]};  // Desplazamiento sin signo
            
        end
        else begin
            Branch <= 1'b0;
            TargetOffset <= 32'd0;
        end

        
        
        
        end else begin
            // Si stall es 1, mantener la instrucción actual
            Instruction = Instruction; // No cambiar la instrucción, mantener la actual
        end
    end

endmodule

