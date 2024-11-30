`timescale 1ns / 1ps

module mux
    #(
        parameter CHANNELS = 2,              // Número de canales de entrada (por defecto es 2)
        parameter BUS_SIZE = 32              // Ancho de cada bus de datos (por defecto es de 32 bits)
    )
    (
        input  wire [$clog2(CHANNELS) - 1 : 0]    selector,  // Entrada selector, se usa para elegir qué canal se pasa a la salida
        input  wire [CHANNELS * BUS_SIZE - 1 : 0] data_in,   // Bus de datos de entrada, que contiene los datos de todos los canales
        output wire [BUS_SIZE - 1 : 0]            data_out    // Salida de datos, el ancho es igual a BUS_SIZE
    );

        // Si el selector es válido, la salida se calcula desplazando la señal data_in.
        // Si el selector es inválido (estado de alta impedancia), la salida se pone en alta impedancia (1'bz).
        assign data_out = selector !== { $clog2(CHANNELS) {1'bx} } ? data_in >> BUS_SIZE * selector : { BUS_SIZE {1'bz} };    

    /* 
        - Si el selector es válido: La salida se calcula desplazando los datos de entrada según el valor del selector.
        - Si el selector es inválido (es decir, todos los bits son 'x'): La salida se pone en alta impedancia (1'bz).
        
        Ejemplo para CHANNELS = 2:
            - selector = 0: data_out = data_in[31:0]  (canal 0).
            - selector = 1: data_out = data_in[63:32] (canal 1).
        
        Ejemplo para CHANNELS = 4 (NO USADO):
            - El selector tiene 2 bits, por lo que puede ser 00, 01, 10 o 11.
            - selector = 00: data_out = data_in[31:0]  (canal 0).
            - selector = 01: data_out = data_in[63:32] (canal 1).
            - selector = 10: data_out = data_in[95:64] (canal 2).
            - selector = 11: data_out = data_in[127:96] (canal 3).

        - 1'bz: Esto representa alta impedancia, que se usa cuando no se fuerza un valor específico en el bus.
          Permite que otras señales manejen el bus en lugar de una sola fuente.
    */

endmodule
