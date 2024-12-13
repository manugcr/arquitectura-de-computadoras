`timescale 1ns / 1ps

module Mux2to1 (
    input wire [31:0] in0,     // Primera entrada (por ejemplo, PC + 4)
    input wire [31:0] in1,     // Segunda entrada (por ejemplo, dirección de salto)
    input wire select,         // Señal de selección
    output reg [31:0] out      // Salida
);

    always @(*) begin
        if (select) begin
            out = in1;         // Selecciona la segunda entrada
        end else begin
            out = in0;         // Selecciona la primera entrada
        end
    end

endmodule
