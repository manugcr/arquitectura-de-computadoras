`timescale 1ns/1ps

module tb_xilinx_one_port_ram_async;

    // Parameters
    localparam ADDR_WIDTH = 12;
    localparam DATA_WIDTH = 8;

    // Testbench signals
    reg                    i_clk;
    reg                    i_write_enable;
    reg [ADDR_WIDTH-1:0]   i_addr;
    reg [DATA_WIDTH*4-1:0] i_data;
    wire [DATA_WIDTH*4-1:0] o_data;

    // Instantiate DUT (Device Under Test)
    xilinx_one_port_ram_async #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .i_clk(i_clk),
        .i_write_enable(i_write_enable),
        .i_addr(i_addr),
        .i_data(i_data),
        .o_data(o_data)
    );

    // Generate clock (50MHz clock, period = 20ns)
    initial i_clk = 0;
    always #10 i_clk = ~i_clk;

    // Testbench logic
    initial begin
        // Initialize signals
        i_write_enable = 0;
        i_addr = 0;
        i_data = 0;

        // Test Case 1: Write and read a 32-bit instruction at address 0x000
        #20;
        i_write_enable = 1;         // Enable write
        i_addr = 12'h000;           // Address to write
        i_data = 32'h12345678;      // Data to write
        #20;
        i_write_enable = 0;         // Disable write

        // Read back the data
        #10;
        $display("Test Case 1: Write 0x12345678 at address 0x000");
        $display("Read Data: 0x%h", o_data);
        if (o_data !== 32'h12345678)
            $display("ERROR: Mismatch!");

        // Test Case 2: Write and read at a higher address
        #20;
        i_write_enable = 1;
        i_addr = 12'h004;
        i_data = 32'h87654321;
        #20;
        i_write_enable = 0;

        // Read back the data
        #10;
        $display("Test Case 2: Write 0x87654321 at address 0x004");
        $display("Read Data: 0x%h", o_data);
        if (o_data !== 32'h87654321)
            $display("ERROR: Mismatch!");

        // Test Case 3: Edge case - Write to the last addressable memory
        #20;
        i_write_enable = 1;
        i_addr = 12'hFFC; // Last address (since ADDR_WIDTH=12, max=0xFFF)
        i_data = 32'hDEADBEEF;
        #20;
        i_write_enable = 0;

        // Read back the data
        #10;
        $display("Test Case 3: Write 0xDEADBEEF at address 0xFFC");
        $display("Read Data: 0x%h", o_data);
        if (o_data !== 32'hDEADBEEF)
            $display("ERROR: Mismatch!");

        // End simulation
        #50;
        $finish;
    end

endmodule
