`timescale 1ns / 1ps

module tb_MIPS_Jump;

// Entradas del sistema
reg ClockIn;
reg Reset;

// Salidas para monitoreo



wire [31:0]  ID_JumpMux_A,ID_JumpMux_B,ID_JumpMux_sel,IF_JumpAddress,IF_PCIn,EX_ALUResult,WB_MemToReg,MEMWB_AluResult,EXMEM_AluResult,PCResult,IF_Instruction,IFID_Instruction,IDEX_ReadData1,IDEX_ReadData2,WriteData;
wire EX_Zero,EX_RegWrite_Out,RegWrite,ID_STALL,IF_JumpFlag;


// Instancia del módulo principal MIPS
MIPS uut (
    .ClockIn(ClockIn),
    .Reset(Reset)
);

// Rutas para acceder a las señales de la etapa MEM



assign PC = uut.IF_Stage.PC.PCResult;
assign IF_Instruction = uut.IF_Stage.InstructionMemory.Instruction;
assign IFID_Instruction = uut.IFID.Out_Instruction;
// assign IDEX_ReadData1 = uut.IDEX.Out_ReadData1;
// assign IDEX_ReadData2 = uut.IDEX.Out_ReadData2;
// // assign EXMEM_AluResult = uut.EXMEM.Out_ALUResult;
// // assign MEMWB_AluResult = uut.MEMWB.Out_ALUResult;
// // assign WB_MemToReg = uut.WB_Stage.MemToReg_Out;
// // assign ID_STALL = uut.ID_Stage.HazardDetection.ControlStall;

// assign EX_ALUResult = uut.EX_Stage.ALU.ALUResult;
// assign EX_RegWrite_Out = uut.EX_Stage.ALU.RegWrite_Out;
// assign EX_Zero = uut.EX_Stage.ALU.Zero;

assign IF_PCIn = uut.IF_Stage.PC.PC_In;
assign IF_JumpFlag = uut.IF_Stage.JumpControl;
assign IF_JumpAddress = uut.IF_Stage.JumpAddress;


assign ID_JumpMux_A = uut.ID_Stage.JumpMux.inA;
assign ID_JumpMux_B = uut.ID_Stage.JumpMux.inB;
assign ID_JumpMux_sel = uut.ID_Stage.JumpMux.sel;







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
