`timescale 1ns / 1ps

module tb_transmitter;

    // Parameters
    parameter DBIT = 8;               // Data bits
    parameter TICKS_END = 16;         // Ticks for stop bits
    parameter CLK_PERIOD = 20;        // Clock period for 50 MHz (20 ns)
    
    // Inputs
    reg clk;
    reg reset;
    reg tx_go;
    reg pulse_tick;
    reg [7:0] din;

    // Outputs
    wire tx_done_tick;
    wire tx;

    // Instantiate the transmitter module
    transmitter 
    #(
        .DBIT(DBIT), 
        .TICKS_END(TICKS_END)
    ) uut (
        .clk(clk),
        .reset(reset),
        .tx_go(tx_go),
        .pulse_tick(pulse_tick),
        .din(din),
        .tx_done_tick(tx_done_tick),
        .tx(tx)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;  // Toggle clock every 10 ns
    end

    // Test sequence
    initial begin
        // Initialize inputs
        reset = 1;
        tx_go = 0;
        pulse_tick = 0;
        din = 8'b10101010;  // Example data to transmit
        
        // Release reset
        #(CLK_PERIOD) reset = 0;  
        
        // Start the transmission
        #(CLK_PERIOD) tx_go = 1;  // Assert tx_go to start transmission
        #(CLK_PERIOD) tx_go = 0;  // Deassert tx_go
        
        // Generate pulse ticks for transmission
        repeat (128) begin  // 128 ticks for 8 bits of data at TICKS_END = 16
            #(CLK_PERIOD) pulse_tick = 1;  // Assert pulse_tick
            #(CLK_PERIOD) pulse_tick = 0;   // Deassert pulse_tick
        end

        // Wait for transmission to complete
        #(CLK_PERIOD * 10);  // Adjust time as needed to observe tx_done_tick
        
        // Finish the simulation
        $finish;
    end

    // VCD Dump 
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_transmitter);
    end

    // Monitor outputs
    initial begin
        $monitor("Time: %0t | Reset: %b | TX_GO: %b | Pulse_Tick: %b | Din: %b | TX_Done: %b | TX: %b", 
                 $time, reset, tx_go, pulse_tick, din, tx_done_tick, tx);
    end

endmodule
