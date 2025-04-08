module IFID (
    input wire         clk,
    input wire         i_rst_n,
    input wire         i_halt,
    input wire         i_stall,
    input wire [31:0]  i_instruction,   //! instrucción cruda desde IF
    output reg [31:0]  o_instruction    //! instrucción registrada para ID
);

    always @(posedge clk) begin
        if (!i_rst_n) begin
            o_instruction <= 32'b0;
        end
        else if (!i_halt && !i_stall) begin
            o_instruction <= i_instruction;
        end
    end
    

endmodule
