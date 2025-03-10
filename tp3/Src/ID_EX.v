`timescale 1ns / 1ps


module ID_EX(
    Clock,
    In_ControlSignal, In_ReadData1, In_ReadData2, In_PCAdder,
    In_RegRT, In_RegRD,In_SignExtend,In_isBranch, In_RegRS,
    
    Out_ControlSignal, Out_ReadData1,Out_SignExtend, Out_ReadData2 , Out_PCAdder,
    Out_RegRT, Out_RegRD, Out_RegRS
  /*  i_halt,
    o_halt,
    i_enable,
    i_flush*/
);

    input        Clock;
    input        In_isBranch;
    input [4:0]  In_RegRT, In_RegRD, In_RegRS;
    input [31:0] In_ControlSignal,In_SignExtend, In_ReadData1, In_ReadData2, In_PCAdder;
  //  input        i_halt;
 //   input        i_enable;
  //  input        i_flush;

    output reg [4:0]  Out_RegRT, Out_RegRD, Out_RegRS;
    output reg [31:0] Out_ControlSignal,Out_SignExtend, Out_ReadData1, Out_ReadData2 , Out_PCAdder;
 //   output reg o_halt;


    always @(posedge Clock) begin
    /*    if(i_flush) begin
            Out_ControlSignal <= 32'b0;
        Out_ReadData1     <= 32'b0;
        Out_ReadData2     <= 32'b0;
        Out_PCAdder       <= 32'b0;
        Out_SignExtend    <= 32'b0;
        Out_RegRT         <= 5'b0;
        Out_RegRD         <= 5'b0;
        Out_RegRS         <= 5'b0;
        o_halt            <= 1'b0;
        end 
        else if(i_enable) begin */
        Out_ControlSignal <= In_ControlSignal;
        Out_ReadData1     <= In_ReadData1;
        Out_ReadData2     <= In_ReadData2;
        Out_PCAdder       <= In_PCAdder;
        Out_SignExtend    <= In_SignExtend;
        Out_RegRT         <= In_RegRT;
        Out_RegRD         <= In_RegRD;
        Out_RegRS         <= In_RegRS;
      //  o_halt            <=  i_halt;
      //  end 
    end
    
endmodule
