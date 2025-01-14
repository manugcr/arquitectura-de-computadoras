`timescale 1ns / 1ps



module EX_Stage(

    // --- Inputs ---
                        // System Inputs
    ALUOp, RegDst,        // Control Signals
    RegWrite, ALUBMuxSel,     
    ReadData1, ReadData2, SignExtend, // ALU Inputs
    RegRT, RegRD,  ForwardMuxASel, ForwardMuxBSel,                      // Write Back Registers
    ALUResult_MEM,        // Forwarding Data
    Shamt,                            // Shift Amount
      
    // --- Outputs ---         
    ALUZero, ALUResult,               // ALU Outputs     
    RegDst32_Out,MemToReg_WB,                     // Write Back Register
    RegWrite_Out,
    ALURT
    );             
      
          
    // Control Signals     
    input        ALUBMuxSel,RegWrite;
    input [1:0] RegDst;
    input [5:0] ALUOp;

     // Forwarding
    input [1:0]  ForwardMuxASel, ForwardMuxBSel;
    

    input [31:0] ALUResult_MEM, MemToReg_WB;
    
    // Write Back Registers
    input [4:0] RegRT, RegRD;
    
    // ALU Inputs
    input [4:0]  Shamt;
    input [31:0] ReadData1, ReadData2, SignExtend;
    

    // ALU Outputs
    output wire         ALUZero;
    output wire [31:0]  ALUResult;
    
    // Write Back Register
    output wire [31:0] RegDst32_Out;
    
    output wire [31:0] ALURT;
    
    output wire RegWrite_Out;
    
    
    // ALU Inputs
    wire [31:0] ALUA, ALUB; 
    
    // ALU Control Signal
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
