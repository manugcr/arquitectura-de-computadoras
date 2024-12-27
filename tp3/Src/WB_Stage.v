`timescale 1ns / 1ps


module WB_Stage(
    MemToReg,       
    ALUResult, MemReadData, PCAdder,        
    MemToReg_Out    // Write Back Data   
    );             
          

    input [1:0] MemToReg;
    
    input [31:0] ALUResult, MemReadData, PCAdder;

    output wire [31:0] MemToReg_Out;



    Mux3to1    MemToRegMux(.out(MemToReg_Out), 
                                .inA(MemReadData), 
                                .inB(PCAdder), 
                                .inC(ALUResult), 
                                .sel(MemToReg));

endmodule
