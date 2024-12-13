`timescale 1ns / 1ps

module InstructionMemory (
    input wire [31:0] i_pc,    // Dirección proporcionada por el PC
    output reg [31:0] instruction // Instrucción leída de la memoria
);

    // Declaración de la memoria: 256 palabras de 32 bits (puedes ajustar el tamaño según lo necesites)
    reg [31:0] memory [0:255];

    // PC me tira la direccion 0000 0004 = 00000000000000000000000000000100

    // Inicialización de la memoria (opcional)
    initial begin
        // Carga instrucciones en memoria (puedes personalizar estas)
        memory[0] = 32'h00000001; // Ejemplo: ADD $r0, $r0, $r1
        memory[1] = 32'h00000002; // Ejemplo: SUB $r2, $r2, $r3
        memory[2] = 32'h00000003; // Ejemplo: JUMP a dirección X
        // Puedes cargar más instrucciones aquí...
    end

    // Lectura de la instrucción basada en la dirección (dividida por 4 porque las direcciones son byte-aligned)
    always @(*) begin
        instruction = memory[i_pc[31:2]]; // Dirección alineada a 4 bytes
    end

endmodule
