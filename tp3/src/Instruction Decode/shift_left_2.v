`timescale 1ns / 1ps

// Este módulo realiza un desplazamiento lógico a la izquierda de un valor de entrada.
// El número de posiciones a desplazar es definido mediante un parámetro (por defecto, 2).

module shift_left
    #(
        // Parámetros configurables
        parameter DATA_LEN = 32,       // Longitud de los datos (bits)
        parameter POS_TO_SHIFT = 2    // Número de posiciones a desplazar
    )
    (
        // Puertos de entrada y salida
        input  wire [DATA_LEN - 1 : 0] i_value,    // Valor de entrada
        output wire [DATA_LEN - 1 : 0] o_shifted  // Valor desplazado
    );

    // Operación de desplazamiento lógico a la izquierda
    // El resultado se almacena en la salida `o_shifted`.
    assign o_shifted = i_value << POS_TO_SHIFT;

endmodule
