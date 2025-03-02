`timescale 1ns / 1ps

module Control(Instruction,
                  ALUBMux, RegDst, ALUOp, MemWrite,JumpMuxSel, JumpControl, MemRead, ByteSig, RegWrite, MemToReg, 
                  Flush_IF,BranchComp, LaMux);
    
          
    input [31:0] Instruction;
    

    output reg       Flush_IF;
    output reg [2:0] BranchComp;
    output reg       JumpMuxSel, JumpControl;
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

    initial begin
        
        //ControlSignal = 32'b0;
        Flush_IF    = 1'b0;
        ALUBMux     = 1'b0;
        RegDst      = 2'b00;
        ALUOp       = 6'b000000;
        ByteSig     = 2'b00;
        JumpMuxSel  = 1'b0; 
        JumpControl = 1'b0;
        MemWrite    = 1'b0;
        BranchComp  = 3'b0;
        MemRead     = 1'b0;
        RegWrite    = 1'b0;
        MemToReg    = 2'b00;
        LaMux       = 1'b0;
        
    end
    
    always @(*) begin
   
        Flush_IF    = 1'b0;
        Func   = Instruction[5:0];
        Shamt  = Instruction[10:6];
        Bit6   = Instruction[6];
        Bit16  = Instruction[16];
        Bit21  = Instruction[21];
        OpCode = Instruction[31:26];

        // NOP
        if (Instruction == 32'b0) begin
            JumpMuxSel  = 1'b0; 
            JumpControl = 1'b0;
            ALUBMux     = 1'b0;
            RegDst      = 2'b00;
            BranchComp  = 3'b0;
            ALUOp       = ALUOP_ZERO;
            ByteSig     = 2'b00;
            MemWrite    = 1'b0;
            MemRead     = 1'b0;
            RegWrite    = 1'b0;
            MemToReg    = 2'b00;
            LaMux       = 1'b0;
        end
        
        else begin
            case(OpCode)
            
                //------------
                // Arithmetic  
                //------------
            
                OP_ZERO: begin
               
                    ALUBMux     = 1'b0;
                    MemWrite    = 1'b0;
                    MemRead     = 1'b0;
                    BranchComp  = 3'b0;
                    ByteSig     = 2'b00;
                    LaMux       = 1'b0;
    
                    if (Func == FUNC_JR) begin    // jr
                        JumpMuxSel  = 1'b1;
                        JumpControl = 1'b1;
                        RegWrite    = 1'b0;
                        RegDst      = 2'b00;
                        MemToReg    = 2'b00;
                        ALUOp       = ALUOP_JUMP;  
                        
                        Flush_IF    = 1'b1; 
                    end

                    else if (Func == FUNC_JALR) begin    // jalr
                        JumpMuxSel  = 1'b1;            //
                        JumpControl = 1'b1;
                        RegWrite    = 1'b1;            //ESTO CAMBIO
                        RegDst      = 2'b01;
                        MemToReg    = 2'b01;           //
                        ALUOp       = ALUOP_JUMP;  
                        
                        Flush_IF    = 1'b1; 
                    end


                
                    else begin
                        
                        JumpMuxSel  = 1'b0;
                        JumpControl = 1'b0;
                        RegWrite    = 1'b1;
                        RegDst      = 2'b01;
                        MemToReg    = 2'b10;
                        ALUOp       = ALUOP_ZERO;  

                        if (Func == FUNC_SRL && ~Bit21) begin   // srl
                            ALUOp = ALUOP_SRL;  
                            ALUBMux = 1'b0;
                        end
                        
                        else if (Func == FUNC_SLL || Func == FUNC_SLLV) ALUBMux = 1'b0;
                        else if (Func == FUNC_SRLV  && ~Bit6)  ALUOp = ALUOP_SRLV;  // srlv
                        else ALUOp = ALUOP_ZERO;
                    
                    end

                end
                
                //addiu
                OP_ADDIU: begin
                    JumpMuxSel  = 1'b0; 
                    JumpControl = 1'b0;
                    ALUBMux     = 1'b1;
                    BranchComp  = 3'b0;
                    RegDst      = 2'b00;
                    ALUOp       = ALUOP_ADDIU;
                    ByteSig     = 2'b00;
                    MemWrite    = 1'b0;
                    MemRead     = 1'b0;
                    RegWrite    = 1'b1;
                    MemToReg    = 2'b10;
                    LaMux       = 1'b0;
                end
                
                //addi
                OP_ADDI: begin
                    JumpMuxSel  = 1'b0; 
                    JumpControl = 1'b0;
                    ALUBMux     = 1'b1;
                    BranchComp  = 3'b0;
                    RegDst      = 2'b00;
                    ALUOp       = ALUOP_ADDI;
                    ByteSig     = 2'b00;
                    MemWrite    = 1'b0;
                    MemRead     = 1'b0;
                    RegWrite    = 1'b1;
                    MemToReg    = 2'b10;
                    LaMux       = 1'b0;
                end
                
                
                //------------
                // Data
                //------------
                
                //lw
                OP_LW: begin
                    JumpMuxSel  = 1'b0; 
                    JumpControl = 1'b0;
                    ALUBMux     = 1'b1;
                    BranchComp  = 3'b0;
                    RegDst      = 2'b00;
                    ALUOp       = ALUOP_ADDI;
                    ByteSig     = 2'b00;
                    MemWrite    = 1'b0;
                    MemRead     = 1'b1;
                    RegWrite    = 1'b1;
                    MemToReg    = 2'b00; 
                    LaMux       = 1'b0;               
                end

                 /*   OP_LHU         = 6'b100101,                    //AGREGAR
                     OP_LBU         = 6'b100100,                    //AGREGAR
                     OP_LWU         = 6'b100111,                    //AGREGAR*/
                
                OP_LHU: begin
                    JumpMuxSel  = 1'b0; 
                    JumpControl = 1'b0;
                    ALUBMux     = 1'b1;
                    BranchComp  = 3'b0;
                    RegDst      = 2'b00;
                    ALUOp       = ALUOP_ADDI;
                    ByteSig     = 2'b01;
                    MemWrite    = 1'b0;
                    MemRead     = 1'b1;
                    RegWrite    = 1'b1;
                    MemToReg    = 2'b00;  
                    LaMux       = 1'b0;      
                end

                OP_LBU: begin
                    JumpMuxSel  = 1'b0; 
                    JumpControl = 1'b0;
                    ALUBMux     = 1'b1;
                    BranchComp  = 3'b0;
                    RegDst      = 2'b00;
                    ALUOp       = ALUOP_ADDI;
                    ByteSig     = 2'b10;
                    MemWrite    = 1'b0;
                    MemRead     = 1'b1;
                    RegWrite    = 1'b1;
                    MemToReg    = 2'b00;
                    LaMux       = 1'b0;
                end

                OP_LWU: begin
                    JumpMuxSel  = 1'b0; 
                    JumpControl = 1'b0;
                    ALUBMux     = 1'b1;
                    BranchComp  = 3'b0;
                    RegDst      = 2'b00;
                    ALUOp       = ALUOP_ADDI;
                    ByteSig     = 2'b00;
                    MemWrite    = 1'b0;
                    MemRead     = 1'b1;
                    RegWrite    = 1'b1;
                    MemToReg    = 2'b00; 
                    LaMux       = 1'b0;               
                end

                
                
                //sw
                OP_SW: begin  
                    JumpMuxSel  = 1'b0; 
                    JumpControl = 1'b0;               
                    ALUBMux     = 1'b1;
                    BranchComp  = 3'b0;
                    RegDst      = 2'b00;
                    ALUOp       = ALUOP_ADDI;
                    ByteSig     = 2'b00;
                    MemWrite    = 1'b1;
                    MemRead     = 1'b0;
                    RegWrite    = 1'b0;
                    MemToReg    = 2'b00; 
                    LaMux       = 1'b0;
                end
                
                //sb
                OP_SB: begin       
                    JumpMuxSel  = 1'b0; 
                    JumpControl = 1'b0;  
                    BranchComp  = 3'b0;         
                    ALUBMux     = 1'b1;
                    RegDst      = 2'b00;
                    ALUOp       = ALUOP_ADDI;
                    ByteSig     = 2'b10;
                    MemWrite    = 1'b1;
                    MemRead     = 1'b0;
                    RegWrite    = 1'b0;
                    MemToReg    = 2'b00;
                    LaMux       = 1'b0;
                end
                
                //lh
                OP_LH: begin
                    JumpMuxSel  = 1'b0; 
                    JumpControl = 1'b0;
                    ALUBMux     = 1'b1;
                    BranchComp  = 3'b0;
                    RegDst      = 2'b00;
                    ALUOp       = ALUOP_ADDI;
                    ByteSig     = 2'b01;
                    MemWrite    = 1'b0;
                    MemRead     = 1'b1;
                    RegWrite    = 1'b1;
                    MemToReg    = 2'b00;  
                    LaMux       = 1'b0;      
                end
                
                //lb
                OP_LB: begin
                    JumpMuxSel  = 1'b0; 
                    JumpControl = 1'b0;
                    ALUBMux     = 1'b1;
                    BranchComp  = 3'b0;
                    RegDst      = 2'b00;
                    ALUOp       = ALUOP_ADDI;
                    ByteSig     = 2'b10;
                    MemWrite    = 1'b0;
                    MemRead     = 1'b1;
                    RegWrite    = 1'b1;
                    MemToReg    = 2'b00;
                    LaMux       = 1'b0;
                end
                
                //sh
                OP_SH: begin
                    JumpMuxSel  = 1'b0; 
                    JumpControl = 1'b0;
                    ALUBMux     = 1'b1;
                    BranchComp  = 3'b0;
                    RegDst      = 2'b00;
                    ALUOp       = ALUOP_ADDI;
                    ByteSig     = 2'b01;
                    MemWrite    = 1'b1;
                    MemRead     = 1'b0;
                    RegWrite    = 1'b0;
                    MemToReg    = 2'b00;
                    LaMux       = 1'b0;
                end
                
                //lui
                OP_LUI: begin  
                    JumpMuxSel  = 1'b0; 
                    JumpControl = 1'b0;   
                    ALUBMux     = 1'b1;
                    BranchComp  = 3'b0;
                    RegDst      = 2'b00;
                    ALUOp       = ALUOP_LUI;
                    ByteSig     = 2'b00;
                    MemWrite    = 1'b0;
                    MemRead     = 1'b0;
                    RegWrite    = 1'b1;
                    MemToReg    = 2'b10;
                    LaMux       = 1'b0;
                end

                //beq
                OP_BEQ: begin 
                    JumpMuxSel  = 1'b0; 
                    JumpControl = 1'b0;
                    BranchComp  = BRANCH_BEQ;
                    ALUBMux     = 1'b0;
                    RegDst      = 2'b00;
                    ALUOp       = ALUOP_BEQ;
                    ByteSig     = 2'b00;
                    MemWrite    = 1'b0;
                    MemRead     = 1'b0;
                    RegWrite    = 1'b0;
                    MemToReg    = 2'b00;
                    LaMux       = 1'b0;
                end
                
                //bne
                OP_BNE: begin
                    JumpMuxSel  = 1'b0; 
                    JumpControl = 1'b0;
                    BranchComp  = BRANCH_BNE;
                    ALUBMux     = 1'b0;
                    RegDst      = 2'b00;
                    ALUOp       = ALUOP_BNE;
                    ByteSig     = 2'b00;
                    MemWrite    = 1'b0;
                    MemRead     = 1'b0;
                    RegWrite    = 1'b0;
                    MemToReg    = 2'b00;
                    LaMux       = 1'b0;
                end

                // j
                OP_J: begin  
                    JumpMuxSel  = 1'b0; 
                    JumpControl = 1'b1;
                    ALUBMux     = 1'b0;
                    RegDst      = 2'b00;
                    BranchComp  = 3'b0;
                    ALUOp       = ALUOP_JUMP;
                    ByteSig     = 2'b00;
                    MemWrite    = 1'b0;
                    MemRead     = 1'b0;
                    RegWrite    = 1'b0;
                    MemToReg    = 2'b00;
                    LaMux       = 1'b0;
                    Flush_IF    = 1'b1; 
                end
                
                // jal
                OP_JAL: begin
                    JumpMuxSel  = 1'b0; 
                    JumpControl = 1'b1;
                    ALUBMux     = 1'b0;
                    BranchComp  = 3'b0;
                    RegDst      = 2'b10;
                    ALUOp       = ALUOP_JUMP;
                    ByteSig     = 2'b00;
                    MemWrite    = 1'b0;
                    MemRead     = 1'b0;
                    RegWrite    = 1'b1;
                    MemToReg    = 2'b01;
                    LaMux       = 1'b0;
                    Flush_IF    = 1'b1; 
                end
                

                //------------
                // Logical
                //------------
               
                //andi
                OP_ANDI: begin      
                    JumpMuxSel  = 1'b0; 
                    JumpControl = 1'b0;        
                    ALUBMux     = 1'b1;
                    BranchComp  = 3'b0;
                    RegDst      = 2'b00;
                    ALUOp       = ALUOP_ANDI;
                    ByteSig     = 2'b00;
                    MemWrite    = 1'b0;
                    MemRead     = 1'b0;
                    RegWrite    = 1'b1;
                    MemToReg    = 2'b10;
                    LaMux       = 1'b0;
                end
                
                //ori
                OP_ORI: begin           
                    JumpMuxSel  = 1'b0; 
                    JumpControl = 1'b0;  
                    BranchComp  = 3'b0;      
                    ALUBMux     = 1'b1;
                    RegDst      = 2'b00;
                    ALUOp       = ALUOP_ORI;
                    ByteSig     = 2'b00;
                    MemWrite    = 1'b0;
                    MemRead     = 1'b0;
                    RegWrite    = 1'b1;
                    MemToReg    = 2'b10;
                    LaMux       = 1'b0;
                end
                
                //xori
                OP_XORI: begin
                    JumpMuxSel  = 1'b0; 
                    JumpControl = 1'b0;      
                    BranchComp  = 3'b0;
                    ALUBMux     = 1'b1;
                    RegDst      = 2'b00;
                    ALUOp       = ALUOP_XORI;
                    ByteSig     = 2'b00;
                    MemWrite    = 1'b0;
                    MemRead     = 1'b0;
                    RegWrite    = 1'b1;
                    MemToReg    = 2'b10;
                    LaMux       = 1'b0;
                end
                
             
                
                //slti
                OP_SLTI: begin  
                    JumpMuxSel  = 1'b0; 
                    JumpControl = 1'b0;
                    ALUBMux     = 1'b1;
                    BranchComp  = 3'b0;
                    RegDst      = 2'b00;
                    ALUOp       = ALUOP_SLTI;
                    ByteSig     = 2'b00;
                    MemWrite    = 1'b0;
                    MemRead     = 1'b0;
                    RegWrite    = 1'b1;
                    MemToReg    = 2'b10;
                    LaMux       = 1'b0;
                end
                
                //sltiu
                OP_SLTIU: begin
                    JumpMuxSel  = 1'b0; 
                    JumpControl = 1'b0;
                    BranchComp  = 3'b0;
                    ALUBMux     = 1'b1;
                    RegDst      = 2'b00;
                    ALUOp       = ALUOP_SLTIU;
                    ByteSig     = 2'b00;
                    MemWrite    = 1'b0;
                    MemRead     = 1'b0;
                    RegWrite    = 1'b1;
                    MemToReg    = 2'b10;
                    LaMux       = 1'b0;
                end
                
            

                default: begin
                    JumpMuxSel  = 1'b0; 
                    JumpControl = 1'b0;
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
                end 
                
            endcase
            
        end

    end

            
endmodule