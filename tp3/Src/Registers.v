`timescale 1ns / 1ps

module Registers(
    input [4:0] ReadRegister1, ReadRegister2, WriteRegister,
    input [31:0] WriteData,
    input RegWrite, Clock,
    output reg [31:0] ReadData1, ReadData2
);

    reg [31:0] registers [0:31];
   // reg [31:0] WriteData_reg;
    reg [4:0] WriteRegister_reg;

    // Inicialización de los registros
    integer i;
    initial begin
        // Inicializa todos los registros a 0
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] = i;
        end
        // Inicializa el puntero de pila (registro 29)
        registers[29] = 54400;

        // Crea o limpia el archivo registers.mem
        $writememh("registers.mem", registers);
    end

    // Escritura sincronizada con el flanco de subida del reloj
    always @(posedge Clock) begin
        if (RegWrite) begin
            // Almacena las señales intermedias en registros
           // WriteData_reg <= WriteData;
            WriteRegister_reg <= WriteRegister;

            // Escribe en el registro alineando WriteData y WriteRegister
            registers[WriteRegister_reg] <= WriteData;

            // Actualiza el archivo de memoria para depuración
            $writememh("registers.mem", registers);
        end
    end

    // Lectura combinacional
    always @(*) begin
        ReadData1 = registers[ReadRegister1];
        ReadData2 = registers[ReadRegister2];
    end

endmodule
