`timescale 1ns / 1ps

// Módulo de memoria de instrucciones que permite almacenar y leer instrucciones de 32 bits.
// La memoria tiene 10 palabras, cada una de 4 bytes direccionables, para un total de 40 bytes.
// Se implementan señales para reset, escritura, lectura y estado (memoria llena o vacía).

module Instruction_Memory
   #(
    // Parámetros configurables del módulo
    parameter PC_WIDTH = 32,            // Ancho del contador de programa (bits)
    parameter WORD_WIDTH_BITS = 32,     // Ancho de cada instrucción (bits)
    parameter WORD_WIDTH_BYTES = 4,     // Tamaño de cada instrucción (bytes)
    parameter MEM_SIZE_WORDS = 10,      // Número total de palabras en memoria
    parameter POINTER_SIZE = $clog2(MEM_SIZE_WORDS * WORD_WIDTH_BYTES) // Tamaño del puntero (bits necesarios para direccionar)
    )
    (
    // Entradas
    input wire i_clk,                   // Señal de reloj
    input wire i_reset,                 // Señal de reinicio para limpiar la memoria y el puntero
    input wire i_clear,                 // Señal para limpiar la memoria sin reiniciar
    input wire i_inst_write,            // Señal de escritura de instrucción
    input wire [PC_WIDTH-1:0] i_pc,     // Dirección del contador de programa para lectura
    input wire [WORD_WIDTH_BITS-1:0] i_instruction, // Instrucción a escribir en memoria
    
    // Salidas
    output wire [WORD_WIDTH_BITS-1:0] o_instruction, // Instrucción leída desde la memoria
    output wire o_full_mem,           // Señal que indica si la memoria está llena
    output wire o_empty_mem           // Señal que indica si la memoria está vacía
    );
    
    // Definición de parámetros locales
    localparam MEM_SIZE_BITS = MEM_SIZE_WORDS * WORD_WIDTH_BITS; // Tamaño total de la memoria en bits (10 palabras de 32 bits cada una)
    localparam BYTE_SIZE = 8;                                   // Tamaño de un byte en bits
    localparam MAX_POINTER_DIR = MEM_SIZE_WORDS * WORD_WIDTH_BYTES; // Número máximo de direcciones en memoria (40 bytes)
    
    // Registros internos
    reg [POINTER_SIZE-1:0] pointer;  // Puntero para indicar la posición actual de escritura
    reg [MEM_SIZE_BITS-1:0] memory; // Memoria de 10 palabras (40 bytes totales)
    
    // Bloque always para escritura en memoria y gestión del puntero
    always @(posedge i_clk)
    begin
        // Si se activa reset o clear, se limpian la memoria y el puntero
        if (i_reset || i_clear) 
            begin
                memory <= 'b0;       // Se pone la memoria en 0
                pointer <= 'b0;      // Se reinicia el puntero a 0
            end
        else 
            begin
                // Si la señal de escritura está activa, se almacena la instrucción
                if (i_inst_write) 
                    begin
                        // Se selecciona la posición en la memoria con el puntero y se escribe la instrucción
                        memory[BYTE_SIZE * pointer +: WORD_WIDTH_BITS] = i_instruction;
                        // `+:` selecciona un rango de bits:
                        // BYTE_SIZE * pointer calcula la posición inicial en bits,
                        // WORD_WIDTH_BITS define el rango de bits seleccionados (32 bits por instrucción).
                        
                        // Se incrementa el puntero en 4 (siguiente palabra en memoria)
                        pointer = pointer + WORD_WIDTH_BYTES;
                    end
            end
    end
    
    // Lectura de memoria
    assign o_instruction = memory[BYTE_SIZE * i_pc +: WORD_WIDTH_BITS];
    // Se selecciona y retorna la instrucción almacenada en la dirección especificada por i_pc.
    // BYTE_SIZE * i_pc calcula la posición inicial en bits para la lectura.

    // Señal que indica si la memoria está llena
    assign o_full_mem = (pointer == MAX_POINTER_DIR);
    // Se verifica si el puntero alcanzó el número máximo de direcciones posibles.

    // Señal que indica si la memoria está vacía
    assign o_empty_mem = (pointer == 'b0);
    // La memoria está vacía si el puntero está en la posición inicial (0).
    
endmodule

