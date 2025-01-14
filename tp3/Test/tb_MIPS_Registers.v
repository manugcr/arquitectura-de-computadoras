`timescale 1ns / 1ps

module tb_MIPS_Registers;

// Entradas del sistema
reg ClockIn;
reg Reset;

// Salidas para monitoreo
wire [31:0] V0, V1; // Registros especiales para observar

// Señales para monitorear el banco de registros
wire [31:0] ReadData1, ReadData2; // Datos leídos de los registros
wire [4:0] WriteRegister;         // Registro de destino para escritura
wire [31:0] WriteData;            // Datos escritos en el registro
wire RegWrite;                    // Señal de escritura habilitada

// Instancia del módulo principal MIPS
MIPS uut (
    .ClockIn(ClockIn),
    .Reset(Reset)
);

// Rutas para acceder a las señales del banco de registros dentro de ID_Stage
assign ReadData1 = uut.ID_Stage.ReadData1;
assign ReadData2 = uut.ID_Stage.ReadData2;
assign WriteRegister = uut.ID_Stage.Registers.WriteRegister;
assign WriteData = uut.ID_Stage.Registers.WriteData;
assign RegWrite = uut.ID_Stage.Registers.RegWrite;


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

    // Simulación de instrucciones para probar el banco de registros
    #20; // Esperar sincronización del primer ciclo

    // Escribir un valor en el registro 5
    $display("Escribiendo en el registro 5");
    wait(RegWrite && WriteRegister == 5);
    #1 $display("WriteRegister = %d, WriteData = %h", WriteRegister, WriteData);

    // Leer los valores de los registros 5 y 6
    #20;
    $display("Leyendo registros");
    $display("ReadData1 (Reg 5) = %h, ReadData2 (Reg 6) = %h", ReadData1, ReadData2);

    // Escribir un valor en el registro 6
    #20;
    $display("Escribiendo en el registro 6");
    wait(RegWrite && WriteRegister == 6);
    #1 $display("WriteRegister = %d, WriteData = %h", WriteRegister, WriteData);

    // Leer nuevamente los valores de los registros 5 y 6
    #20;
    $display("Leyendo registros nuevamente");
    $display("ReadData1 (Reg 5) = %h, ReadData2 (Reg 6) = %h", ReadData1, ReadData2);

    // Verificar valores especiales (V0 y V1)
    #20;
    $display("Verificando registros especiales");
    $display("V0 = %h, V1 = %h", V0, V1);

    // Finalizar la simulación
    #50;
    $stop;
end

endmodule


