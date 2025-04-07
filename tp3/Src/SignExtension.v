module SignExtension
#(
    parameter NB_IMM = 16, // Número de bits del inmediato
    parameter NB_DATA = 32 // Número de bits de datos de salida
)
(
    input wire                  i_immediate_flag,   // Indica si el inmediato es con signo o sin signo
    input wire  [NB_IMM-1:0]    i_immediate_value,  // Valor inmediato de entrada
    output wire [NB_DATA-1:0]   o_data             // Valor extendido a 32 bits
);

// Extensión de signo o extensión con ceros dependiendo de i_immediate_flag
assign o_data = i_immediate_flag ? 
                {{16{i_immediate_value[NB_IMM-1]}}, i_immediate_value} : // Extiende con signo
                {16'b0, i_immediate_value}; // Extiende con ceros

endmodule