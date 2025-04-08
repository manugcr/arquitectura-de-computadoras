module EXMEM #(
    parameter NB_DATA = 32,
    parameter NB_REG  = 5
)(
    input  wire                 clk,
    input  wire                 i_rst_n,
    input  wire                 i_halt,

    // Señales de control y datos
    input  wire                 i_mem2reg,
    input  wire                 i_memRead,
    input  wire                 i_memWrite,
    input  wire                 i_regWrite,
    input  wire [1:0]           i_aluSrc,
    input  wire [1:0]           i_width,
    input  wire                 i_sign_flag,
    input  wire [2:0]           i_aluOP,
    input  wire [NB_DATA-1:0]   i_result,
    input  wire [NB_DATA-1:0]   i_data4Mem,

    // Write register
    input  wire                 i_regDst,
    input  wire [NB_REG-1:0]    i_rd,
    input  wire [NB_REG-1:0]    i_rt,

    output reg                  o_mem2reg,
    output reg                  o_memRead,
    output reg                  o_memWrite,
    output reg                  o_regWrite,
    output reg [1:0]            o_aluSrc,
    output reg [1:0]            o_width,
    output reg                  o_sign_flag,
    output reg [2:0]            o_aluOP,
    output reg [NB_DATA-1:0]    o_result,
    output reg [NB_DATA-1:0]    o_data4Mem,
    output reg [NB_REG-1:0]     o_write_reg
);

    // Registro de o_write_reg (solo con clk positivo)
     //! when asserted The register destination number for the Write registeW
    //! comes from the rd field.
    //! when deasserted The register destination number for the Write register
    //! comes from the rt field
    // === Instancia del pipeline register EXMEM ===
    always @(posedge clk) begin
        if (!i_rst_n) begin
            o_write_reg <= {NB_REG{1'b0}};
        end else if (!i_halt) begin
            o_write_reg <= i_regDst ? i_rt : i_rd;
        end
    end

    // Registros del resto de señales (clk y rst_n asíncrono)
    always @(posedge clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            o_mem2reg    <= 1'b0;
            o_memRead    <= 1'b0;
            o_memWrite   <= 1'b0;
            o_regWrite   <= 1'b0;
            o_aluSrc     <= 2'b00;
            o_width      <= 2'b11;
            o_sign_flag  <= 1'b0;
            o_aluOP      <= 3'b000;
            o_result     <= {NB_DATA{1'b0}};
            o_data4Mem   <= {NB_DATA{1'b0}};
        end else if (!i_halt) begin
            o_mem2reg    <= i_mem2reg;
            o_memRead    <= i_memRead;
            o_memWrite   <= i_memWrite;
            o_regWrite   <= i_regWrite;
            o_aluSrc     <= i_aluSrc;
            o_width      <= i_width;
            o_sign_flag  <= i_sign_flag;
            o_aluOP      <= i_aluOP;
            o_result     <= i_result;
            o_data4Mem   <= i_data4Mem;
        end
    end

endmodule
