timescale 1ns / 1ps

// Módulo de igualdad: compara dos datos de entrada y genera una señal de salida
// indicando si son iguales o no.
module equality
    #(
        parameter DATA_LEN = 32 // Parámetro configurable: longitud de los datos a comparar
    )
    (
        // Entradas:
        input  wire [DATA_LEN - 1 : 0] i_data_A, // Primer dato de entrada
        input  wire [DATA_LEN - 1 : 0] i_data_B, // Segundo dato de entrada
        
        // Salida:
        output wire o_is_equal // Señal de salida: 1 si los datos son iguales, 0 si no lo son
    );

    // Lógica de comparación:
    // Compara `i_data_A` con `i_data_B` y asigna 1 a `o_is_equal` si son iguales.
    // Si los datos son diferentes, `o_is_equal` será 0.
    assign o_is_equal = i_data_A == i_data_B; 

endmodule
