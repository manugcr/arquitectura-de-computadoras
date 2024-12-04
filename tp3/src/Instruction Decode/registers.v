`timescale 1ns / 1ps

/*
    Descripción: Banco de registros configurable que permite realizar operaciones de lectura, escritura y reinicio.
                 Incluye soporte para depuración mostrando todos los registros mediante un bus de salida.

    Parámetros:
        - NUMBER_OF_REGISTERS: Número de registros en el banco (por defecto 32).
        - REGISTERS_SIZE: Ancho (en bits) de cada registro (por defecto 32).

    Entradas:
        - i_clk: Señal de reloj.
        - i_reset: Señal de reinicio global para limpiar todos los registros.
        - i_flush: Señal de limpieza (flush) para borrar los registros.
        - i_enable_wr: Señal de habilitación para la escritura.
        - i_A: Dirección del registro a leer en el bus A.
        - i_B: Dirección del registro a leer en el bus B.
        - i_wr: Dirección del registro donde se escribirá el dato.
        - i_data_wr: Dato a escribir en el registro especificado.

    Salidas:
        - o_data_A: Dato leído del registro direccionado por i_A.
        - o_data_B: Dato leído del registro direccionado por i_B.
        - o_Debugging: Bus de depuración que muestra el contenido completo de todos los registros.

    Notas:
        - Registro 0 siempre se mantiene en 0.
        - Compatible con configuraciones de bancos y tamaños de registros personalizables.
*/

module registers
    #(
        parameter NUMBER_OF_REGISTERS = 32,   // Número de registros en el banco
        parameter REGISTERS_SIZE = 32         // Ancho de cada registro
    )
    (
        // Entradas
        input  wire i_clk,                              // Entrada de reloj
        input  wire i_reset,                            // Entrada de reinicio
        input  wire i_flush,                            // Señal de limpieza (flush)
        input  wire i_enable_wr,                     // Señal de habilitación de escritura
        input  wire [$clog2(NUMBER_OF_REGISTERS) - 1 : 0] i_A, // Dirección para leer el registro A
        input  wire [$clog2(NUMBER_OF_REGISTERS) - 1 : 0] i_B, // Dirección para leer el registro B
        input  wire [$clog2(NUMBER_OF_REGISTERS) - 1 : 0] i_wr, // Dirección para escribir en el registro
        input  wire [REGISTERS_SIZE - 1 : 0] i_data_wr,  // Dato a escribir en el registro

        // Salidas
        output wire [REGISTERS_SIZE - 1 : 0] o_data_A,  // Dato leído del registro A
        output wire [REGISTERS_SIZE - 1 : 0] o_data_B,  // Dato leído del registro B
        output wire [NUMBER_OF_REGISTERS * REGISTERS_SIZE - 1 : 0] o_Debugging // Bus de depuración
    );
    
    // Declaración del banco de registros (matriz de registros)
    reg [REGISTERS_SIZE - 1 : 0] registers [NUMBER_OF_REGISTERS - 1 : 0]; 
    
    // Variable de iteración para inicialización de registros
    integer i; 
    
    // Bloque always: Se ejecuta en el flanco negativo del reloj
    always @(negedge i_clk) 
    begin
        if (i_reset || i_flush) 
        begin
            // Si se activa el reinicio o la limpieza, se ponen todos los registros a 0
            for (i = 0; i < NUMBER_OF_REGISTERS; i = i + 1)
                registers[i] <= 'b0;
        end
        else
        begin
            if (i_enable_wr)
            begin
                if (i_wr != 0)
                    // Escritura en el registro especificado
                    registers[i_wr] = i_data_wr;
                else
                    // Registro 0 se mantiene en 0
                    registers[i_wr] = 'b0;
            end
        end
    end

    // Asignación de datos a los buses de salida A y B
    assign o_data_A = registers[i_A];
    assign o_data_B = registers[i_B];

    // Generación del bus de depuración para mostrar el contenido de todos los registros
    generate
        genvar j;
        for (j = 0; j < NUMBER_OF_REGISTERS; j = j + 1) begin : GEN_DEBUG_BUS
            assign o_Debugging[(j + 1) * REGISTERS_SIZE - 1 : j * REGISTERS_SIZE] = registers[j];
        end
    endgenerate

endmodule
