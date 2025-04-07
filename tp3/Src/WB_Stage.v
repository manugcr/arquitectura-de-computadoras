module WB_Stage
#(
    parameter NB_DATA = 32, // Número de bits de datos
    parameter NB_ADDR = 5  // Número de bits de direcciones
)
(
    input   wire    [NB_DATA-1: 0]  i_reg_read,   // Dato leído desde la memoria
    input   wire    [NB_DATA-1: 0]  i_ALUresult, // Resultado de la ALU
    input   wire    [4:0]           i_reg2write, // Registro destino (rd o rt)

    input   wire                    i_mem2reg,   // 1 -> Guarda el valor leído desde memoria, 0 -> Guarda el valor de la ALU
    input   wire                    i_regWrite,  // Señal de control para escritura en registro

    output  wire    [NB_DATA-1: 0]  o_write_data, // Dato que se escribirá en el registro
    output  wire    [4:0]           o_reg2write,  // Registro de destino
    output  wire                    o_regWrite   // Señal de control para escritura en registro
);

    // Selecciona el dato a escribir dependiendo de i_mem2reg
    assign o_write_data = (i_mem2reg) ? i_reg_read : i_ALUresult;
    
    // Propaga el registro de destino
    assign o_reg2write = i_reg2write;
    
    // Propaga la señal de control de escritura
    assign o_regWrite  = i_regWrite;

endmodule