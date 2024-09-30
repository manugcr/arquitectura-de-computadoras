`timescale 1ns / 1ps

module tb_baud_rate;

    // Parameters
    parameter N = 8;                                // Number of bits in the counter (same as in the module)
    parameter M = 163;                              // Maximum value the counter will reach (same as in the module)
    parameter CLK_PERIOD = 20;                      // Clock period in ns for 50MHz clock (1 / 50MHz = 20ns)
    parameter RESET_TIME = 10;                      // Time to hold reset

    // Inputs
    reg clk;
    reg reset;

    // Outputs
    wire tick;
    wire [N-1:0] q;                                 // Counter output

    // Instantiate the baud_rate module
    baud_rate #(
        .N(N), 
        .M(M)
    ) uut (
        .clk(clk),
        .reset(reset),
        .tick(tick),
        .q(q)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;       // Toggle clock every half period
    end

    // Test sequence
    initial begin
        // Initialize inputs
        reset = 1;                                  // Start with reset
        #(RESET_TIME) reset = 0;                    // Release reset

        // Let the system run for some time to observe ticks
        #(CLK_PERIOD * 200);                        // Run for ~200 clock cycles

        $finish;
    end

    // VCD Dump
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_baud_rate);
    end

    // Monitor outputs
    initial begin
        $monitor("Time: %0t | Reset: %b | Tick: %b | Q: %d", $time, reset, tick, q);
    end

endmodule
