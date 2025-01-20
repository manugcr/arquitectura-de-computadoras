`timescale 1ns / 1ps

module Control(Instruction,
                  ALUBMux, RegDst, ALUOp, MemWrite, MemRead, ByteSig, RegWrite, MemToReg, 
                  Flush_IF, LaMux);
    
    //--------------------------------
    // Inputs
    //--------------------------------
                
    input [31:0] Instruction;
    
    //--------------------------------
    // Outputs
    //--------------------------------
    
    output reg      Flush_IF;
    
    
    // Execute
    output reg       ALUBMux, LaMux;
    output reg [1:0] RegDst;
    output reg [5:0] ALUOp;
    
    // Memory
    output reg MemWrite, MemRead;
    output reg [1:0] ByteSig;   
    
    // Write Back
    output reg       RegWrite;
    output reg [1:0] MemToReg;
    
    
    localparam [5:0] OP_R           = 6'b000000,   // 
                     OP_LW          = 6'b100011,   // LW
                     OP_SW          = 6'b101011,   // SW
                     OP_ADDI        = 6'b001000,   // ADDI
                     OP_ADDIU       = 6'b001001,   // ADDIU
                     LHU_TYPE       = 6'b100101,  //AGREGAR
                     LBU_TYPE       = 6'b100100,  //AGREGAR
                     LWU_TYPE       = 6'b100111,  //AGREGAR
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
    
    localparam [5:0] FUNC_ROTR      =  6'b000010,  // ROTR
                     FUNC_ROTRV     =  6'b000110,  // ROTRV
                     FUNC_SLL       =  6'b000000,  // SLL
                     FUNC_SRL       =  6'b000010,  // SRL 
                     FUNC_SRLV      =  6'b000110,  // SRLV 
                     FUNC_SRAV      =  6'b000111;  // SRAV 

    localparam [5:0] ALUOP_ZERO     = 6'b000000, // ZERO
                     ALUOP_ADDIU    = 6'b000001, // ADDIU
                     ALUOP_ADDI     = 6'b000010, // ADDI
                     ALUOP_MUL      = 6'b000011, // MUL, MADD, MSUB
                     ALUOP_LUI      = 6'b000100, // LUI
                     ALUOP_ANDI     = 6'b001100, // ANDI
                     ALUOP_ORI      = 6'b001101, // ORI
                     ALUOP_XORI     = 6'b001110, // XORI
                     ALUOP_SEB      = 6'b001111, // SEB
                     ALUOP_SLTI     = 6'b010000, // SLTI
                     ALUOP_SLTIU    = 6'b010001, // SLTIU
                     ALUOP_SRL      = 6'b010010, // SRL
                     ALUOP_ROTR     = 6'b010011, // ROTR
                     ALUOP_SRLV     = 6'b010100, // SRLV
                     ALUOP_SEH      = 6'b010101, // SEH
                     ALUOP_ROTRV    = 6'b010110, // ROTRV
                     ALUOP_EXI      = 6'b010111, // EH, IH, DH, EB, IB
                     ALUOP_LA       = 6'b011000; // LA
             
      

    reg Bit21, Bit16, Bit6;
    reg [5:0] Func, Shamt, OpCode;

    //--------------------------------
    // Controller Logic
    //--------------------------------

    initial begin
        
        //ControlSignal <= 32'b0;
        Flush_IF    <= 1'b0;
        ALUBMux     <= 1'b0;
        RegDst      <= 2'b00;
        ALUOp       <= 6'b000000;
        ByteSig     <= 2'b00;
        MemWrite    <= 1'b0;
        MemRead     <= 1'b0;
        RegWrite    <= 1'b0;
        MemToReg    <= 2'b00;
        LaMux       <= 1'b0;
        
    end
    
    always @(*) begin
   
        Flush_IF    <= 1'b0;
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
            ByteSig     <= 2'b00;
            MemWrite    <= 1'b0;
            MemRead     <= 1'b0;
            RegWrite    <= 1'b0;
            MemToReg    <= 2'b00;
            LaMux       <= 1'b0;
        end
        
        else begin
            case(OpCode)
            
                //------------
                // Arithmetic  
                //------------
            
                OP_R: begin
               
                    ALUBMux     <= 1'b0;
                    MemWrite    <= 1'b0;
                    MemRead     <= 1'b0;
                    ByteSig     <= 2'b00;
                    LaMux       <= 1'b0;
                    RegWrite    <= 1'b1;
                    RegDst      <= 2'b01;
                    MemToReg    <= 2'b10;
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
                
                //addiu
                OP_ADDIU: begin
                    ALUBMux     <= 1'b1;
                    RegDst      <= 2'b00;
                    ALUOp       <= ALUOP_ADDIU;
                    ByteSig     <= 2'b00;
                    MemWrite    <= 1'b0;
                    MemRead     <= 1'b0;
                    RegWrite    <= 1'b1;
                    MemToReg    <= 2'b10;
                    LaMux       <= 1'b0;
                end
                
                //addi
                OP_ADDI: begin
                    ALUBMux     <= 1'b1;
                    RegDst      <= 2'b00;
                    ALUOp       <= ALUOP_ADDI;
                    ByteSig     <= 2'b00;
                    MemWrite    <= 1'b0;
                    MemRead     <= 1'b0;
                    RegWrite    <= 1'b1;
                    MemToReg    <= 2'b10;
                    LaMux       <= 1'b0;
                end
                
                
                //------------
                // Data
                //------------
                
                //lw
                OP_LW: begin
                    ALUBMux     <= 1'b1;
                    RegDst      <= 2'b00;
                    ALUOp       <= ALUOP_ADDI;
                    ByteSig     <= 2'b00;
                    MemWrite    <= 1'b0;
                    MemRead     <= 1'b1;
                    RegWrite    <= 1'b1;
                    MemToReg    <= 2'b00; 
                    LaMux       <= 1'b0;               
                end
                
                //sw
                OP_SW: begin                 
                    ALUBMux     <= 1'b1;
                    RegDst      <= 2'b00;
                    ALUOp       <= ALUOP_ADDI;
                    ByteSig     <= 2'b00;
                    MemWrite    <= 1'b1;
                    MemRead     <= 1'b0;
                    RegWrite    <= 1'b0;
                    MemToReg    <= 2'b00; 
                    LaMux       <= 1'b0;
                end
                
                //sb
                OP_SB: begin                  
                    ALUBMux     <= 1'b1;
                    RegDst      <= 2'b00;
                    ALUOp       <= ALUOP_ADDI;
                    ByteSig     <= 2'b10;
                    MemWrite    <= 1'b1;
                    MemRead     <= 1'b0;
                    RegWrite    <= 1'b0;
                    MemToReg    <= 2'b00;
                    LaMux       <= 1'b0;
                end
                
                //lh
                OP_LH: begin
                    ALUBMux     <= 1'b1;
                    RegDst      <= 2'b00;
                    ALUOp       <= ALUOP_ADDI;
                    ByteSig     <= 2'b01;
                    MemWrite    <= 1'b0;
                    MemRead     <= 1'b1;
                    RegWrite    <= 1'b1;
                    MemToReg    <= 2'b00;  
                    LaMux       <= 1'b0;      
                end
                
                //lb
                OP_LB: begin
                    ALUBMux     <= 1'b1;
                    RegDst      <= 2'b00;
                    ALUOp       <= ALUOP_ADDI;
                    ByteSig     <= 2'b10;
                    MemWrite    <= 1'b0;
                    MemRead     <= 1'b1;
                    RegWrite    <= 1'b1;
                    MemToReg    <= 2'b00;
                    LaMux       <= 1'b0;
                end
                
                //sh
                OP_SH: begin
                    ALUBMux     <= 1'b1;
                    RegDst      <= 2'b00;
                    ALUOp       <= ALUOP_ADDI;
                    ByteSig     <= 2'b01;
                    MemWrite    <= 1'b1;
                    MemRead     <= 1'b0;
                    RegWrite    <= 1'b0;
                    MemToReg    <= 2'b00;
                    LaMux       <= 1'b0;
                end
                
                //lui
                OP_LUI: begin     
                    ALUBMux     <= 1'b1;
                    RegDst      <= 2'b00;
                    ALUOp       <= ALUOP_LUI;
                    ByteSig     <= 2'b00;
                    MemWrite    <= 1'b0;
                    MemRead     <= 1'b0;
                    RegWrite    <= 1'b1;
                    MemToReg    <= 2'b10;
                    LaMux       <= 1'b0;
                end
                

                //------------
                // Logical
                //------------
               
                //andi
                OP_ANDI: begin              
                    ALUBMux     <= 1'b1;
                    RegDst      <= 2'b00;
                    ALUOp       <= ALUOP_ANDI;
                    ByteSig     <= 2'b00;
                    MemWrite    <= 1'b0;
                    MemRead     <= 1'b0;
                    RegWrite    <= 1'b1;
                    MemToReg    <= 2'b10;
                    LaMux       <= 1'b0;
                end
                
                //ori
                OP_ORI: begin                   
                    ALUBMux     <= 1'b1;
                    RegDst      <= 2'b00;
                    ALUOp       <= ALUOP_ORI;
                    ByteSig     <= 2'b00;
                    MemWrite    <= 1'b0;
                    MemRead     <= 1'b0;
                    RegWrite    <= 1'b1;
                    MemToReg    <= 2'b10;
                    LaMux       <= 1'b0;
                end
                
                //xori
                OP_XORI: begin      
                    ALUBMux     <= 1'b1;
                    RegDst      <= 2'b00;
                    ALUOp       <= ALUOP_XORI;
                    ByteSig     <= 2'b00;
                    MemWrite    <= 1'b0;
                    MemRead     <= 1'b0;
                    RegWrite    <= 1'b1;
                    MemToReg    <= 2'b10;
                    LaMux       <= 1'b0;
                end
                
             
                
                //slti
                OP_SLTI: begin  
                    ALUBMux     <= 1'b1;
                    RegDst      <= 2'b00;
                    ALUOp       <= ALUOP_SLTI;
                    ByteSig     <= 2'b00;
                    MemWrite    <= 1'b0;
                    MemRead     <= 1'b0;
                    RegWrite    <= 1'b1;
                    MemToReg    <= 2'b10;
                    LaMux       <= 1'b0;
                end
                
                //sltiu
                OP_SLTIU: begin
                    ALUBMux     <= 1'b1;
                    RegDst      <= 2'b00;
                    ALUOp       <= ALUOP_SLTIU;
                    ByteSig     <= 2'b00;
                    MemWrite    <= 1'b0;
                    MemRead     <= 1'b0;
                    RegWrite    <= 1'b1;
                    MemToReg    <= 2'b10;
                    LaMux       <= 1'b0;
                end
                
            

                default: begin
                    ALUBMux     <= 1'b0;
                    RegDst      <= 2'b00;
                    ALUOp       <= ALUOP_ZERO;
                    ByteSig     <= 2'b00;
                    MemWrite    <= 1'b0;
                    MemRead     <= 1'b0;
                    RegWrite    <= 1'b0;
                    MemToReg    <= 2'b00;
                    LaMux       <= 1'b0;
                end 
                
            endcase
            
        end

    end

            
endmodule
