`timescale 1ns / 1ps


module EX_MEM(

    Clock, 
    In_ControlSignal, In_ALUZero, In_ALUResult, In_RegRTData, In_RegDst32, In_PCAdder, 
    Out_ControlSignal, Out_ALUZero, Out_ALUResult, Out_RegRTData, Out_RegDst, Out_PCAdder,
    i_halt,
    o_halt,
    i_enable,
    i_flush
);
	
	input Clock, In_ALUZero;
	input [31:0] In_RegDst32;
    input [31:0] In_ControlSignal, In_ALUResult, In_RegRTData, In_PCAdder;
    input        i_halt;
    input        i_enable;
    input        i_flush;

	output reg        Out_ALUZero;
	output reg [4:0]  Out_RegDst;
	output reg [31:0] Out_ControlSignal, Out_ALUResult, Out_RegRTData, Out_PCAdder;
	output reg o_halt;

	always @(posedge Clock) begin
        if(i_flush) begin
        Out_ALUZero       <= 1'b0;
	    Out_RegDst        <= 5'b0;
        Out_ControlSignal <= 32'b0;
        Out_ALUResult     <= 32'b0;
        Out_RegRTData     <= 32'b0;
        Out_PCAdder       <= 32'b0;
		o_halt            <= 1'b0;
        end
        else if(i_enable) begin
		Out_ALUZero       <= In_ALUZero;
	    Out_RegDst        <= In_RegDst32[4:0];
        Out_ControlSignal <= In_ControlSignal;
        Out_ALUResult     <= In_ALUResult;
        Out_RegRTData     <= In_RegRTData;
        Out_PCAdder       <= In_PCAdder;
		o_halt            <=  i_halt;
        end
	end

endmodule
