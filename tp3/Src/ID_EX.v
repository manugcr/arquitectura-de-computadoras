`timescale 1ns / 1ps


module ID_EX(
    Clock,
    In_ControlSignal, In_ReadData1, In_ReadData2, In_PCAdder,
    In_RegRT, In_RegRD,In_SignExtend,In_isBranch, In_RegRS,
    
    Out_ControlSignal, Out_ReadData1,Out_SignExtend, Out_ReadData2 , Out_PCAdder,
    Out_RegRT, Out_RegRD,Out_isBranch, Out_RegRS
);

    input        Clock;
    input        In_isBranch;
    input [4:0]  In_RegRT, In_RegRD, In_RegRS;
    input [31:0] In_ControlSignal,In_SignExtend, In_ReadData1, In_ReadData2, In_PCAdder;
    
    output reg [4:0]  Out_RegRT, Out_RegRD, Out_RegRS;
    output reg [31:0] Out_ControlSignal,Out_SignExtend, Out_ReadData1, Out_ReadData2 , Out_PCAdder;
	output reg Out_isBranch;

	initial begin
        Out_ControlSignal <= 32'd0;
        Out_ReadData1     <= 32'd0;
        Out_ReadData2     <= 32'd0;
        Out_PCAdder       <= 32'd0;
        Out_SignExtend    <= 32'd0;
        Out_RegRT         <= 5'd0;
        Out_RegRD         <= 5'd0;
        Out_RegRS         <= 5'd0;
        Out_isBranch      <= 1'd0;
	end
	
    always @(posedge Clock) begin
        Out_ControlSignal <= In_ControlSignal;
        Out_ReadData1     <= In_ReadData1;
        Out_ReadData2     <= In_ReadData2;
        Out_PCAdder       <= In_PCAdder;
        Out_SignExtend    <= In_SignExtend;
        Out_RegRT         <= In_RegRT;
        Out_RegRD         <= In_RegRD;
        Out_RegRS         <= In_RegRS;
      //  Out_isBranch      <= In_isBranch;
    end
    
endmodule
