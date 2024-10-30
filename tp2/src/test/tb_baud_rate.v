`timescale 1ns / 1ps

module tb_baud_rate;

    // Parameters
    parameter NB_COUNTER = 8;            // To count up to 163
    parameter COUNTER_LIMIT = 163;       // Counter up to 163
    
    // Test signals
    reg i_clk;
    reg i_reset;
    wire o_tick;
    
    // Clock cycle counter until a tick occurs (1 byte)
    reg [7:0] clock_counter; // Declare as an 8-bit register

    // Instantiate the DUT (Device Under Test)
    baud_rate #(
        .NB_COUNTER(NB_COUNTER),
        .COUNTER_LIMIT(COUNTER_LIMIT)
    ) DUT (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .o_tick(o_tick)
    );

    // Clock generator
    initial begin
        i_clk = 0;
        forever #10 i_clk = ~i_clk; // 50 MHz clock (20 ns period)
    end

    // Reset process
    initial begin
        i_reset = 1; // Activate reset
        #30;         // Hold reset for 30 ns
        i_reset = 0; // Deactivate reset
    end

    // Clock cycle counter until a tick
    initial begin
        clock_counter = 0; // Initialize clock cycle counter
        
        // Count clock cycles until a tick occurs
        forever begin
            @(posedge i_clk); // Wait for a rising edge of the clock
            if (o_tick) begin
                // When a tick is generated, display the clock cycle count
                $display("Tick generated at time %0dns, clock cycles counted: %d", $time, clock_counter);
                clock_counter = 0; // Reset counter
            end
            else begin
                if (clock_counter < 8'hFF) begin
                    clock_counter = clock_counter + 1; // Increment counter
                end
            end
        end
    end

    // Monitor the output signal
    initial begin
        $monitor("Time: %0dns | Reset: %b | Tick: %b", $time, i_reset, o_tick);
        
        // Wait sufficient time to observe behavior
        #2000; // Wait sufficient time to observe multiple ticks
        $finish; // End the simulation
    end

endmodule
