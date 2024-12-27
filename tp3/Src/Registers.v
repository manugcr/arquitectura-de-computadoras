`timescale 1ns / 1ps

module Registers(
    input [4:0] ReadRegister1, ReadRegister2, WriteRegister, // Direcciones de 5 bits
    input [31:0] WriteData,                                  // Datos de escritura
    input RegWrite,                                          // Señal de escritura habilitada
    input Clock,                                             // Reloj
    output reg [31:0] ReadData1, ReadData2,                  // Salidas de lectura
    output [31:0] V0, V1                                     // Alias para registros especiales
);

    // Archivo de registros interno: 32 registros de 32 bits
    reg [31:0] registers [0:31];
    
    // Inicialización de los registros
    integer i;
    initial begin
        // Inicializa todos los registros a 0
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] = 0;
        end
        // Inicializa el puntero de pila (registro 29)
        registers[29] = 54400;

        // Crea o limpia el archivo registers.mem
        $writememh("registers.mem", registers);
    end

    // Escritura sincronizada en el flanco de subida del reloj
    always @(posedge Clock) begin
        if (RegWrite) begin
            registers[WriteRegister] <= WriteData;
        end
        // Actualiza el archivo registers.mem después de cada operación de escritura
        $writememh("registers.mem", registers);
    end

    // Lectura asíncrona de los registros
    always @(*) begin
        ReadData1 = registers[ReadRegister1];
        ReadData2 = registers[ReadRegister2];
    end

    // Alias para los registros especiales
    assign V0 = registers[2];
    assign V1 = registers[3];

endmodule
