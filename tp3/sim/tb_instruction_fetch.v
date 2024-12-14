`timescale 1ns / 1ps

module tb_instruction_fetch;

    // Inputs
    reg i_clk;
    reg i_reset;
    reg i_jump;
    reg i_halt;
    reg i_stall;
    reg i_write_enable;
    reg [31:0] i_instruction_addr;
    reg [31:0] i_instruction_data;
    reg [31:0] i_jump_addr;

    // Outputs
    wire [31:0] o_instruction;
    wire [31:0] o_pc;

    // Instantiate the Device Under Test
    instruction_fetch uut (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_jump(i_jump),
        .i_halt(i_halt),
        .i_stall(i_stall),
        .i_write_enable(i_write_enable),
        .i_instruction_addr(i_instruction_addr),
        .i_instruction_data(i_instruction_data),
        .i_jump_addr(i_jump_addr),
        .o_instruction(o_instruction),
        .o_pc(o_pc)
    );

    // Clock Generation
    always #5 i_clk = ~i_clk; // 10ns clock period

    initial begin
        // Initialize Inputs
        i_clk               = 0;
        i_reset             = 1;
        i_jump              = 0;
        i_halt              = 0;
        i_stall             = 0;
        i_write_enable      = 0;
        i_instruction_addr  = 0;
        i_instruction_data  = 0;
        i_jump_addr         = 0;

        // Apply reset
        #10;
        i_reset = 0;

        // Write some instructions into memory
        #10;
        i_write_enable      = 1;
        i_instruction_addr  = 32'h00000000;
        i_instruction_data  = 32'h12345678; // First instruction
        #10;
        i_instruction_addr  = 32'h00000004;
        i_instruction_data  = 32'hDEADBEEF; // Second instruction
        #10;
        i_instruction_addr  = 32'h00000008;
        i_instruction_data  = 32'hCAFEBABE; // Third instruction
        #10;
        i_write_enable      = 0;

        // Normal Fetch
        #10;
        i_stall = 0;
        i_halt  = 0;

        // Jump to address
        #10;
        i_jump      = 1;
        i_jump_addr = 32'h00000008;
        #10;
        i_jump      = 0;

        // Stall PC
        #10;
        i_stall = 1;
        #20;
        i_stall = 0;

        // Halt PC
        #10;
        i_halt = 1;
        #20;
        i_halt = 0;

        // End simulation
        #50;
        $finish;
    end

    // Dump waves for GTKWave
    initial begin
        $dumpfile("tb_instruction_fetch.vcd");
        $dumpvars(0, tb_instruction_fetch);
    end

endmodule
