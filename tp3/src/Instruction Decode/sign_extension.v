`timescale 1ns / 1ps

// Este módulo realiza una extensión de signo o una extensión con ceros de un valor de entrada.
// El tipo de extensión se determina mediante la señal de control `i_flag_signed`.

module sign_extension
    #(
        // Parámetro: Tamaño original del valor de entrada
        parameter ORIGINAL_SIZE = 16,

        // Parámetro: Tamaño extendido del valor de salida
        parameter EXTENDED_SIZE = 32
    )
    (
        // Entrada: Valor que se va a extender
        input wire [ORIGINAL_SIZE - 1 : 0] i_data,

        // Entrada: Señal de control
        // i_flag_signed = 1 -> Realizar extensión de signo (preservar el bit de signo)
        // i_flag_signed = 0 -> Realizar extensión con ceros (rellenar con ceros)
        input wire i_flag_signed,

        // Salida: Valor extendido
        output wire [EXTENDED_SIZE - 1 : 0] o_ext_data
    );

    // Lógica:
    // Si `i_flag_signed` es 1 (extensión de signo), se replica el MSB de `i_data`
    // para rellenar los bits más significativos del valor extendido.
    // En caso contrario, los bits más significativos se rellenan con ceros para una extensión sin signo.
    assign o_ext_data = i_flag_signed ? 
        // Extensión de signo: Replicar el MSB de `i_data`
        {{(EXTENDED_SIZE - ORIGINAL_SIZE){i_data[ORIGINAL_SIZE - 1]}}, i_data} : 
        // Extensión con ceros: Rellenar los bits superiores con 0
        {{(EXTENDED_SIZE - ORIGINAL_SIZE){1'b0}}, i_data};

endmodule
