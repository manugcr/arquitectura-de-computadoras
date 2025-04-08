module IF_Stage
(
    input wire          clk,
    input wire          i_rst_n,   
    input wire          i_jump,          //! 1 = jump asserted | 0 = normal PC increment
    input wire          i_we,            //! Write enable para inicializar memoria
    input wire [31:0]   i_addr2jump,     //! Dirección a saltar
    input wire [31:0]   i_instr_data,    //! Dato a escribir si i_we está en 1
    input wire [31:0]   i_inst_addr,     //! Dirección para escribir instrucción
    input wire          i_halt,          //! Halt del pipeline
    input wire          i_stall,         //! Stall del pipeline
    output wire [31:0]  o_instruction,   //! Instrucción registrada (salida del IFID)
    output wire [31:0]  o_pcounter       //! Program counter
);

    wire [31:0] instruction_data;
    wire [7:0]  instruction_addr;

    //! PC module
    PC pc1 (
        .clk        (clk),
        .i_rst_n    (i_rst_n),
        .i_addr2jump(i_addr2jump),
        .i_jump     (i_jump),
        .o_pcounter (o_pcounter),
        .i_halt     (i_halt),
        .i_stall    (i_stall)
    );

    //! RAM de instrucciones
    RAM #(
        .NB_DATA(32),
        .NB_ADDR(8)
    ) InstructionMemory (
        .clk              (clk),
        .i_write_enable   (i_we),
        .i_data           (i_instr_data),
        .i_addr_w         (instruction_addr),
        .o_data           (instruction_data)
    );

    //! Selección de dirección: para escribir (i_we) o para fetch
    assign instruction_addr = i_we ? i_inst_addr[7:0] : o_pcounter[7:0];

    //! IF/ID register instanciado internamente
    IFID ifid_sreg (
        .clk           (clk),
        .i_rst_n       (i_rst_n),
        .i_halt        (i_halt),
        .i_stall       (i_stall),
        .i_instruction (instruction_data),
        .o_instruction (o_instruction)
    );

endmodule
