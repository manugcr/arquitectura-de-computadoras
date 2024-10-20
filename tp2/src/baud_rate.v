

module baud_rate#
(
    parameter NB_COUNTER = 5,       
    parameter COUNTER_LIMIT = 20    
)
(
    input wire i_clk,
    input wire i_reset,
    output wire o_tick
);

reg [NB_COUNTER-1 : 0] counter;
wire [NB_COUNTER-1 : 0] counter_next;

always @(posedge i_clk) begin
    if (i_reset) begin
        counter <= 0;
    end
    else begin
        counter <= counter_next;
    end
end


assign counter_next = (counter == (COUNTER_LIMIT-1)) ? 0 : counter + 1;
assign o_tick = (counter == (COUNTER_LIMIT-1)) ? 1'b1 : 1'b0;

endmodule
