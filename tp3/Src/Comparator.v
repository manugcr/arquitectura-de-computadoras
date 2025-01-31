`timescale 1ns / 1ps

//This file compares the rs and rt read data from the register and compares for branching purposes

module Comparator(InA, InB, Result, Control);

    input [2:0]  Control;   // 3 bit Control signal to determine the branch
    input [31:0] InA, InB;  // Input data to compare
    
    output reg Result;      // Signal of whether to branch or not branch

    localparam [2:0] BEQ  = 3'd1,   // 0 results in Result = 0
                     BNE  = 3'd6;

    always @ (*) begin
    
        case (Control)
        
            BEQ  : Result <= (InA == InB);
            BNE  : Result <= (InA != InB);
            default : Result <= 0;
        
        endcase
    
    end
    

endmodule
