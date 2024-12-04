`timescale 1ns / 1ps

// Este módulo realiza un desplazamiento lógico a la izquierda de un valor de entrada.
// El número de posiciones a desplazar es definido mediante un parámetro (por defecto, 2).

module shift_left_2
    #(
        // Parámetros configurables
        parameter SIZE = 32,       // Longitud de los datos (bits)
        parameter SHIFT = 2    // Número de posiciones a desplazar
    )
    (
        // Puertos de entrada y salida
        input  wire [SIZE - 1 : 0] i_noshift,    // Valor de entrada
        output wire [SIZE - 1 : 0] o_shift  // Valor desplazado
    );

    // Operación de desplazamiento lógico a la izquierda
    // El resultado se almacena en la salida `o_shift`.
    assign o_shift = i_noshift << SHIFT;

endmodule
