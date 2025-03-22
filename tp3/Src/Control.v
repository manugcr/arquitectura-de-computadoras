`timescale 1ns / 1ps

module Control(Instruction,
                  ALUBMux, RegDst, ALUOp, MemWrite,JumpMuxSel, MemRead, ByteSig, RegWrite, MemToReg, 
                  BranchComp, LaMux);
    
          
    input [31:0] Instruction;
    

 //   output reg       Flush_IF;
    output reg [2:0] BranchComp;
    output reg       JumpMuxSel;
    output reg       ALUBMux, LaMux;
    output reg [1:0] RegDst;
    output reg [5:0] ALUOp;
    output reg       MemWrite, MemRead;
    output reg [1:0] ByteSig;   
    output reg       RegWrite;
    output reg [1:0] MemToReg;
    
    
    localparam [5:0] OP_ZERO        = 6'b000000,   // 
                     OP_J           = 6'b000010,   // J
                     OP_JAL         = 6'b000011,   // JAL
                     OP_LW          = 6'b100011,   // LW
                     OP_SW          = 6'b101011,   // SW
                     OP_ADDI        = 6'b001000,   // ADDI
                     OP_ADDIU       = 6'b001001,   // ADDIU
                     OP_LHU         = 6'b100101,                    
                     OP_LBU         = 6'b100100,                    
                     OP_LWU         = 6'b100111,                    
                     OP_BEQ         = 6'b000100,   // BEQ
                     OP_BNE         = 6'b000101,   // BNE
                     OP_SB          = 6'b101000,   // SB
                     OP_SH          = 6'b101001,   // SH
                     OP_ORI         = 6'b001101,   // ORI
                     OP_XORI        = 6'b001110,   // XORI
                     OP_LUI         = 6'b001111,   // LUI
                     OP_LB          = 6'b100000,   // LB
                     OP_LH          = 6'b100001,   // LH
                     OP_ANDI        = 6'b001100,   // ANDI
                     OP_SLTI        = 6'b001010,   // SLTI
                     OP_SLTIU       = 6'b001011;   // SLTUI
    
    localparam [5:0] FUNC_JR        =  6'b001000,  // JR 
                     FUNC_JALR      =  6'b001001,  // JALR      
                     FUNC_SLL       =  6'b000000,  // SLL
                     FUNC_SRL       =  6'b000010,  // SRL 
                     FUNC_SRLV      =  6'b000110,  // SRLV 
                     FUNC_SRA       =  6'b000011,  //SRA
                     FUNC_SRAV      =  6'b000111,  // SRAV 
                     FUNC_SLLV      =  6'b000100;  // SLLV         //////////// VER

    localparam [5:0] ALUOP_ZERO     = 6'b000000, // ZERO
                     ALUOP_ADDIU    = 6'b000001, // ADDIU
                     ALUOP_ADDI     = 6'b000010, // ADDI
                     ALUOP_LUI      = 6'b000100, // LUI
                     ALUOP_BEQ      = 6'b000110,       // BEQ
                     ALUOP_BNE      = 6'b000111,       // BNE
                     ALUOP_ANDI     = 6'b001100, // ANDI
                     ALUOP_ORI      = 6'b001101, // ORI
                     ALUOP_JUMP     = 6'b001011, // J, JR, JAL
                     ALUOP_XORI     = 6'b001110, // XORI
                     ALUOP_XOR      = 6'b100110,  // XOR AGREGADOOOOOOOOOOO
                     ALUOP_SLTI     = 6'b010000, // SLTI
                     ALUOP_SLTIU    = 6'b010001, // SLTIU
                     ALUOP_SRL      = 6'b010010, // SRL
                     ALUOP_SRLV     = 6'b010100; // SRLV
           
    localparam [2:0] BRANCH_BEQ  = 3'd1,
                     BRANCH_BNE  = 3'd2;     
      

    reg Bit21, Bit16, Bit6;
    reg [5:0] Func, Shamt, OpCode;

    //--------------------------------
    // Controller Logic
    //--------------------------------

    //ControlSignal = 32'b0 -> inicial
    
    always @(*) begin
   
     //   Flush_IF    = 1'b0;
        Func   = Instruction[5:0];
        Shamt  = Instruction[10:6];
        Bit6   = Instruction[6];
        Bit16  = Instruction[16];
        Bit21  = Instruction[21];
        OpCode = Instruction[31:26];

    

            //valores por defecto o NOP
            JumpMuxSel  = 1'b0; 
            ALUBMux     = 1'b0;
            BranchComp  = 3'b0;
            RegDst      = 2'b00;
            ALUOp       = ALUOP_ZERO;
            ByteSig     = 2'b00;
            MemWrite    = 1'b0;
            MemRead     = 1'b0;
            RegWrite    = 1'b0;
            MemToReg    = 2'b00;
            LaMux       = 1'b0;

            case(OpCode)
            

                OP_J, OP_JAL: begin
                        ALUOp       = ALUOP_JUMP;
                        if (OpCode == OP_JAL) begin
                            RegDst   = 2'b10;
                            RegWrite = 1'b1;
                            MemToReg = 2'b01;
                        end
                            end

                  OP_BEQ, OP_BNE: begin
                        BranchComp = (OpCode == OP_BEQ) ? BRANCH_BEQ : BRANCH_BNE;
                        ALUOp      = (OpCode == OP_BEQ) ? ALUOP_BEQ : ALUOP_BNE;
                    end 


                OP_ZERO: begin
            if (Func == FUNC_JR || Func == FUNC_JALR) begin
                JumpMuxSel  = 1'b1;
                RegWrite    = (Func == FUNC_JALR);
                RegDst      = (Func == FUNC_JALR) ? 2'b01 : 2'b00;
                MemToReg    = (Func == FUNC_JALR) ? 2'b01 : 2'b00;
                ALUOp       = ALUOP_JUMP;
            end else begin
                RegWrite = 1'b1;
                RegDst   = 2'b01;
                MemToReg = 2'b10;
                ALUOp    = (Func == FUNC_SRL && ~Bit21) ? ALUOP_SRL :
                           (Func == FUNC_SRLV && ~Bit6) ? ALUOP_SRLV : ALUOP_ZERO;
            end
        end
                
                OP_ADDIU, OP_ADDI: begin
                        ALUBMux  = 1'b1;
                        RegWrite = 1'b1;
                        MemToReg = 2'b10;
                        ALUOp    = (OpCode == OP_ADDIU) ? ALUOP_ADDIU : ALUOP_ADDI;
                    end
                

               OP_LW, OP_LHU, OP_LBU, OP_LWU, OP_LH, OP_LB: begin
                    ALUBMux  = 1'b1;
                    MemRead  = 1'b1;
                    RegWrite = 1'b1;
                    ByteSig  = (OpCode == OP_LHU || OpCode == OP_LH) ? 2'b01 :
                            (OpCode == OP_LBU || OpCode == OP_LB) ? 2'b10 : 2'b00;
                    ALUOp    = ALUOP_ADDI;
                end
                
                
                OP_SW, OP_SB, OP_SH: begin
                    ALUBMux  = 1'b1;
                    MemWrite = 1'b1;
                    ByteSig  = (OpCode == OP_SH) ? 2'b01 : (OpCode == OP_SB) ? 2'b10 : 2'b00;
                    ALUOp    = ALUOP_ADDI;
                end
                
                 OP_LUI: begin
                    ALUBMux  = 1'b1;
                    RegWrite = 1'b1;
                    MemToReg = 2'b10;
                    ALUOp    = ALUOP_LUI;
                end


                //------------
                // Logical
                //------------
               
               OP_ANDI, OP_ORI, OP_XORI: begin
                ALUBMux  = 1'b1;
                RegWrite = 1'b1;
                MemToReg = 2'b10;
                ALUOp    = (OpCode == OP_ANDI) ? ALUOP_ANDI :
                        (OpCode == OP_ORI) ? ALUOP_ORI :
                        ALUOP_XORI;
            end
                
             
                
                 OP_SLTI, OP_SLTIU: begin
                ALUBMux  = 1'b1;
                RegWrite = 1'b1;
                MemToReg = 2'b10;
                ALUOp    = (OpCode == OP_SLTI) ? ALUOP_SLTI : ALUOP_SLTIU;
            end
                
            

                default: ; // Mantiene valores por defecto
                
            endcase
            
        end


            
endmodule