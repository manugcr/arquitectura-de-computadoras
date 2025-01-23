`timescale 1ns / 1ps

module tb_MIPS_Datapath;

// Entradas del sistema
reg ClockIn;
reg Reset;

// Salidas para monitoreo



wire [31:0]  PCResult,Instruction_IF,Instruction_ID,ReadData1,ReadData2,WriteData,WriteRegister_1REGISTER,WriteRegister_2MEMWB,WriteRegister_3EXMEM,RegRD_4EX,RegRT_4EX,RegDst_4EX;
wire RegWrite;


// Instancia del módulo principal MIPS
MIPS uut (
    .ClockIn(ClockIn),
    .Reset(Reset)
);

// Rutas para acceder a las señales de la etapa MEM


/*
assign RegRTData = uut.MEM_Stage.RegRTData;
assign RegWriteEXMEM = uut.EXMEM.Out_ControlSignal[2];
assign Instruction = uut.ID_Stage.Instruction;
assign ALUResultALU = uut.EX_Stage.ALU.ALUResult;
assign RegWrite  = uut.ID_Stage.Registers.RegWrite;
assign ReadData1_out  = uut.ID_Stage.ReadData1_out;
assign ReadData2_out  = uut.ID_Stage.ReadData2_out;
assign WriteData =  uut.ID_Stage.Registers.WriteData;
assign WriteRegister_reg = uut.ID_Stage.Registers.WriteRegister_reg;
assign WriteRegister = uut.ID_Stage.Registers.WriteRegister;
assign DelayHazardAlu = uut.EX_Stage.ALU.DelayHazardAlu;*/

assign PC = uut.IF_Stage.PC.PCResult;
assign Instruction_IF = uut.IF_Stage.InstructionMemory.Instruction;
assign Instruction_ID = uut.IFID.Out_Instruction;
assign ReadData1 = uut.IDEX.In_ReadData1;
assign ReadData2 = uut.IDEX.In_ReadData2;
assign WriteData =  uut.ID_Stage.Registers.WriteData;
assign RegWrite  = uut.ID_Stage.Registers.RegWrite;
//assign WriteRegister_reg = uut.ID_Stage.Registers.WriteRegister_reg;
assign WriteRegister_1REGISTER = uut.ID_Stage.Registers.WriteRegister;
assign WriteRegister_2MEMWB = uut.MEMWB.In_RegDst;
assign WriteRegister_3EXMEM = uut.EXMEM.In_RegDst32;
assign RegRD_4EX = uut.EX_Stage.RegRD;
assign RegRT_4EX = uut.EX_Stage.RegRT;
assign RegDst_4EX = uut.EX_Stage.RegDst;





// Generador de reloj
initial begin
    ClockIn = 0;
    forever #5 ClockIn = ~ClockIn; // Periodo de reloj: 10 ns
end

// Proceso de pruebas
initial begin
    // Inicialización
    Reset = 1;
    #15 Reset = 0;

    // Esperar sincronización inicial
    
    #50;
    $stop;
end

endmodule
