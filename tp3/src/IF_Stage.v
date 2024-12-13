`timescale 1ns / 1ps

// Módulo que implementa la etapa Instruction Fetch (IF) en un procesador.
module IF_Stage
    #(
        // Parámetros configurables del módulo
        parameter PC_SIZE = 32,                   // Tamaño del Program Counter (PC) en bits
        parameter WORD_SIZE_IN_BYTES = 4,         // Tamaño de una palabra en bytes
        parameter MEM_SIZE_IN_WORDS = 10          // Tamaño de la memoria de instrucciones en palabras
    )(
        // Entradas del módulo
        input wire i_clk,                         // Reloj
        input wire i_reset,                       // reinicio
     //   input wire i_halt,                        // Señal para detener la ejecución
     //   input wire pc_write,                    // Indica si no se debe cargar un nuevo PC
        input wire i_enable,                      // Habilita el módulo
        input wire i_next_pc_src,                 // Selecciona entre PC secuencial o no secuencial
        input wire i_write_mem,                   // Señal para escribir en memoria
        input wire i_clear_mem,                   // Señal para borrar la memoria
        input wire i_flush,                       // Señal para reiniciar el PC a su estado inicial
        input wire [WORD_SIZE_IN_BYTES*8 - 1 : 0] i_instruction, // Instrucción de entrada
        input wire [PC_SIZE - 1 : 0] i_next_not_seq_pc, // Siguiente PC no secuencial
        input wire [PC_SIZE - 1 : 0] i_next_seq_pc,     // Siguiente PC secuencial
        // Salidas del módulo
        output wire o_full_mem,                   // Indica si la memoria está llena
        output wire o_empty_mem,                  // Indica si la memoria está vacía
        output wire [WORD_SIZE_IN_BYTES*8 - 1 : 0] o_instruction, // Instrucción de salida
        output wire [PC_SIZE - 1 : 0] o_next_seq_pc, // Siguiente PC secuencial calculado
        output wire [PC_SIZE - 1 : 0] o_current_pc  // Valor actual del PC
    );
    
    // Tamaño del bus de datos, calculado a partir del tamaño de la palabra
    localparam BUS_SIZE = WORD_SIZE_IN_BYTES * 8;

    // Wires internos
    wire [PC_SIZE - 1 : 0] next_pc;  // Almacena el próximo valor del PC
    wire [PC_SIZE - 1 : 0] pc;       // Almacena el valor actual del PC

    // Conexión directa para enviar el valor actual del PC a la salida
    assign o_current_pc = pc;

    // Multiplexor que selecciona el próximo valor del PC (secuencial o no secuencial)
    Mux2to1 
    #() 
    mux_pc_unit
    (
        .select (i_next_pc_src),               // Selecciona entre PC secuencial o no secuencial
        .in0 (i_next_seq_pc),                   // Entradas del multiplexor
        .in1 (i_next_not_seq_pc),
        .out (next_pc)                     // Salida: próximo valor del PC
    );

    // Sumador para calcular el siguiente valor secuencial del PC
    adder 
    #
    (
        .BUS_SIZE(BUS_SIZE)
    ) 
    adder_unit 
    (
        .a (WORD_SIZE_IN_BYTES),                // Incremento basado en el tamaño de una palabra
        .b (pc),                                // Valor actual del PC
        .result(o_next_seq_pc)                     // Salida: próximo valor secuencial del PC
    );

    // Contador de programa (PC) que mantiene y actualiza el valor del PC
    ProgramCounter
    #(
        .PC_WIDTH(PC_SIZE)
    ) 
    pc_unit 
    (
        .i_clk (i_clk),                         // Reloj
        .i_reset (i_reset),                     // Reinicio
    //   .i_flush (i_flush),                     // Reinicia el PC a su valor inicial
    //    .i_clear (i_clear_mem),                 // Limpia la memoria
    //    .i_halt (i_halt),                       // Detiene la ejecución
        .pc_write(pc_write),                // Indica si no se debe cargar un nuevo PC
    //    .i_enable (i_enable),                   // Habilita el módulo
        .i_next_pc (next_pc),                   // Próximo valor del PC
        .o_pc (pc)                              // Salida: valor actual del PC
    );

    // Memoria de instrucciones para almacenar y recuperar instrucciones
    Instruction_Memory 
    #(
        .WORD_WIDTH_BYTES (WORD_SIZE_IN_BYTES), // Tamaño de cada palabra en bytes
        .MEM_SIZE_WORDS (MEM_SIZE_IN_WORDS),    // Tamaño de la memoria en palabras
        .PC_WIDTH (PC_SIZE)                     // Tamaño del PC
    ) 
    instruction_memory_unit 
    (
    //    .i_clk (i_clk),                        // Reloj
    //    .i_reset (i_reset),                    // Reinicio
    //    .i_inst_write (i_write_mem),           // Escritura en memoria
        .i_pc (pc),                            // Dirección actual (PC)
    //    .i_instruction (i_instruction),        // Instrucción a escribir en memoria
    //    .i_clear (i_clear_mem),                // Limpia la memoria
    //    .o_full_mem (o_full_mem),              // Indica si la memoria está llena
    //    .o_empty_mem (o_empty_mem),            // Indica si la memoria está vacía
        .o_instruction (o_instruction)         // Instrucción recuperada de memoria
    );

endmodule