`timescale 1ns / 1ps

module Mux2to1(out, inA, inB, sel);

    output reg [31:0] out;
    
    input [31:0] inA;
    input [31:0] inB;
    input sel;

    always @ (inA, inB, sel) begin
    
        if (sel)
            out <= inB;
        else
            out <= inA;
    end

endmodule
