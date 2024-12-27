`timescale 1ns / 1ps


module ID_Stage(

    // --- Inputs ---
    Clock, Reset,               // System Inputs
    RegWrite,     // Control Signals
    WriteRegister, WriteData,   // Write data
    Instruction, 
    RegRT_IDEX, RegRD_IDEX, RegDst_IDEX,
    RegWrite_IDEX, RegWrite_EXMEM,
    RegisterDst_EXMEM,
    PCAdder,       
    ControlSignal_Out,  // Control Signals
    ReadData1, ReadData2,       // Register Data
    ImmediateValue,             // Immediate value        // Hazard Signals    
    V0, V1 //V0 and V1
    );             
          

    // System Inputs
    input Clock, Reset;
          
          
    // Control Signals     
    input RegWrite;
    input RegWrite_IDEX, RegWrite_EXMEM;
    

    
    input [1:0] RegDst_IDEX; 
    
    // Data
    input [31:0] Instruction, PCAdder;
    
    input [4:0] RegRT_IDEX, RegRD_IDEX;
    
    input [4:0] RegisterDst_EXMEM;
    
    
    // Write Register Data
    input [4:0]  WriteRegister;
    input [31:0] WriteData;
    
    //--------------------------------
    // Outputs
    //--------------------------------
    

    
    // Control Signal
    output wire [31:0] ControlSignal_Out;
    
    // Register Data
    output wire [31:0] ReadData1, ReadData2;
    
    // Immediate value
    output wire [31:0] ImmediateValue;

    
    
    //V0 and V1 Data
    output wire [31:0] V0, V1;

    //--------------------------------
    // Wires                        
    //--------------------------------
    
    
    
    wire [31:0] ImmediateShift;
    
    // Execute
    wire       ALUBMux_Control;
    wire [1:0] RegDst_Control;
    wire [5:0] ALUOp_Control;
    
    // Write Back
    wire       RegWrite_Control;
    wire [1:0] MemToReg_Control;
    
    
    wire [31:0] SignExtend_Out;

    
    //--------------------------------
    // Hardware Components
    //--------------------------------
    
    
    Control              Control(.Instruction(Instruction),
                                    .ALUBMux(ALUBMux_Control), .RegDst(RegDst_Control), 
                                    .ALUOp(ALUOp_Control), 
                                    .RegWrite(RegWrite_Control), .MemToReg(MemToReg_Control));
    
    
    
    Registers            Registers(.ReadRegister1(Instruction[25:21]), // rs
                                      .ReadRegister2(Instruction[20:16]), // rt 
                                      .WriteRegister(WriteRegister), 
                                      .WriteData(WriteData), 
                                      .RegWrite(RegWrite), 
                                      .Clock(Clock), 
                                      .ReadData1(ReadData1), 
                                      .ReadData2(ReadData2),
                                      .V0(V0),
                                      .V1(V1));
    
    
    
    SignExtension           ImmSignExtend(.in(Instruction[15:0]), 
                                          .out(SignExtend_Out));

    
    ShiftLeft2              AdderShift(.inputNum(SignExtend_Out), 
                                       .outputNum(ImmediateShift));
    



endmodule
