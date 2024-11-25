`timescale 1ns / 1ps

module adder
    #(
        parameter BUS_SIZE = 32
    )
    (
        input  wire [BUS_SIZE - 1 : 0] a,
        input  wire [BUS_SIZE - 1 : 0] b,
        output wire [BUS_SIZE - 1 : 0] result
    );
    
    assign result = a + b;

endmodule