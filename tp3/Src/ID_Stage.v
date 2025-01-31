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
    PCAdder,
    ReadData1_out,ReadData2_out,
    ControlSignal_Out,JumpControl,          // Señales de control de salida
    Out_Instruction,
    JumpAddress,
    ImmediateValue             // Valor inmediato extendido
    );             

    //--------------------------------
    // Declaración de Entradas
    //--------------------------------

    // Entradas del sistema
    input Clock, Reset;

    // Señales de control
    input RegWrite, MemRead_IDEX;

    input RegWrite_IDEX;

    // Datos reenviados
    input [31:0] ForwardData_EXMEM;

    input RegWrite_EXMEM;

    input ForwardMuxASel, ForwardMuxBSel;
    

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

    output wire [31:0] Out_Instruction;

    // Datos de los registros
    output wire [31:0] ReadData1_out, ReadData2_out;

    

    // Valor inmediato extendido
    output wire [31:0] ImmediateValue;

    // Señales de peligro (hazards)
    output wire PCWrite, IFIDWrite;

    // PC Addresses
    output wire [31:0]  JumpAddress;


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

    wire [31:0] ShiftedJumpAddress;

    // Cable para valor inmediato desplazado
    wire [31:0] ImmediateShift, ReadData1, ReadData2;

    // Control de ejecución
    wire ALUBMux_Control;
    wire [1:0] RegDst_Control;
    wire [5:0] ALUOp_Control;

        

    // Control de escritura posterior
    wire RegWrite_Control;
    wire [1:0] MemToReg_Control;

    // Salida del bloque de extensión de signo
    wire [31:0] SignExtend_Out;

    wire LaMux;

    //--------------------------------
    // Componentes de Hardware
    //--------------------------------

    assign Out_Instruction = In_Instruction;

    // Unidad de detección de peligros
    Hazard HazardDetection(
        .RegRS_IFID(In_Instruction[25:21]),
        .RegRT_IFID(In_Instruction[20:16]),
        .RegRT_IDEX(RegRT_IDEX),
        .RegRD_IDEX(RegRD_IDEX),
        .RegWrite_IDEX(RegWrite_IDEX), //////////////////////////////
        .RegWrite_EXMEM(RegWrite_EXMEM), /////////////////////////////
        .RegisterDst_EXMEM(RegisterDst_EXMEM),  ///////////////////////
        .MemRead_IDEX(MemRead_IDEX),
        .RegDst_IDEX(RegDst_IDEX),
        .ControlStall(ControlStall),
        .PCWrite(PCWrite),
        .IFIDWrite(IFIDWrite)
    );

    // Módulo de control
    Control              Control(.Instruction(In_Instruction),
                                    .ALUBMux(ALUBMux_Control), .RegDst(RegDst_Control), 
                                    .ALUOp(ALUOp_Control), .MemWrite(MemWrite_Control), 
                                    .MemRead(MemRead_Control), .ByteSig(ByteSig_Control),
                                    .RegWrite(RegWrite_Control), .MemToReg(MemToReg_Control),  
                                    .JumpMuxSel(JumpMuxSel), 
                                    .JumpControl(JumpControl), 
                                    .Flush_IF(JumpFlush), //???
                                    .LaMux(LaMux));

    // Bancos de registros
    Registers Registers(
        .ReadRegister1(In_Instruction[25:21]), // rs
        .ReadRegister2(In_Instruction[20:16]), // rt 
        .WriteRegister(WriteRegister),  // Registro de destino para escritura
        .WriteData(WriteData), 
        .RegWrite(RegWrite), 
        .Clock(Clock), 
        .ReadData1(ReadData1), 
        .ReadData2(ReadData2)
    );

    // Extensión de signo para valores inmediatos
    SignExtension ImmSignExtend(
        .in(In_Instruction[15:0]), 
        .out(SignExtend_Out)
    );

    // Desplazador hacia la izquierda por 2
    ShiftLeft2 AdderShift(
        .inputNum(SignExtend_Out), 
        .outputNum(ImmediateShift)
    );

    Mux2to1            ControlMux(.out(ControlSignal_Out), 
                                       .inA({14'd0, ALUOp_Control[5:0], ALUBMux_Control, RegDst_Control[1:0], 
                                             ByteSig_Control[1:0], MemWrite_Control, MemRead_Control, 2'd0, 
                                             RegWrite_Control, MemToReg_Control[1:0]}),
                                       .inB(32'd0), 
                                       .sel(ControlStall));

    Mux2to1            ForwardMuxA_ID(.out(ReadData1_out), 
                                           .inA(ReadData1),
                                           .inB(ForwardData_EXMEM), 
                                           .sel(ForwardMuxASel));
                                    
    Mux2to1            ForwardMuxB_ID(.out(ReadData2_out), 
                                           .inA(ReadData2),
                                           .inB(ForwardData_EXMEM), 
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




endmodule
