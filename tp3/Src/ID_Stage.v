`timescale 1ns / 1ps

module ID_Stage(

    // --- Entradas ---
    Clock, Reset,               // Entradas del sistema
    RegWrite , MemRead_IDEX ,     // Señales de control
    RegisterDst_EXMEM,
    WriteRegister, WriteData,   // Datos para escritura
    In_Instruction,                // Instrucción actual
    ForwardData_EXMEM,          // Datos reenviados desde la etapa EX/MEM
    RegRT_IDEX, RegRD_IDEX, RegDst_IDEX,  // Registros y control de destino
    RegWrite_EXMEM,       // Señales de escritura
    ForwardMuxASel,             // Selección para el multiplexor de reenvío A
    ForwardMuxBSel,             // Selección para el multiplexor de reenvío B
    PCWrite, IFIDWrite,
    RegWrite_IDEX, 
    MemRead_EXMEM,
    ForwardData_MEMWB,
    PCAdder,
    Flush_IF,
    ReadData1_out,ReadData2_out,
    ControlSignal_Out,JumpControl,          // Señales de control de salida
    Out_Instruction,
    JumpAddress, BranchFlag,
    ImmediateValue,             // Valor inmediato extendido

    //DEBUG
    o_bus_debug
   /* o_halt,
    i_flush*/
    );             

    //--------------------------------
    // Declaración de Entradas
    //--------------------------------

    // Entradas del sistema
    input Clock, Reset;

    // Señales de control
    input RegWrite, MemRead_IDEX;

    input MemRead_EXMEM;  // solo se usa para el caso de branch hazard load

    input RegWrite_IDEX;

    // Datos reenviados
    input [31:0] ForwardData_EXMEM;

    input RegWrite_EXMEM;

    input [31:0] ForwardData_MEMWB; // SOLO UTIL PARA HAZARD DE BRANCH
    

    input [1:0] ForwardMuxASel, ForwardMuxBSel;
    

    // Control de registros de destino
    input [1:0] RegDst_IDEX;

    // Datos de entrada
    input [31:0] In_Instruction , PCAdder;
    input [4:0] RegRT_IDEX, RegRD_IDEX;

    // Datos para escritura
    input [4:0] WriteRegister, RegisterDst_EXMEM;
    input [31:0] WriteData;

    //--------------------------------
    // Declaración de Salidas
    //--------------------------------

    

    // Señales de control
    output wire [31:0] ControlSignal_Out;

    output wire JumpControl;

    output wire Flush_IF;

    output wire [31:0] Out_Instruction;

    // Datos de los registros
    output wire [31:0] ReadData1_out, ReadData2_out;

    
    wire [2:0] BranchComp;

    // Valor inmediato extendido
    output wire [31:0] ImmediateValue;

    // Señales de peligro (hazards)
    output wire PCWrite, IFIDWrite;

    // PC Addresses
    output wire [31:0]  JumpAddress;

    output wire BranchFlag;


    ///DEBUG

    output wire [32 * 32 - 1 : 0] o_bus_debug;

   // output wire o_halt; // Indicates if a HALT operation is detected

    //input i_flush;


    //--------------------------------
    // Declaración de Cables
    //--------------------------------

    // Hazard Signals
    wire ControlStall;

    // Control de memoria
    wire MemWrite_Control, MemRead_Control;
    wire [1:0] ByteSig_Control;  

    wire JumpFlush;

    wire JumpMuxSel;

    wire BranchFlush;

    wire [31:0] ShiftedJumpAddress;

    // Cable para valor inmediato desplazado
    wire [31:0] ImmediateShift, ReadData1, ReadData2;

    // Control de ejecución
    wire ALUBMux_Control;
    wire [1:0] RegDst_Control;
    wire [5:0] ALUOp_Control;

    wire FlushJump;

    wire BranchControl;

    wire itsHazardBranch, NotifyCompare;

        

    // Control de escritura posterior
    wire RegWrite_Control;
    wire [1:0] MemToReg_Control;

    // Salida del bloque de extensión de signo
    wire [31:0] SignExtend_Out;

    wire LaMux;

    wire HazardCompareBranch;

    //--------------------------------
    // Componentes de Hardware
    //--------------------------------

    assign Out_Instruction = In_Instruction;

    assign BranchFlag = BranchControl;

    // Unidad de detección de peligros
    Hazard HazardDetection(
        .Reset(Reset),
            .OpCode(In_Instruction[31:26]), 
            .Func(In_Instruction[5:0]),
        .RegRS_IFID(In_Instruction[25:21]),
        .RegRT_IFID(In_Instruction[20:16]),
        .RegRT_IDEX(RegRT_IDEX),
        .RegRD_IDEX(RegRD_IDEX),
        .HazardCompareBranch(HazardCompareBranch),
        .RegWrite_IDEX(RegWrite_IDEX), //////////////////////////////
        .RegWrite_EXMEM(RegWrite_EXMEM), /////////////////////////////
        .RegisterDst_EXMEM(RegisterDst_EXMEM),  ///////////////////////
        .MemRead_IDEX(MemRead_IDEX),
        .RegDst_IDEX(RegDst_IDEX),
        .MemRead_EXMEM(MemRead_EXMEM),          //SOLO SE USA PARA HAZARD BRANCH LOAD
        .ControlStall(ControlStall),
        .PCWrite(PCWrite),
        .RegDst_MEMWB(WriteRegister),   //PARA HAZARD DE BRANCH en etapa MEMWB
        .IFIDWrite(IFIDWrite),
      //  .o_halt(o_halt),
        .BranchFlush(FlushJump));
    

    // Módulo de control
    Control              Control(.Instruction(In_Instruction),
                                    .ALUBMux(ALUBMux_Control), .RegDst(RegDst_Control), 
                                    .ALUOp(ALUOp_Control), .MemWrite(MemWrite_Control), 
                                    .MemRead(MemRead_Control), .ByteSig(ByteSig_Control),
                                    .RegWrite(RegWrite_Control), .MemToReg(MemToReg_Control),  
                                    .JumpMuxSel(JumpMuxSel), 
                                    .BranchComp(BranchComp),
                                    .JumpControl(JumpControl), 
                                    .Flush_IF(JumpFlush), //???
                                    .LaMux(LaMux));

    // Bancos de registros
    Registers Registers(
       // .i_flush(i_flush),
       .Reset(Reset),
        .ReadRegister1(In_Instruction[25:21]), // rs
        .ReadRegister2(In_Instruction[20:16]), // rt 
        .WriteRegister(WriteRegister),  // Registro de destino para escritura
        .WriteData(WriteData), 
        .RegWrite(RegWrite), 
        .Clock(Clock), 
        .ReadData1(ReadData1), 
        .ReadData2(ReadData2),
       .o_bus_debug (o_bus_debug)
    );

    // Extensión de signo para valores inmediatos
    SignExtension ImmSignExtend(
        .in(In_Instruction[15:0]), 
        .out(SignExtend_Out)
    );



    Mux2to1            ControlMux(.out(ControlSignal_Out), 
                                       .inA({14'd0, ALUOp_Control[5:0], ALUBMux_Control, RegDst_Control[1:0], 
                                             ByteSig_Control[1:0], MemWrite_Control, MemRead_Control, 2'd0, 
                                             RegWrite_Control, MemToReg_Control[1:0]}),
                                       .inB(32'd0), 
                                       .sel(ControlStall));

    Mux3to1            ForwardMuxA_ID(.out(ReadData1_out), 
                                           .inA(ReadData1),
                                           .inB(ForwardData_EXMEM), 
                                           .inC(ForwardData_MEMWB),           //SOLO PARA HAZARD BRANCH    
                                           .sel(ForwardMuxASel));
                                    
    Mux3to1            ForwardMuxB_ID(.out(ReadData2_out), 
                                           .inA(ReadData2),
                                           .inB(ForwardData_EXMEM), 
                                           .inC(ForwardData_MEMWB),   //SOLO PARA HAZARD BRANCH
                                           .sel(ForwardMuxBSel));  



    // Multiplexor para dirección de carga inmediata
    Mux2to1 LoadAddressMux(
        .out(ImmediateValue),
        .inA(SignExtend_Out),
        .inB({16'd0, In_Instruction[15:0]}),
        .sel(LaMux)
    );

    // JUMP


        ShiftLeft2              JumpShift(.inputNum({6'b0, In_Instruction[25:0]}), 
                                      .outputNum(ShiftedJumpAddress));

        Mux2to1            JumpMux(.out(JumpAddress), 
                                    .inA({PCAdder[31:28], ShiftedJumpAddress[27:0]}),
                                    .inB(ReadData1_out), 
                                    .sel(JumpMuxSel));

    //BRANCH

        Comparator              BranchCompare(.InA(ReadData1_out), 
                                          .InB(ReadData2_out), 
                                          .Result(BranchControl),
                                          .CompareFlag(NotifyCompare),
                                          .Control(BranchComp));                       


        Or                  FlushOr(.InA(BranchControl), 
                                    .InB(FlushJump), 
                                    .Out(Flush_IF));

         Or                  HazardBranchCompareFlagOr(.InA(ForwardMuxASel[1]), 
                                    .InB(ForwardMuxBSel[1]), 
                                    .Out(itsHazardBranch));
      
        Or                  CompareFlagOr(.InA(itsHazardBranch), 
                                        .InB(HazardCompareBranch), 
                                        .Out(NotifyCompare));                              
    





endmodule
