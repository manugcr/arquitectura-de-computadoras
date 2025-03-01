`timescale 1ns / 1ps

module EX_Stage(

    // --- Inputs ---
    ALUOp, RegDst,        
    RegWrite, ALUBMuxSel,     
    ReadData1, ReadData2, SignExtend,
    RegRT, RegRD,  ForwardMuxASel, ForwardMuxBSel,                     
    ALUResult_MEM,                    
    Shamt,                            
      
    // --- Outputs ---         
    ALUZero, ALUResult,              
    RegDst32_Out,MemToReg_WB,        
    RegWrite_Out,
    ALURT
    );             
      

    input        ALUBMuxSel,RegWrite;
    input [1:0] RegDst;
    input [5:0] ALUOp;
    input [1:0]  ForwardMuxASel, ForwardMuxBSel;
    input [31:0] ALUResult_MEM, MemToReg_WB;
    input [4:0] RegRT, RegRD;
    input [4:0]  Shamt;
    input [31:0] ReadData1, ReadData2, SignExtend;
    
    output wire         ALUZero;
    output wire [31:0]  ALUResult;
    output wire [31:0] RegDst32_Out;
    output wire [31:0] ALURT;
    output wire RegWrite_Out;

    wire [31:0] ALUA, ALUB; 
    wire [5:0] ALUControl;


    ALUControl       ALUController1(.Funct(SignExtend[5:0]), 
                                       .ALUOp(ALUOp), 
                                       .ALUControl(ALUControl));
    

    ALU                  ALU(.ALUControl(ALUControl), 
                            .A(ALUA), 
                            .B(ALUB), 
                            .Shamt(Shamt),
                            .ALUResult(ALUResult), 
                            .Zero(ALUZero), 
                            .RegWrite(RegWrite),
                            .RegWrite_Out(RegWrite_Out));
    
                               
    Mux3to1        RegDstMux(.out(RegDst32_Out), 
                                  .inA({27'd0, RegRT}), 
                                  .inB({27'd0, RegRD}), 
                                  .inC(32'd31), 
                                  .sel(RegDst));
    

    Mux3to1        ForwardMuxA(.out(ALUA),
                                    .inA(ReadData1),
                                    .inB(ALUResult_MEM),
                                    .inC(MemToReg_WB),
                                    .sel(ForwardMuxASel));
    
    
    Mux3to1        ForwardMuxB(.out(ALURT),
                                    .inA(ReadData2),
                                    .inB(ALUResult_MEM),
                                    .inC(MemToReg_WB),
                                    .sel(ForwardMuxBSel));
    
    Mux2to1        ALUBMux(.out(ALUB),
                                .inA(ALURT),
                                .inB(SignExtend),
                                .sel(ALUBMuxSel));


endmodule
