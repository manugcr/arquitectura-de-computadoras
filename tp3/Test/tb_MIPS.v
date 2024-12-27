`timescale 1ns / 1ps


module tb_MIPS();

    reg         Reset, Clock;

    
    MIPS    MIPSTest(.ClockIn(Clock), 
                         .Reset(Reset));
    
    always begin    
        Clock <= 1;
        #50;
        Clock <= 0;
        #50;
    end
    
    initial begin
        Reset <= 1;
        @(posedge Clock);
        #100 
        Reset <= 0; 
    end

endmodule
