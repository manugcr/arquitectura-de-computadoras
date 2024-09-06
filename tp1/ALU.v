module ALU 
#(
    parameter NB_DATA = 8,                                  // Data bus width (number of bits for A and B)
    parameter NB_OP = 6                                     // Operation width (number of bits for the operation code)
)
(
    input wire signed [NB_DATA-1 : 0] i_data_a,             // 8-bit number A
    input wire signed [NB_DATA-1 : 0] i_data_b,             // 8-bit number B
    input wire [NB_OP-1 : 0] i_op,                          // 6-bit operation code
    output reg signed [NB_DATA-1 : 0] o_data                // 8-bit output
);

    always @(*)                                             // Code block that is executed when any of the inputs change
    begin                       
        case (i_op)
            6'b100000: o_data = i_data_a + i_data_b;        // ADD
            6'b100010: o_data = i_data_a - i_data_b;        // SUB
            6'b100100: o_data = i_data_a & i_data_b;        // AND
            6'b100101: o_data = i_data_a | i_data_b;        // OR
            6'b100110: o_data = i_data_a ^ i_data_b;        // XOR
            6'b000011: o_data = i_data_a >>> 1;             // SRA (arithmetic shift right)
            6'b000010: o_data = i_data_a >> 1;              // SRL (logical shift right)
            6'b100111: o_data = ~(i_data_a | i_data_b);     // NOR
            default: o_data = 0;                            // Default case (optional)
        endcase
    end
endmodule
