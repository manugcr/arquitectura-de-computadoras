`timescale 1ns / 1ps

//This file compares the rs and rt read data from the register and compares for branching purposes

module Comparator(InA, InB, Result, Control, CompareFlag);

    input [2:0]  Control;   // 3 bit Control signal to determine the branch
    input [31:0] InA, InB;  // Input data to compare
    input CompareFlag;
    
    output reg Result;      // Signal of whether to branch or not branch

    localparam [2:0] BEQ  = 3'd1,   // 0 results in Result = 0
                     BNE  = 3'd2;

    always @ (*) begin

         Result = 0;
    
        if(CompareFlag == 1'b1 && Control !=1'b0) begin

        case (Control)
            BEQ  : Result =  (InA == InB);
            BNE  : Result =  (InA != InB);
            default : Result =  0;
        endcase
        end
        else begin
            Result =  0;
        end

    
    end
    

endmodule
