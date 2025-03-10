`timescale 1ns / 1ps

  
module MEM_WB(

    Clock, 
    In_ControlSignal, In_MemReadData, In_ALUResult, In_RegDst, In_PCAdder, 
    Out_ControlSignal, Out_MemReadData, Out_ALUResult, Out_RegDst, Out_PCAdder
 /*   i_halt,
    o_halt,
	i_enable,
	i_flush */
);
	
	input Clock;
	input [4:0]  In_RegDst;
    input [31:0] In_ControlSignal, In_MemReadData, In_ALUResult, In_PCAdder;
	/*input        i_halt;
	input		 i_enable;
	input 		 i_flush; */

	output reg [4:0]  Out_RegDst;
	output reg [31:0] Out_ControlSignal, Out_MemReadData, Out_ALUResult, Out_PCAdder;
//	output reg o_halt;
	
	always @(posedge Clock) begin
		/*if(i_flush) begin
		Out_MemReadData   <= 32'b0;
	    Out_RegDst        <= 5'b0;
        Out_ControlSignal <= 32'b0;
        Out_ALUResult     <= 32'b0;
        Out_PCAdder       <= 32'b0;
		o_halt            <= 1'b0;
		end 
		else if(i_enable) begin */
		Out_MemReadData   <= In_MemReadData;
	    Out_RegDst        <= In_RegDst;
        Out_ControlSignal <= In_ControlSignal;
        Out_ALUResult     <= In_ALUResult;
        Out_PCAdder       <= In_PCAdder;
	//	o_halt            <=  i_halt;
	//	end 
	end
	
endmodule
