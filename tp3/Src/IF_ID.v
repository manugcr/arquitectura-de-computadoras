`timescale 1ns / 1ps

module IF_ID(
    Clock,         // Señal de reloj para sincronización
    Enable,        // Señal para habilitar la escritura en los registros
    In_Instruction, // Entrada de la instrucción actual
    In_Branch,
    Out_Instruction, // Salida de la instrucción almacenada
    In_PCAdder,     // Entrada del valor del PC sumado
    Flush,
    Out_PCAdder,    // Salida del valor del PC sumado almacenado
    Out_BrachAddress, // Salida del valor anterior del PC sumado
    Out_Branch,
    i_enable,        //DEBUGG
    i_flush
);

    // Declaración de entradas
    input        Flush, Clock, Enable;
    input [31:0] In_Instruction;
    input [31:0] In_PCAdder;
    input        In_Branch;
    input        i_enable;
    input        i_flush;

    // Declaración de salidas
    output reg [31:0] Out_Instruction;     // Almacena la instrucción
    output reg [31:0] Out_BrachAddress;     // Almacena el valor anterior del PC sumado
    output reg [31:0] Out_PCAdder;         // Almacena el valor del PC sumado
    output reg Out_Branch;


    // Comportamiento del registro sincronizado con el flanco positivo del reloj
    always @(posedge Clock) begin
         if (Flush || i_flush) begin
         //   if (Flush ) begin
            Out_Instruction <= 32'd0;
            Out_Branch      <=  1'd0;           //OJOOOO
          //  Out_PCAdder     = 32'd0;  VER SI ESTO ROMPE ALGO ojoooooooooooo
        end
         else if (Enable && i_enable) begin     // ojoooooOOOOO
            // Si Enable está activo, actualiza los registros con las entradas
          //  else if (Enable ) begin     // ojoooooOOOOO
            Out_Instruction <= In_Instruction;
            Out_PCAdder     <= In_PCAdder;
            Out_Branch      <=  In_Branch;
 
            Out_BrachAddress <= {16'h0000, In_Instruction[15:0]};  // Desplazamiento sin signo

        end
    end

endmodule