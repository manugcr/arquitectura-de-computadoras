`timescale 1ns / 1ps

module Controller(
    Instruction,
    ALUBMux, RegDst, ALUOp, MemRead, ByteSig, RegWrite, MemToReg
);

    input [31:0] Instruction;  // Instrucción de 32 bits que se decodifica para determinar las señales de control.

    
    output reg       ALUBMux;       // Selección del multiplexor para el segundo operando de la ALU.
    output reg [1:0] RegDst;        // Selección del destino del registro para escritura.
    output reg [5:0] ALUOp;         // Código de operación para la ALU.

    // Memory (Señales para la etapa de acceso a memoria).
    output reg MemRead;             // Señal para habilitar lectura de memoria.
    output reg [1:0] ByteSig;       // Indica el tamaño de los datos a transferir (byte, half-word, word).

    // Write Back (Señales para la etapa de escritura en el pipeline).
    output reg       RegWrite;      // Habilita la escritura en el registro de destino.
    output reg [1:0] MemToReg;      // Selección del origen de los datos para escribir en el registro (memoria o ALU).


    
    localparam [5:0] OP_ZERO        = 6'b000000,   // Zero OpCode
                     OP_BGEZBLTZ    = 6'b000001,   // BGEZ, BLTZ
                     OP_J           = 6'b000010,   // J
                     OP_JAL         = 6'b000011,   // JAL
                     OP_BEQ         = 6'b000100,   // BEQ
                     OP_BNE         = 6'b000101,   // BNE
                     OP_BLEZ        = 6'b000110,   // BLEZ 
                     OP_BGTZ        = 6'b000111,   // BGTZ 
                     OP_ADDI        = 6'b001000,   // ADDI
                     OP_ADDIU       = 6'b001001,   // ADDIU
                     OP_SLTI        = 6'b001010,   // SLTI
                     OP_SLTIU       = 6'b001011,   // SLTUI
                     OP_ANDI        = 6'b001100,   // ANDI
                     OP_ORI         = 6'b001101,   // ORI
                     OP_XORI        = 6'b001110,   // XORI
                     OP_LUI         = 6'b001111,   // LUI
                     OP_MADD        = 6'b011100,   // MADD, MSUB, MUL
                     OP_SEBSEH      = 6'b011111,   // SEB, SEH
                     OP_LB          = 6'b100000,   // LB
                     OP_LH          = 6'b100001,   // LH
                     OP_LW          = 6'b100011,   // LW
                     OP_SB          = 6'b101000,   // SB
                     OP_SH          = 6'b101001,   // SH
                     OP_SW          = 6'b101011,   // SW
                     OP_EXI         = 6'b011001,   // EH, IH, DH, EB, IB
                     OP_LA          = 6'b011101;   // LA
    
    localparam [5:0] FUNC_JR        =  6'b001000,  // JR  
                     FUNC_ROTR      =  6'b000010,  // ROTR
                     FUNC_ROTRV     =  6'b000110,  // ROTRV
                     FUNC_SLL       =  6'b000000,  // SLL
                     FUNC_SRL       =  6'b000010,  // SRL 
                     FUNC_SRLV      =  6'b000110,  // SRLV 
                     FUNC_SRAV      =  6'b000111;  // SRAV 

   localparam [5:0] 
    ALUOP_ZERO     = 6'b000000,  // ZERO
    ALUOP_ADDIU    = 6'b000001,  // ADDIU
    ALUOP_ADDI     = 6'b000010,  // ADDI
    ALUOP_MUL      = 6'b000011,  // MUL, MADD, MSUB
    ALUOP_LUI      = 6'b000100,  // LUI
    ALUOP_BLTZ     = 6'b000101,  // BLTZ
    ALUOP_BEQ      = 6'b000110,  // BEQ
    ALUOP_BNE      = 6'b000111,  // BNE
    ALUOP_BGTZ     = 6'b001000,  // BGTZ
    ALUOP_BLEZ     = 6'b001001,  // BLEZ
    ALUOP_BGEZ     = 6'b001010,  // BGEZ
    ALUOP_JUMP     = 6'b001011,  // J, JR, JAL
    ALUOP_ANDI     = 6'b001100,  // ANDI
    ALUOP_ORI      = 6'b001101,  // ORI
    ALUOP_XORI     = 6'b001110,  // XORI
    ALUOP_SEB      = 6'b001111,  // SEB
    ALUOP_SLTI     = 6'b010000,  // SLTI
    ALUOP_SLTIU    = 6'b010001,  // SLTIU
    ALUOP_SRL      = 6'b010010,  // SRL
    ALUOP_ROTR     = 6'b010011,  // ROTR
    ALUOP_SRLV     = 6'b010100,  // SRLV
    ALUOP_SEH      = 6'b010101,  // SEH
    ALUOP_ROTRV    = 6'b010110,  // ROTRV
    ALUOP_EXI      = 6'b010111,  // EH, IH, DH, EB, IB
    ALUOP_LA       = 6'b011000;  // LA

              

     reg Bit21, Bit16, Bit6; 
    // Bits específicos de la instrucción para decodificación.

    reg [5:0] Func; 
    // Código de función para instrucciones R-Type.

    reg [5:0] Shamt; 
    // Shift amount (desplazamiento).

    reg [5:0] OpCode; 
    // Código de operación extraído de la instrucción.

    //--------------------------------
    // Controller Logic
    //--------------------------------

    initial begin
        
        //ControlSignal <= 32'b0;
        ALUBMux     <= 1'b0;
        RegDst      <= 2'b00;
        ALUOp       <= 6'b000000;
        RegWrite    <= 1'b0;
    end
    
    always @(*) begin
        Func   <= Instruction[5:0];
        Shamt  <= Instruction[10:6];
        Bit6   <= Instruction[6];
        Bit16  <= Instruction[16];
        Bit21  <= Instruction[21];
        OpCode <= Instruction[31:26];
        // NOP
        if (Instruction == 32'b0) begin
            ALUBMux     <= 1'b0;
            RegDst      <= 2'b00;
            ALUOp       <= ALUOP_ZERO;
            RegWrite    <= 1'b0;
        end
        else begin
            case(OpCode)
                OP_ZERO: begin
                    ALUBMux     <= 1'b0;
                    if (Func == FUNC_JR) begin    // jr
                        RegWrite    <= 1'b0;
                        RegDst      <= 2'b00;
                        ALUOp       <= ALUOP_JUMP;  
                    end
                
                    else begin
                        RegWrite    <= 1'b1;
                        RegDst      <= 2'b01;
                        ALUOp       <= ALUOP_ZERO;  
                        if (Func == FUNC_SRL && ~Bit21) begin   // srl
                            ALUOp <= ALUOP_SRL;  
                            ALUBMux <= 1'b0;
                        end
                        else if (Func == FUNC_SLL) ALUBMux <= 1'b0;
                        else if (Func == FUNC_ROTR  &&  Bit21) ALUOp <= ALUOP_ROTR;  // rotr
                        else if (Func == FUNC_SRLV  && ~Bit6)  ALUOp <= ALUOP_SRLV;  // srlv
                        else if (Func == FUNC_ROTRV &&  Bit6)  ALUOp <= ALUOP_ROTRV; // rotrv
                        else ALUOp <= ALUOP_ZERO;
                    end

                end
                
                //addiu
                OP_ADDIU: begin
                    ALUBMux     <= 1'b1;
                    RegDst      <= 2'b00;
                    ALUOp       <= ALUOP_ADDIU;
                    RegWrite    <= 1'b1;  
                end
                
                //addi
                OP_ADDI: begin
                    ALUBMux     <= 1'b1;
                    RegDst      <= 2'b00;
                    ALUOp       <= ALUOP_ADDI;
                    RegWrite    <= 1'b1;
                end
                
                //mul, madd, msub
                OP_MADD: begin
                    ALUBMux     <= 1'b0;
                    RegDst      <= 2'b01;
                    ALUOp       <= ALUOP_MUL;
                    RegWrite    <= 1'b1;  
                end 
                
                //lw
                OP_LW: begin
                    ALUBMux     <= 1'b1;
                    RegDst      <= 2'b00;
                    ALUOp       <= ALUOP_ADDI;
                    RegWrite    <= 1'b1;              
                end
                
                //sw
                OP_SW: begin                 
                    ALUBMux     <= 1'b1;
                    RegDst      <= 2'b00;
                    ALUOp       <= ALUOP_ADDI;
                    RegWrite    <= 1'b0;
   
                end
                
                //sb
                OP_SB: begin                  
                    ALUBMux     <= 1'b1;
                    RegDst      <= 2'b00;
                    ALUOp       <= ALUOP_ADDI;
                    RegWrite    <= 1'b0;
                    
                    
                end
                
                //lh
                OP_LH: begin
                    ALUBMux     <= 1'b1;
                    RegDst      <= 2'b00;
                    ALUOp       <= ALUOP_ADDI;
                    RegWrite    <= 1'b1;
                      
                          
                end
                
                //lb
                OP_LB: begin
                    ALUBMux     <= 1'b1;
                    RegDst      <= 2'b00;
                    ALUOp       <= ALUOP_ADDI;
                    RegWrite    <= 1'b1;
                    
                    
                end
                
                //sh
                OP_SH: begin
                    ALUBMux     <= 1'b1;
                    RegDst      <= 2'b00;
                    ALUOp       <= ALUOP_ADDI;
                    RegWrite    <= 1'b0;
                    
                    
                end
                
                //lui
                OP_LUI: begin     
                    ALUBMux     <= 1'b1;
                    RegDst      <= 2'b00;
                    ALUOp       <= ALUOP_LUI;
                    RegWrite    <= 1'b1;
                    
                    
                end
                
                OP_BGEZBLTZ: begin
                    ALUBMux     <= 1'b0;
                    RegDst      <= 2'b00;
                    RegWrite    <= 1'b0;
                    case (Bit16)
                        1'b0: begin
                            ALUOp       <= ALUOP_BLTZ;
                            
                        end
                        1'b1: begin
                            ALUOp       <= ALUOP_BGEZ;
                            
                        end
                    endcase
                end
                //beq
                OP_BEQ: begin
                    
                    ALUBMux     <= 1'b0;
                    RegDst      <= 2'b00;
                    ALUOp       <= ALUOP_BEQ;
                    RegWrite    <= 1'b0;
                end
                //bne
                OP_BNE: begin
                    
                    ALUBMux     <= 1'b0;
                    RegDst      <= 2'b00;
                    ALUOp       <= ALUOP_BNE;
                    RegWrite    <= 1'b0;
                end
                //bgtz
                OP_BGTZ: begin
                    
                    ALUBMux     <= 1'b0;
                    RegDst      <= 2'b00;
                    ALUOp       <= ALUOP_BGTZ;
                    RegWrite    <= 1'b0;
                end
                //blez
                OP_BLEZ: begin
                    
                    ALUBMux     <= 1'b0;
                    RegDst      <= 2'b00;
                    ALUOp       <= ALUOP_BLEZ;
                    RegWrite    <= 1'b0;
                end
                // j
                OP_J: begin
                    ALUBMux     <= 1'b0;
                    RegDst      <= 2'b00;
                    ALUOp       <= ALUOP_JUMP;
                    RegWrite    <= 1'b0;
                end
                // jal
                OP_JAL: begin
                    ALUBMux     <= 1'b0;
                    RegDst      <= 2'b10;
                    ALUOp       <= ALUOP_JUMP;
                    RegWrite    <= 1'b1;
                end
                //------------
                // Logical
                //------------
                //andi
                OP_ANDI: begin
                    ALUBMux     <= 1'b1;
                    RegDst      <= 2'b00;
                    ALUOp       <= ALUOP_ANDI;
                    RegWrite    <= 1'b1;
                end
                //ori
                OP_ORI: begin
                    ALUBMux     <= 1'b1;
                    RegDst      <= 2'b00;
                    ALUOp       <= ALUOP_ORI;
                    RegWrite    <= 1'b1;
                end
                //xori
                OP_XORI: begin
                    ALUBMux     <= 1'b1;
                    RegDst      <= 2'b00;
                    ALUOp       <= ALUOP_XORI;
                    RegWrite    <= 1'b1;
                end
                //seh, seb
                OP_SEBSEH: begin
                    ALUBMux     <= 1'b0;
                    RegDst      <= 2'b01;
                    RegWrite    <= 1'b1;
                    case (Shamt)
                        5'b10000: ALUOp <= ALUOP_SEB; //seb
                        5'b11000: ALUOp <= ALUOP_SEH; //seh
                    endcase
                end
                //slti
                OP_SLTI: begin
                    ALUBMux     <= 1'b1;
                    RegDst      <= 2'b00;
                    ALUOp       <= ALUOP_SLTI;
                    RegWrite    <= 1'b1;
                end
                //sltiu
                OP_SLTIU: begin
                    ALUBMux     <= 1'b1;
                    RegDst      <= 2'b00;
                    ALUOp       <= ALUOP_SLTIU;
                    RegWrite    <= 1'b1;
                end
                // EH, IH, DH, EB, IB, ABS
                OP_EXI: begin
                    ALUBMux     <= 1'b1;
                    RegDst      <= 2'b00;
                    ALUOp       <= ALUOP_EXI;
                    RegWrite    <= 1'b1;
                end
                // LA
                OP_LA: begin
                    ALUBMux     <= 1'b1;
                    RegDst      <= 2'b00;
                    ALUOp       <= ALUOP_LA;
                    RegWrite    <= 1'b1;
                end
                default: begin
                    ALUBMux     <= 1'b0;
                    RegDst      <= 2'b00;
                    ALUOp       <= ALUOP_ZERO;
                    RegWrite    <= 1'b0;
                end
                endcase
  end
  end

endmodule 
