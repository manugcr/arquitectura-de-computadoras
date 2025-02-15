`timescale 1ns / 1ps

module tb_MIPS_Branch;

// Entradas del sistema
reg ClockIn;
reg Reset;

// Salidas para monitoreo



wire [31:0]  EX_ALUResult,IF_PC,IF_Instruction,IFID_Instruction,IDEX_ReadData1,IDEX_ReadData2,WriteData;
wire IFID_Flush;


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

assign IF_PCsel = IF_Stage.PCSrcMux.sel;
assign IF_PCinA = IF_Stage.PCSrcMux.inA;
assign IF_PCinB = IF_Stage.PCSrcMux.inB;
assign IF_PCinB = IF_Stage.PCSrcMux.inC;


assign EX_ALUResult = uut.EX_Stage.ALU.ALUResult;


assign IFID_Flush = uut.IFID.Flush;








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
