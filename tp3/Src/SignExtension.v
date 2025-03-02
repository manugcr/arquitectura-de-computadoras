`timescale 1ns / 1ps

// Módulo para realizar la extensión de signo de 16 bits a 32 bits
module SignExtension(in, out);

    /* Entrada de 16 bits. Representa un número de 16 bits a ser extendido. */
    input [15:0] in;
    
    /* Salida de 32 bits. Contendrá el valor extendido a 32 bits. */
    output reg [31:0] out;
    
    always @(in) begin
        if (in[15] == 1) 
            // Si el MSB (bit 15) de `in` es 1, el número es negativo.
            // Se extiende rellenando los 16 bits superiores con `1`s (16'hFFFF).
            out = {16'hFFFF, in};
        else 
            // Si el MSB (bit 15) de `in` es 0, el número es positivo.
            // Se extiende rellenando los 16 bits superiores con `0`s (16'h0000).
            out = {16'h0000, in};
    end

endmodule
