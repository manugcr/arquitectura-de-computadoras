`timescale 1ns / 1ps

module tb_MIPS_Datapath;

// Entradas del sistema
reg ClockIn;
reg Reset;

// Salidas para monitoreo



wire [31:0] ID_Controlsignal,ID_COMPARESel,IF_PC,IF_Instruction,IFID_Instruction,ID_ReadData1,ID_ReadData2,IDEX_ReadData1,IDEX_ReadData2,IDEX_RT,EXMEM_RegDSTIn,EXMEM_RegDSTOut;
wire ID_Stall,IFID_Flush,ID_COMPARE,ID_COMPAREFLAGGG,ID_PULSE,ID_Regwrite;
wire [31:0] EX_ALUResult,EXMEM_AluResult,MEMWB_AluResult,WB_MemToReg ;



// Instancia del módulo principal MIPS
MIPS uut (
    .ClockIn(ClockIn),
    .Reset(Reset)
);

// Rutas para acceder a las señales de la etapa MEM



assign IF_PC = uut.IF_Stage.PC.PCResult;
assign IF_Instruction = uut.IF_Stage.InstructionMemory.Instruction;
assign IFID_Instruction = uut.IFID.Out_Instruction;
assign IDEX_ReadData1 = uut.IDEX.Out_ReadData1;
assign IDEX_ReadData2 = uut.IDEX.Out_ReadData2;

assign ID_ReadData2 = uut.ID_Stage.ReadData2_out;
assign ID_ReadData1 = uut.ID_Stage.ReadData1_out;

assign EXMEM_AluResult = uut.EXMEM.Out_ALUResult;
assign MEMWB_AluResult = uut.MEMWB.Out_ALUResult;
assign WB_MemToReg = uut.WB_Stage.MemToReg_Out;
assign ID_Stall = uut.ID_Stage.HazardDetection.ControlStall;

assign EX_ALUResult = uut.EX_Stage.ALU.ALUResult;
assign EX_RegWrite_Out = uut.EX_Stage.ALU.RegWrite_Out;
assign EX_Zero = uut.EX_Stage.ALU.Zero;
assign IFID_Flush = uut.IFID.Flush;

assign ID_COMPARE = uut.ID_Stage.BranchCompare.Result;
assign ID_COMPAREFLAGGG = uut.ID_Stage.BranchCompare.CompareFlag;
assign ID_COMPARESel = uut.ID_Stage.BranchCompare.Control;
assign ID_PULSE = uut.ID_Stage.BranchCompare.pulse;


assign IDEX_RT = uut.IDEX.Out_RegRT;
assign EXMEM_RegDSTIn = uut.EXMEM.In_RegDst32;
assign EXMEM_RegDSTOut = uut.EXMEM.Out_RegDst;

assign ID_Controlsignal = uut.ID_Stage.ControlMux.out;

assign ID_Regwrite = uut.ID_Stage.Registers.RegWrite;








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
