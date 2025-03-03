`timescale 1ns / 1ps



module ALUControl(Funct, ALUOp, ALUControl);
         
    input [5:0] ALUOp;    // ALUOp From the Controller         
    input [5:0] Funct;    // Funct code from the instruction
    
    output reg [5:0] ALUControl;    // Control signal to ALU
    
    // OpCodes From ALU
    localparam [5:0] ALUOP_ZERO    = 6'd00,  // ZERO
                     ALUOP_ADDIU   = 6'd01,  // ADDIU
                     ALUOP_ADDI    = 6'd02,  // ADDI
                     ALUOP_LUI     = 6'd04,  // LUI
                     ALUOP_BEQ     = 6'd06,  // BEQ
                     ALUOP_BNE     = 6'd07,  // BNE
                     ALUOP_JUMP    = 6'd11,  // J, JAL, JR
                     ALUOP_ANDI    = 6'd12,  // ANDI
                     ALUOP_ORI     = 6'd13,  // ORI
                     ALUOP_XORI    = 6'd14,  // XORI
                     ALUOP_SLTI    = 6'd16,  // SLTI
                     ALUOP_SLTIU   = 6'd17,  // SLTIU
                     ALUOP_SRL     = 6'd18,  // SRL
                     ALUOP_SRLV    = 6'd20;  // SRLV
                     
                        
    // Func Codes from Instruction       
    localparam [5:0] FUNC_ADD       =  6'b100000,   // ADD  
                     FUNC_ADDU      =  6'b100001,   // ADDU
                     FUNC_AND       =  6'b100100,   // AND 
                     FUNC_JR        =  6'b001000,   // JR  
                     FUNC_NOR       =  6'b100111,   // NOR 
                     FUNC_OR        =  6'b100101,   // OR 
                     FUNC_SLL       =  6'b000000,   // SLL  
                     FUNC_SLLV      =  6'b000100,   // SLLV 
                     FUNC_SLT       =  6'b101010,   // SLT 
                     FUNC_SLTU      =  6'b101011,   // SLTU    
                     FUNC_SRA       =  6'b000011,   // SRA  
                     FUNC_SRAV      =  6'b000111,   // SRAV 
                     FUNC_SRL       =  6'b000010,   // SRL 
                     FUNC_SRLV      =  6'b000110,   // SRLV 
                     FUNC_SUB       =  6'b100010,   // SUB  
                     FUNC_SUBU      =  6'b100011,   // SUBU    
                     FUNC_XOR       =  6'b100110;   // XOR  
            
                                              
     
    // ALUControl
    localparam [5:0] ADD    = 6'd00,   // ADD, ADDI      
                     ADDU   = 6'd01,   // ADDU, ADDIU     
                     SUB    = 6'd02,   // SUB      
                     BEQ    = 6'd09,   // BEQ  
                     BNE    = 6'd10,   // BNE  
                     JUMP   = 6'd14,   // J, JAL, JR
                     SRAV   = 6'd15,   // SRAV
                     LUI    = 6'd17,   // LUI  
                     AND    = 6'd18,   // AND, ANDI 
                     OR     = 6'd19,   // OR, ORI
                     NOR    = 6'd20,   // NOR
                     XOR    = 6'd21,   // XOR, XORI 
                     SLL    = 6'd23,   // SLL 
                     SRL    = 6'd24,   // SRL 
                     SRA    = 6'd28,   // SRA, SRAV
                     SLT    = 6'd30,   // SLT, SLTI 
                     SLTU   = 6'd31,   // SLTU, SLTIU 
                     SLLV   = 6'd36,   // SLLV
                     SRLV   = 6'd37,   // SRLV
                     SUBU   = 6'd45;      // Resta (SUBU)     


    
    always @(*) begin

        ALUControl =  6'b000000;
        
        case(ALUOp)

            ALUOP_ZERO: begin 
                case(Funct)
                    FUNC_SLL  : ALUControl =  SLL;
                    FUNC_SRA  : ALUControl =  SRA;
                    FUNC_SLLV : ALUControl =  SLLV; 
                    FUNC_SRAV : ALUControl =  SRAV;
                    FUNC_ADD  : ALUControl =  ADD;
                    FUNC_ADDU : ALUControl =  ADDU;
                    FUNC_SUB  : ALUControl =  SUB;
                    FUNC_SUBU : ALUControl =  SUBU;                     
                    FUNC_AND  : ALUControl =  AND;
                    FUNC_OR   : ALUControl =  OR;
                    FUNC_XOR  : ALUControl =  XOR;
                    FUNC_NOR  : ALUControl =  NOR;
                    FUNC_SLT  : ALUControl =  SLT;
                    FUNC_SLTU : ALUControl =  SLTU;
                    default   : ALUControl =  6'd0;
                endcase
            end
            
            ALUOP_ADDIU: ALUControl =  ADDU;
            ALUOP_ADDI : ALUControl =  ADD;
            ALUOP_LUI  : ALUControl =  LUI;
            ALUOP_BEQ  : ALUControl =  BEQ;
            ALUOP_BNE  : ALUControl =  BNE;
            ALUOP_JUMP : ALUControl =  JUMP;           
            ALUOP_ANDI : ALUControl =  AND;
            ALUOP_ORI  : ALUControl =  OR;
            ALUOP_XORI : ALUControl =  XOR;                    
            ALUOP_SLTI : ALUControl =  SLT;
            ALUOP_SLTIU: ALUControl =  SLTU;
            ALUOP_SRL  : ALUControl =  SRL;
            ALUOP_SRLV : ALUControl =  SRLV;
            default    : ALUControl =  6'd0;
            
        endcase
    end
endmodule