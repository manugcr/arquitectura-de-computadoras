`timescale 1ns / 1ps

/*
 'ALUResult' genera el resultado correspondiente según las entradas de 32 bits, 'A' y 'B'.
 La bandera 'ZERO' se activa cuando 'ALUResult' es igual a '0'.
 La señal 'ALUControl' determina la función de la ALU. La cantidad de bits de
 'ALUControl' depende del número de operaciones necesarias para soportar. */


module ALU(ALUControl, A, B, Shamt, ALUResult, Zero, RegWrite, RegWrite_Out);

    // Definición de entradas
    input        RegWrite;                // Señal de escritura en registro
    input [5:0]  ALUControl;              // Bits de control para las operaciones de la ALU
    input [4:0]  Shamt;                   // Cantidad de desplazamiento

    input [31:0] A, B;                    // Entradas de datos A y B
    output reg [31:0] ALUResult;          // Resultado de la ALU
    output reg Zero;                      // Bandera que indica si el resultado es cero
    output reg RegWrite_Out;              // Salida de escritura en registro
    
    // Variables internas
    reg RegWriteClear;                    // Bandera para limpiar escritura
    reg [31:0] temp;                      // Registro temporal

    // Definición de operaciones mediante constantes locales
    localparam [5:0] ADD    = 6'd00,      // Suma (ADD, ADDI)
                     ADDU   = 6'd01,      // Suma sin signo (ADDU, ADDIU)
                     SUB    = 6'd02,      // Resta (SUB)
                     BEQ    = 6'd09,      // Rama si es igual (BEQ)
                     BNE    = 6'd10,      // Rama si es distinto (BNE)
                     JUMP   = 6'd14,      // Salto (J, JAL, JR)
                     SRAV   = 6'd15,      // Desplazamiento aritmético a la derecha variable
                     LUI    = 6'd17,      // Cargar inmediato superior
                     AND    = 6'd18,      // Operación AND
                     OR     = 6'd19,      // Operación OR
                     NOR    = 6'd20,      // Operación NOR
                     XOR    = 6'd21,      // Operación XOR
                     SLL    = 6'd23,      // Desplazamiento lógico a la izquierda
                     SRL    = 6'd24,      // Desplazamiento lógico a la derecha
                     SRA    = 6'd28,      // Desplazamiento aritmético a la derecha
                     SLT    = 6'd30,      // Comparación menor que (signed)
                     SLTU   = 6'd31,      // Comparación menor que (unsigned)
                     SLLV   = 6'd36,      // Desplazamiento lógico a la izquierda variable
                     SRLV   = 6'd37,      // Desplazamiento lógico a la derecha variable
                     SUBU   = 6'd45;      // Resta (SUBU)

    // Inicialización de variables

    initial begin
        ALUResult     =  32'd0;
        Zero          =  1'b0;
        RegWriteClear =  1'b0;
        temp          =  32'd0;
    end
    
    always @ (*) begin
    
        RegWriteClear = 0;
    
        Zero       =  0;
        
        case (ALUControl)
            ADD  : ALUResult =  $signed(A) + $signed(B);            // add
            ADDU : ALUResult =  A + B;                              // add unsigned
            SUB  : ALUResult =  $signed(A) - $signed(B);            // sub
            SUBU : ALUResult =  A - B;                              // subU      
            LUI  : ALUResult =  B << 16;                            // lui
            AND  : ALUResult =  A & B;                              // and   
            OR   : ALUResult =  A | B;                              // or
            NOR  : ALUResult =  ~(A | B);                           // nor 
            XOR  : ALUResult =  A ^ B;                              // xor
            SLL  : ALUResult =  B << Shamt;                         // sll
            SLLV : ALUResult =  B << A;                             // sllv
            SRL  : ALUResult =  B >> Shamt;                         // srl
            SRLV : ALUResult =  B >> A;                             // srlv
            SRA  : ALUResult[31:0] =  $signed(B) >>> Shamt;         // sra   
            SRAV : ALUResult =  $signed(B) >>> A;                   // srav
            SLT  : ALUResult =  ($signed(A) < $signed(B));          // slt
            SLTU : ALUResult =  (A < B) ;                           // sltu
            
            default: begin
                ALUResult  =  0;
            end

        endcase

        
        if (RegWriteClear == 1) begin
            RegWrite_Out  =  1'b0;
        end
        else 
            RegWrite_Out =  RegWrite;
        
        if (ALUResult == 0) 
            Zero =  1;

    end

endmodule