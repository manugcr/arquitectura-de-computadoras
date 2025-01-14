`timescale 1ns / 1ps


// Este módulo selecciona los datos que se escribirán de vuelta en los registros en la etapa WB (Write Back).
// Utiliza un multiplexor de 3 entradas para decidir entre los datos leídos de memoria, el valor del PC o el resultado de la ALU.

module WB_Stage(
    MemToReg,       // Señal de control para seleccionar la fuente del dato a escribir.
    ALUResult,      // Resultado de la operación de la ALU.
    MemReadData,    // Datos leídos desde la memoria.
    PCAdder,        // Valor del PC actualizado.
    MemToReg_Out    // Salida: dato seleccionado para escribir de vuelta.
    );

    // Señal de control para seleccionar la fuente del dato a escribir:
    // 00: MemReadData, 01: PCAdder, 10: ALUResult.
    input [1:0] MemToReg;

    // Entradas de datos:
    input [31:0] ALUResult;     // Resultado de la ALU.
    input [31:0] MemReadData;   // Datos provenientes de la memoria.
    input [31:0] PCAdder;       // Dirección calculada del PC.

    // Salida: el dato seleccionado por el multiplexor.
    output wire [31:0] MemToReg_Out;

    // Multiplexor 3 a 1:
    // Selecciona la fuente del dato a escribir en base a la señal MemToReg.
    Mux3to1 MemToRegMux(
        .out(MemToReg_Out),     // Salida del multiplexor.
        .inA(MemReadData),      // Entrada A: datos de la memoria.
        .inB(PCAdder),          // Entrada B: valor del PC actualizado.
        .inC(ALUResult),        // Entrada C: resultado de la ALU.
        .sel(MemToReg)          // Selección de la entrada en función de MemToReg.
    );

endmodule
