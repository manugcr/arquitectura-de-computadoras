`timescale 1ns / 1ps

// Módulo para realizar un desplazamiento lógico a la izquierda por 2 bits
module ShiftLeft2(inputNum, outputNum);

    input [31:0] inputNum;

    output reg [31:0] outputNum;
    
  
    always @(inputNum) begin
        // Desplaza los bits de `inputNum` 2 posiciones a la izquierda
        outputNum = inputNum << 2;
    end

endmodule
