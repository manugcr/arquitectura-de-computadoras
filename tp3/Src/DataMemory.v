`timescale 1ns / 1ps



module DataMemory(Address, WriteData, Clock, MemWrite, MemRead, ReadData);

    input [31:0] Address;       // Dirección de memoria (32 bits)
    input [31:0] WriteData;     // Datos a escribir en memoria (32 bits)
    input Clock;                // Señal de reloj
    input MemWrite;             // Señal de control para escritura
    input MemRead;              // Señal de control para lectura

    output reg [31:0] ReadData; // Datos leídos de memoria (32 bits)

    reg [31:0] memory [0:13600]; // Memoria de datos: 13601 palabras de 32 bits
    
    integer i;

    // Inicialización de la memoria desde un archivo
    initial begin
        $readmemh("Data_memory.mem", memory,0,13600); // Archivo para valores iniciales
        
         for (i = 0; i < 13600; i = i + 1) begin
            memory[i] = i;
        end


        // Crea o limpia el archivo registers.mem
        $writememh("Data_memory.mem", memory);
    end

    // Escritura en memoria
    always @ (posedge Clock) begin
        if (MemWrite == 1'b1) begin
            memory[Address[31:2]] <= WriteData; // Escritura de palabra completa
        end
    end

    // Lectura de memoria
    always @ (*) begin
        if (MemRead == 1'b1) begin
            ReadData <= memory[Address[31:2]]; // Lectura de palabra completa
        end else begin
            ReadData <= 32'b0; // Si no se lee, salida en 0
        end
    end

endmodule
