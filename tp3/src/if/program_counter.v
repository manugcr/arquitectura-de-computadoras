module program_counter (
    input   wire            i_clk,
    input   wire            i_reset,
    input   wire            i_stall,
    input   wire            i_halt,
    input   wire            i_jump,
    input   wire    [31:0]  i_jump_addr,
    output  reg     [31:0]  o_pc
);

    always @(posedge i_clk or negedge i_reset) begin
        if (i_reset) begin
            o_pc <= 32'b0;
        end 
        else if (!i_stall && !i_halt) begin
            if (i_jump) begin
                o_pc <= i_jump_addr;    // Jump to indicated instruction
            end 
            else begin
                o_pc <= o_pc + 4;       // Instructions are 32 bits long (4 bytes)
            end
        end
    end

endmodule
