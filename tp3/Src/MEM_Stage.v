`timescale 1ns / 1ps


module MEM_Stage(

    Clock,           // Reloj del sistema
    MemWrite,        // Señal de control para escritura en memoria
    MemRead,         // Señal de control para lectura de memoria
    ALUResult,       // Resultado de la ALU (dirección de memoria)
    RegRTData,       // Datos del registro RT (a escribir en memoria)    
    MemReadData,      // Datos leídos de la memoria
    ByteSig     
    );             

    // Reloj del sistema
    input Clock;
          
    // Señales de control para la memoria     
    input MemWrite;  // Activa la escritura en memoria
    input MemRead;   // Activa la lectura de memoria
    
    // Dirección generada por la ALU
    input [31:0] ALUResult;
    
    // Datos del registro RT para escribir en memoria
    input [31:0] RegRTData;

    input [1:0] ByteSig;

    output wire [31:0] MemReadData;


    DataMemory DataMem(
        .Address(ALUResult), 
        .WriteData(RegRTData), 
        .Clock(Clock), 
        .MemWrite(MemWrite), 
        .MemRead(MemRead), 
        .ReadData(MemReadData),
        .ByteSig(ByteSig));


endmodule
