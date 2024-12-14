// This module serves as the memory where the program instructions are preloaded
// and from which the processor fetches the instructions during execution.
// The module can handle either a read or a write operation and holds 4 bytes of data.

module xilinx_one_port_ram_async 
#(
    parameter ADDR_WIDTH = 12,  // 4096 addresses
    parameter DATA_WIDTH = 8    // 8 bit data
) (
    input   wire                    i_clk,
    input   wire                    i_write_enable,     // Write enable signal
    input   wire [ADDR_WIDTH-1:0]   i_addr,             // Address of the instruction
    input   wire [DATA_WIDTH*4-1:0] i_data,
    output  wire [DATA_WIDTH*4-1:0] o_data              // Instruction given to the processor
);

    reg [DATA_WIDTH-1:0] memory [2**ADDR_WIDTH-1:0];

    always @(posedge i_clk) begin
        if (i_write_enable) begin
            memory[i_addr]   <= i_data[31:24];          // MSB
            memory[i_addr+1] <= i_data[23:16];
            memory[i_addr+2] <= i_data[15:8];
            memory[i_addr+3] <= i_data[7:0];            // LSB
        end
    end

    assign o_data = {memory[i_addr], memory[i_addr+1], memory[i_addr+2], memory[i_addr+3]};

endmodule
