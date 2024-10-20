// Baud Rate Generator Module
// This module generates a baud rate clock tick based on a counter.
// Parameters:
// - NB_COUNTER: Number of bits in the counter (controls the maximum value the counter can hold).
// - COUNTER_LIMIT: Defines when the counter should reset (controls the baud rate).

module baud_rate #
(
    parameter NB_COUNTER = 5,        // Width of the counter (in bits)
    parameter COUNTER_LIMIT = 20     // Limit for the counter (baud rate frequency divisor)
)
(
    input wire i_clk,                // Input clock signal
    input wire i_reset,              // Asynchronous reset signal
    output wire o_tick_ovf           // Output tick signal (1 when counter reaches limit)
);

// Internal counter register (holds the current count value)
reg [NB_COUNTER-1 : 0] counter;
// Next counter value (calculated each clock cycle)
wire [NB_COUNTER-1 : 0] counter_next;

// Synchronous process: Update the counter on every rising edge of i_clk
always @(posedge i_clk) begin
    if (i_reset) begin
        // If reset is active, reset the counter to 0
        counter <= 0;
    end
    else begin
        // Otherwise, update counter with the next calculated value
        counter <= counter_next;
    end
end

// Calculate the next value of the counter
// If counter reaches the COUNTER_LIMIT, reset to 0; otherwise, increment
assign counter_next = (counter == (COUNTER_LIMIT-1)) ? 0 : counter + 1;

// Output tick overflow signal
// When the counter reaches COUNTER_LIMIT-1, set o_tick_ovf to 1; otherwise, set it to 0
assign o_tick_ovf = (counter == (COUNTER_LIMIT-1)) ? 1'b1 : 1'b0;

endmodule
