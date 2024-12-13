`timescale 1ns / 1ps

module ProgramCounter (
    input wire i_clk,           // Señal de reloj
    input wire i_reset,         // Señal de i_reset
    input wire [31:0] i_next_pc,  // Nueva dirección para el PC
    input wire pc_write,      // Habilitación para actualizar el PC
    output reg [31:0] o_pc  // Valor actual del PC
);

    always @(posedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            o_pc <= 32'b0;  // Reinicia el PC a 0
        end else if (pc_write) begin
            o_pc <= i_next_pc;  // Actualiza el PC con la nueva dirección
        end
        // Si pc_write es 0, mantiene el valor actual
    end

endmodule
