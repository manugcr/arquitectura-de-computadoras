`timescale 1ns / 1ps  

module IF_ID
    #(
        parameter PC_SIZE          = 32,  // Tamaño del contador de programa (Program Counter)
        parameter INSTRUCTION_SIZE = 32   // Tamaño de las instrucciones
    )
    (
        // Entradas del módulo
        input  wire                            i_clk,            
        input  wire                            i_reset,         
        input  wire                            i_enable,          // Señal de habilitación
      //  input  wire                            i_flush,           // Señal para limpiar el registro 
      //  input  wire                            i_halt,            // Señal de pausa (STOP)
        input  wire [PC_SIZE - 1 : 0]          i_next_seq_pc,     // Valor del siguiente contador de programa 
        input  wire [INSTRUCTION_SIZE - 1 : 0] i_instruction,     // Instrucción a almacenar

        // Salidas del módulo
      //  output wire                            o_halt,            // Salida para señal de pausa
        output wire [PC_SIZE - 1 : 0]          o_next_seq_pc,     // Salida del contador de programa almacenado
        output wire [INSTRUCTION_SIZE - 1 : 0] o_instruction      // Salida de la instrucción almacenada
    );

    // Registros internos para almacenar los valores de entrada
    reg [PC_SIZE - 1 : 0]          next_seq_pc;  // Registro para almacenar el PC
    reg [INSTRUCTION_SIZE - 1 : 0] instruction;  // Registro para almacenar la instrucción
    reg                            halt;         // Registro para almacenar la señal de pausa

    // Bloque sensible al flanco subida del reloj
    always @(posedge i_clk) 
    begin
        if (i_reset || i_flush) // Si se activa reset o STOP
            begin
                next_seq_pc <= 'b0;         // limpio PC
                instruction <= 'b0;         // Restablece la instrucción inicial
                halt        <= 1'b0;        // limpio señal de pausa
            end
        else if (i_enable) // Si está habilitado el registro
            begin
                next_seq_pc <= i_next_seq_pc; // Almacena el siguiente valor del PC
                instruction <= i_instruction; // Almacena la instrucción
                halt        <= i_halt;        // Almacena la señal de pausa
            end
    end

  
    assign o_next_seq_pc = next_seq_pc;  // Salida del contador de programa
    assign o_instruction = instruction; // Salida de la instrucción
    assign o_halt        = halt;        // Salida de la señal de pausa

endmodule