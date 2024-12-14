module instruction_fetch (
    input   wire            i_clk,
    input   wire            i_reset,
    input   wire            i_jump,
    input   wire            i_halt,
    input   wire            i_stall,
    input   wire            i_write_enable,             // Write enable signal
    input   wire    [31:0]  i_instruction_addr,         // Instruction to write on memory
    input   wire    [31:0]  i_instruction_data,         // Addres to write the instruction
    input   wire    [31:0]  i_jump_addr,
    output  reg     [31:0]  o_instruction,              // This is where the instruction is stored
    output  wire    [31:0]  o_pc                        // Instruction address
);

    wire [31:0] instruction_data;                       // Data fetched from memory
    wire [31:0] instruction_addr;

    program_counter #(
    ) pc1 (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_jump_addr(i_jump_addr),
        .i_jump(i_jump),
        .i_stall(i_stall),
        .i_halt(i_halt),
        .o_pc(o_pc)
    );

    xilinx_one_port_ram_async #(
        .ADDR_WIDTH(8),
        .DATA_WIDTH(8)
    ) memory1 (
        .i_clk(i_clk),
        .i_write_enable(i_write_enable),
        .i_addr(instruction_addr[7:0]),
        .i_data(i_instruction_data),
        .o_data(instruction_data)
    );

    always @(posedge i_clk) begin
        if (i_reset) begin
            o_instruction <= 32'b0;
        end 
        else begin
            if (!i_stall && !i_halt) begin
                o_instruction <= instruction_data;      // Load instruction from data
            end
        end
    end

    assign instruction_addr = i_write_enable ? i_instruction_addr : o_pc;

endmodule
