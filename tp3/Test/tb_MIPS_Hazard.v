`timescale 1ns / 1ps

module tb_MIPS_Hazard;

// Entradas del sistema
reg ClockIn;
reg Reset;

// Salidas para monitoreo

wire RegWrite, RegWriteEXMEM,RegWriteEXSTAGE ;
wire [31:0] ALUResult_MEM_IN,A,B,ALUResultALU;
wire [31:0] RegRTData, WriteRegister_reg, WriteRegister, ReadData2_out,ReadData1_out;
wire [31:0] WriteData;


// Instancia del módulo principal MIPS
MIPS uut (
    .ClockIn(ClockIn),
    .Reset(Reset)
);

// Rutas para acceder a las señales de la etapa MEM


assign ALUResult_MEM_IN = uut.MEM_Stage.ALUResult;
assign RegRTData = uut.MEM_Stage.RegRTData;
assign RegWriteEXMEM = uut.EXMEM.Out_ControlSignal[2];
assign RegWriteEXSTAGE = uut.EX_Stage.ALU.RegWrite_Out;
assign A = uut.EX_Stage.ALU.A;
assign B = uut.EX_Stage.ALU.B;
assign ALUResultALU = uut.EX_Stage.ALU.ALUResult;
assign RegWrite  = uut.ID_Stage.Registers.RegWrite;
assign ReadData1_out  = uut.ID_Stage.ReadData1_out;
assign ReadData2_out  = uut.ID_Stage.ReadData2_out;
assign WriteData =  uut.ID_Stage.Registers.WriteData;
assign WriteRegister_reg = uut.ID_Stage.Registers.WriteRegister_reg;
assign WriteRegister = uut.ID_Stage.Registers.WriteRegister;




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
