`timescale 1ns / 1ps

module tb_MIPS_DataMemory;

// Entradas del sistema
reg ClockIn;
reg Reset;

// Salidas para monitoreo
wire MemWrite;
wire MemRead;
wire RegWrite;
wire [31:0] MemReadData;
wire [31:0] ALUResult_MEM;
wire [3:0] ByteSig;
wire [31:0] RegRTData, WriteRegister_reg, WriteRegister;
wire [31:0] WriteData;


// Instancia del módulo principal MIPS
MIPS uut (
    .ClockIn(ClockIn),
    .Reset(Reset)
);

// Rutas para acceder a las señales de la etapa MEM
assign MemWrite = uut.MEM_Stage.MemWrite;
assign MemRead = uut.MEM_Stage.MemRead;
assign MemReadData = uut.MEM_Stage.MemReadData;
assign ALUResult_MEM = uut.MEM_Stage.ALUResult;
assign ByteSig = uut.MEM_Stage.ByteSig;
assign RegRTData = uut.MEM_Stage.RegRTData;
assign RegWrite  = uut.ID_Stage.Registers.RegWrite;
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
    #20;

    // Monitoreo de la etapa MEM
    $display("Iniciando pruebas en la etapa MEM");

    // Monitorear escritura en memoria
    wait(MemWrite);
    #1 $display("[Escritura] MemWrite = %b, ALUResult = %h, RegRTData = %h", MemWrite, ALUResult_MEM, RegRTData);

    // Monitorear lectura de memoria
    wait(MemRead);
    #1 $display("[Lectura] MemRead = %b, ALUResult = %h, MemReadData = %h", MemRead, ALUResult_MEM, MemReadData);

    // Monitorear ByteSig
    #20;
    $display("[ByteSig] ByteSig = %h", ByteSig);

    // Finalizar la simulación
    #50;
    $stop;
end

endmodule
