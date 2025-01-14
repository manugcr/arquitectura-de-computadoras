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
    
    
    localparam [5:0] OP_ZERO        = 6'b000000,   // Zero OpCode
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
    
    localparam [5:0] FUNC_ROTR      =  6'b000010,  // ROTR
                     FUNC_ROTRV     =  6'b000110,  // ROTRV
                     FUNC_SLL       =  6'b000000,  // SLL
                     FUNC_SRL       =  6'b000010,  // SRL 
                     FUNC_SRLV      =  6'b000110,  // SRLV 
                     FUNC_SRAV      =  6'b000111;  // SRAV 

    localparam [5:0] ALUOP_ZERO     = 6'd00,       // ZERO
                     ALUOP_ADDIU    = 6'd01,       // ADDIU
                     ALUOP_ADDI     = 6'd02,       // ADDI
                     ALUOP_MUL      = 6'd03,       // MUL, MADD, MSUB
                     ALUOP_LUI      = 6'd04,       // LUI
                     ALUOP_ANDI     = 6'd12,       // ANDI
                     ALUOP_ORI      = 6'd13,       // ORI
                     ALUOP_XORI     = 6'd14,       // XORI
                     ALUOP_SEB      = 6'd15,       // SEB
                     ALUOP_SLTI     = 6'd16,       // SLTI
                     ALUOP_SLTIU    = 6'd17,       // SLTIU
                     ALUOP_SRL      = 6'd18,       // SRL
                     ALUOP_ROTR     = 6'd19,       // ROTR
                     ALUOP_SRLV     = 6'd20,       // SRLV
                     ALUOP_SEH      = 6'd21,       // SEH
                     ALUOP_ROTRV    = 6'd22,       // ROTRV
                     ALUOP_EXI      = 6'd23,       // EH, IH, DH, EB, IB
                     ALUOP_LA       = 6'd24;       // LA
             
      

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
            
                OP_ZERO: begin
               
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
                
                //mul, madd, msub
                OP_MADD: begin
                    ALUBMux     <= 1'b0;
                    RegDst      <= 2'b01;
                    ALUOp       <= ALUOP_MUL;
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
                
                //seh, seb
                OP_SEBSEH: begin
                    ALUBMux     <= 1'b0;
                    RegDst      <= 2'b01;
                    ByteSig     <= 2'b00;
                    MemWrite    <= 1'b0;
                    MemRead     <= 1'b0;
                    RegWrite    <= 1'b1;
                    MemToReg    <= 2'b10;
                    LaMux       <= 1'b0;
                   
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
                
                // EH, IH, DH, EB, IB, ABS
                OP_EXI: begin
                    ALUBMux     <= 1'b1;
                    RegDst      <= 2'b00;
                    ALUOp       <= ALUOP_EXI;
                    ByteSig     <= 2'b00;
                    MemWrite    <= 1'b0;
                    MemRead     <= 1'b0;
                    RegWrite    <= 1'b1;
                    MemToReg    <= 2'b10;
                    LaMux       <= 1'b0;
                end

                // LA
                OP_LA: begin
                    ALUBMux     <= 1'b1;
                    RegDst      <= 2'b00;
                    ALUOp       <= ALUOP_LA;
                    ByteSig     <= 2'b00;
                    MemWrite    <= 1'b0;
                    MemRead     <= 1'b0;
                    RegWrite    <= 1'b1;
                    MemToReg    <= 2'b10;
                    LaMux       <= 1'b1;
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
