`timescale 1ns / 1ps

// Este módulo realiza una extensión de signo o una extensión con ceros de un valor de entrada.
// El tipo de extensión se determina mediante la señal de control `i_is_signed`.

module sign_extension
    #(
        // Parámetro: Tamaño original del valor de entrada
        parameter DATA_ORIGINAL_SIZE = 16,

        // Parámetro: Tamaño extendido del valor de salida
        parameter DATA_EXTENDED_SIZE = 32
    )
    (
        // Entrada: Valor que se va a extender
        input wire [DATA_ORIGINAL_SIZE - 1 : 0] i_value,

        // Entrada: Señal de control
        // i_is_signed = 1 -> Realizar extensión de signo (preservar el bit de signo)
        // i_is_signed = 0 -> Realizar extensión con ceros (rellenar con ceros)
        input wire i_is_signed,

        // Salida: Valor extendido
        output wire [DATA_EXTENDED_SIZE - 1 : 0] o_extended_value
    );

    // Lógica:
    // Si `i_is_signed` es 1 (extensión de signo), se replica el MSB de `i_value`
    // para rellenar los bits más significativos del valor extendido.
    // En caso contrario, los bits más significativos se rellenan con ceros para una extensión sin signo.
    assign o_extended_value = i_is_signed ? 
        // Extensión de signo: Replicar el MSB de `i_value`
        {{(DATA_EXTENDED_SIZE - DATA_ORIGINAL_SIZE){i_value[DATA_ORIGINAL_SIZE - 1]}}, i_value} : 
        // Extensión con ceros: Rellenar los bits superiores con 0
        {{(DATA_EXTENDED_SIZE - DATA_ORIGINAL_SIZE){1'b0}}, i_value};

endmodule
