`timescale 1ns / 1ps

module baud_rate 
#(
	// 19200 baud rate
    parameter N = 8,                                    // Number of bits in the counter
    parameter M = 163                                   // Maximum value the counter will reach before resetting
)
(
    input wire clk,   
    input wire reset,  
    output wire tick,                                  	// Output that indicates when a tick has been generated
    output wire [N-1:0] q                             	// Output that represents the current value of the counter
);

    reg [N-1:0] r_reg;                                	// Register that stores the current value of the counter
    wire [N-1:0] r_next;                              	// Signal that represents the next state of the counter

    // Register logic
    always @(posedge clk, posedge reset)				// Triggered on the rising edge of the clock
	begin
        if (reset)
            r_reg <= 0;
        else
            r_reg <= r_next;
    end

    // Logic to determine the next state of the counter
    assign r_next = (r_reg == (M - 1)) ? 0 : r_reg + 1;
    assign tick = (r_reg == (M - 1)) ? 1'b1 : 1'b0;

    assign q = r_reg;

endmodule
