`timescale 1ns / 1ps

module Registers(
    ReadRegister1, ReadRegister2, WriteRegister, WriteData, 
    RegWrite, Clock, ReadData1, ReadData2, V0, V1
);

    // Puertos de entrada
    input [4:0] ReadRegister1, ReadRegister2, WriteRegister; // Direcciones de 5 bits de los registros
    input [31:0] WriteData;                                 // Datos a escribir en el registro
    input RegWrite;                                         // Señal de habilitación para la escritura
    input Clock;                                            // Señal de reloj

    // Puertos de salida
    output reg [31:0] ReadData1, ReadData2; // Datos leídos de los registros
    output reg [31:0] V0, V1;               // Salidas para los registros 2 y 3

    // Archivo de registros interno: 32 registros, cada uno de 32 bits
    reg [31:0] registers [0:31];
    
    // Inicialización de los registros
    integer i; // Variable de iteración
    initial begin
        // Se inicializan todos los registros en 0
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] = 0;
        end

        // Se inicializa el puntero de pila (registro 29) con un valor predefinido
        registers[29] = 54400;
    end

    // Operación de escritura (asíncrona)
    always @(*) begin
        // Si RegWrite está activa, escribe WriteData en el registro especificado
        if (RegWrite) begin
            registers[WriteRegister] <= WriteData;
        end
    end

    // Operación de lectura (sincrónica, activada en el flanco de bajada del reloj)
    always @(negedge Clock) begin
        // Lee los datos de los registros especificados por ReadRegister1 y ReadRegister2
        ReadData1 <= registers[ReadRegister1];
        ReadData2 <= registers[ReadRegister2];

        // Actualiza los registros especiales V0 (registro 2) y V1 (registro 3)
        V0 = registers[2];
        V1 = registers[3];
    end

endmodule
