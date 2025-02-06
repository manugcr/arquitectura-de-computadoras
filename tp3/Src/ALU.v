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
                     MUL    = 6'd03,      // Multiplicación (MUL)
                     MULT   = 6'd04,      // Multiplicación (MULT)
                     MULTU  = 6'd05,      // Multiplicación sin signo (MULTU)
                     MADD   = 6'd06,      // Multiplicación y acumulación (MADD)
                     MSUB   = 6'd07,      // Multiplicación y resta (MSUB)
                     BGEZ   = 6'd08,      // Rama si >= 0 (BGEZ)
                     BEQ    = 6'd09,      // Rama si es igual (BEQ)
                     BNE    = 6'd10,      // Rama si es distinto (BNE)
                     BGTZ   = 6'd11,      // Rama si > 0 (BGTZ)
                     BLEZ   = 6'd12,      // Rama si <= 0 (BLEZ)
                     BLTZ   = 6'd13,      // Rama si < 0 (BLTZ)
                     JUMP   = 6'd14,      // Salto (J, JAL, JR)
                     SRAV   = 6'd15,      // Desplazamiento aritmético a la derecha variable
                     ROTRV  = 6'd16,      // Rotación a la derecha variable
                     LUI    = 6'd17,      // Cargar inmediato superior
                     AND    = 6'd18,      // Operación AND
                     OR     = 6'd19,      // Operación OR
                     NOR    = 6'd20,      // Operación NOR
                     XOR    = 6'd21,      // Operación XOR
                     SEH    = 6'd22,      // Extensión de signo (16 bits a 32 bits)
                     SLL    = 6'd23,      // Desplazamiento lógico a la izquierda
                     SRL    = 6'd24,      // Desplazamiento lógico a la derecha
                     MOVN   = 6'd25,      // Mover si no es cero
                     MOVZ   = 6'd26,      // Mover si es cero
                     ROTR   = 6'd27,      // Rotación a la derecha
                     SRA    = 6'd28,      // Desplazamiento aritmético a la derecha
                     SEB    = 6'd29,      // Extensión de signo (8 bits a 32 bits)
                     SLT    = 6'd30,      // Comparación menor que (signed)
                     SLTU   = 6'd31,      // Comparación menor que (unsigned)
                     MTHI   = 6'd32,      // Mover a registro Hi
                     MTLO   = 6'd33,      // Mover a registro Lo
                     MFHI   = 6'd34,      // Mover desde registro Hi
                     MFLO   = 6'd35,      // Mover desde registro Lo
                     SLLV   = 6'd36,      // Desplazamiento lógico a la izquierda variable
                     SRLV   = 6'd37,      // Desplazamiento lógico a la derecha variable
                     ABS    = 6'd43,      // Valor absoluto
                     LA     = 6'd44;      // Cargar dirección

    // Inicialización de variables

    initial begin
        ALUResult     <= 32'd0;
        Zero          <= 1'b0;
        RegWriteClear <= 1'b0;
        temp          <= 32'd0;
    end
    
    always @ (*) begin
    
        RegWriteClear = 0;
    
        Zero       <= 0;
        
        case (ALUControl)

         
        
            //------------
            // Arithmetic
            //------------
            
            ADD  : ALUResult <= $signed(A) + $signed(B);     // add
            ADDU : ALUResult <= A + B;                       // add unsigned
            SUB  : ALUResult <= A - B;                       // sub
            MUL  : ALUResult <= A * B;                       // mul
            
            MULT : begin                                    // mult
                ALUResult   <= 0;
            end
            
            MULTU: begin                                    // multu

                ALUResult   <= 0;
            end
            
            MADD : begin                                    // madd
                ALUResult   <= 0;
            end
            
            MSUB : begin                                    // msub
                ALUResult   <= 0;
            end
            

            LUI  : ALUResult <= B << 16;    // lui
            

            AND  : ALUResult <= A & B;                      // and   
            OR   : ALUResult <= A | B;                      // or
            NOR  : ALUResult <= ~(A | B);                   // nor 
            XOR  : ALUResult <= A ^ B;                      // xor
            
            SEH  : begin                                    // seh 
                if (B[15] == 0) ALUResult <= {16'b0, B[15:0]};
                else ALUResult <= {16'hffff, B[15:0]};
            end

            SLL  : ALUResult <= B << Shamt;                             // sll
            SLLV : ALUResult <= B << A;                                 // sllv
            SRL  : ALUResult <= B >> Shamt;                             // srl
            SRLV : ALUResult <= B >> A;                                 // srlv
            ROTR : ALUResult <= ((B >> Shamt) | (B << (32 - Shamt)));   // rotr
            ROTRV: ALUResult <= ((B >> A) | (B << (32 - A)));           // rotrv
            SRA  : ALUResult[31:0] <= $signed(B) >>> Shamt;           // sra   LE AGREGE SIGNADO B SACAR SI NO SIRVE
            SRAV : ALUResult <= B >>> A;                                // srav
            
            MOVN : begin
                if (B != 0) ALUResult <= A;                          // movn
                else begin
                    ALUResult <= 0;
                    RegWriteClear = 1;
                end
            end
            
            MOVZ : begin
                if (B == 0) ALUResult <= A;                          // movz
                else begin
                    ALUResult <= 0;
                    RegWriteClear = 1;
                end
            end
            
            SEB  : begin                                    // seb
                if (B[7] == 0) ALUResult <= {24'b0, B[7:0]};
                else ALUResult <= {24'hFFFFFF, B[7:0]};                     
            end
            
            SLT  : ALUResult <= ($signed(A) < $signed(B));  // slt
            SLTU : ALUResult <= (A < B) ;                   // sltu
            
            MTHI : begin
                ALUResult   <= 0;
            end
            
            MTLO : begin
                ALUResult   <= 0;
            end
            
       
            ABS : ALUResult <= ($signed(A) < 0) ? -A : A;
          
            default: begin
                
                ALUResult  <= 0;
            end
          
            LA : ALUResult <= {8'H0, B[23:00]};

         

        endcase

        
        if (RegWriteClear == 1) begin
            RegWrite_Out  <= 1'b0;
        end
        else 
            RegWrite_Out <= RegWrite;
        
        if (ALUResult == 0) 
            Zero <= 1;

    end

endmodule

