`timescale 1ns / 1ps


//module MIPS(Clock, Reset,  i_clear_program, i_ins,i_ins_mem_wr,o_ins_mem_full,o_ins_mem_empty,o_registers,o_mem_data,o_current_pc,o_end_program,i_enable, i_flush);

module MIPS(clk_in, Reset,btn,leds);


    

    input clk_in, Reset;

    input btn;  // Botón para avanzar
    output reg [15:0] leds;  // LEDs que muestran los valores de los registros


/*    //// DEBUG UNIT

    input i_clear_program;
    input  [31 : 0] i_ins;
    input  i_ins_mem_wr;
    input   i_enable;
    input   i_flush;
    output  o_ins_mem_full;
    output  o_ins_mem_empty;
    output  [32 * 32 - 1 : 0] o_registers;
    output  [32 * 32 - 1 : 0] o_mem_data;
    output wire [31 : 0] o_current_pc;
    output wire o_end_program;
    


    wire id_halt;
    wire o_ex_mem_halt;
    wire o_if_id_halt;   
    wire o_id_ex_halt; */

   // Declaración de registros y wires fuera del bloque always
wire [1023:0] o_registers;  // Suponiendo que los registros están en esta estructura
reg [31:0] register_value;  // Registro actual a mostrar
reg [4:0] register_index;   // Índice del registro que estamos mostrando

// Sincronización del botón
reg btn_last;
wire btn_edge = btn & ~btn_last;  // Detecta flanco de subida

// Contador para los registros
always @(posedge Clock or posedge Reset) begin
    if (Reset) begin
        register_index <= 0;
        leds <= 16'h0000;
        btn_last <= 0;
    end else begin
        btn_last <= btn;  // Guardamos estado anterior del botón
        if (btn_edge) begin
            register_index <= (register_index + 1) % 32; // Avanzar al siguiente registro (circular)
        end
        register_value <= o_registers[register_index * 32 +: 32]; // Asignación de valor de registro
        leds <= register_value[15:0];  // Mostrar los 16 bits más bajos del registro en los LEDs
    end
end



    wire [31:0] PCResult;
    wire [31:0] WriteData_WB;
    

    //--------------------------------
    // Wires
    //--------------------------------


    // Hazard Detection
    wire Hazard_IFIDWrite, Hazard_PCWrite;

     // Forwarding
    wire [1:0] ForwardMuxASel_EX, ForwardMuxBSel_EX;
    wire [1:0] ForwardMuxASel_ID, ForwardMuxBSel_ID;
    
    
    // Flush Register
    wire Flush_IF;

    wire BrachflagIFID;

    
    // Instructions
    wire [31:0] Instruction_IF, Instruction_ID, Instruction_IDStage;

    wire BranchIF;

    wire isBranchID;
    
    // Program Counter Adder
    wire [31:0] PCAdder_IF, PCAdder_ID, PCAdder_EX, PCAdder_MEM, PCAdder_WB;
    
 
    wire [31:0] BrachAddress;
    
    // Control Signal
    wire [31:0] ControlSignal_ID, ControlSignal_EX, ControlSignal_MEM, ControlSignal_WB;
    wire ALURegWrite;

    wire [31:0] JumpAddress;
    
    // Registers
    wire [4:0] RegRT_IDEX, RegRS_IDEX, RegRD_IDEX;
    
    // Register Data
    wire [31:0] ReadData1_ID, ReadData2_ID, ReadData1_EX, ReadData2_EX;
    
    // ALU Data
    wire ALUZero_EX, ALUZero_MEM;
    wire [31:0] ALUResult_EX, ALUResult_MEM, ALUResult_WB;

    // Sign Extend
    wire [31:0] SignExtend_ID, SignExtend_EX;
    
    // Memory Data
    wire [31:0] MemReadData_MEM, MemReadData_WB;
    wire [31:0] RegRTData_EX, RegRTData_MEM;
    
    // Write Register and Data from Write Back
    wire [4:0]  RegDst_MEM, RegDst_WB;
    wire [31:0] RegDst32_EX;



    // Instruction Fetch Stage 
    IF_Stage         IF_Stage(// Inputs
                       .Clock(Clock), 
                       .Reset(Reset),          
                       .PCWrite(Hazard_PCWrite),
                       .JumpAddress(JumpAddress), 
                       .JumpControl(JumpControl), 
                       .BrachAddress(BrachAddress), //////////////////
                       .BranchFlagID(BrachflagIFID),                
                    
                       // Outputs         
                       .Instruction(Instruction_IF), 
                       .PCAdder_Out(PCAdder_IF),
                       .PCResult(o_current_pc),
                       .isBranch(BranchIF)

                       ///DEBUG 
     //                  .i_clear_mem(i_clear_program),
       //                .i_instruction(i_ins),
         //              .i_write_mem(i_ins_mem_wr),
        //               .o_full_mem(o_ins_mem_full),
          //             .i_halt(id_halt),
           //            .o_empty_mem(o_ins_mem_empty),
           //            .i_enable(i_enable),
          //             .i_flush(i_flush)
                       );   
    
    

    IF_ID    IFID(.Clock(Clock), 
                        .Flush(Flush_IF), ///////////////////////////
                         .Enable(Hazard_IFIDWrite), 
                         .In_Instruction(Instruction_IF), 
                         .In_PCAdder(PCAdder_IF),
                         .In_Branch(BranchIF),
                         .Out_Instruction(Instruction_ID), 
                         .Out_PCAdder(PCAdder_ID),
                         .Out_Branch(isBranchID),
                         .Out_BrachAddress(BrachAddress)
                  //       .i_enable(i_enable),
                   //      .i_flush(i_flush)
                         );
 
    
    // Instruction Decode Stage
    ID_Stage  ID_Stage(// Inputs 
                       .Clock(Clock), 
                       .Reset(Reset),    
                       .RegWrite(ControlSignal_WB[2]), 
                       .MemRead_IDEX(ControlSignal_EX[5]),
                       .MemRead_EXMEM(ControlSignal_MEM[5]),        //SOLO PARA HAZARD BRANCH LOAD
                       .WriteRegister(RegDst_WB), 
                       .BranchFlag(BrachflagIFID),
                       .WriteData(WriteData_WB), 
                       .JumpControl(JumpControl),
                       .JumpAddress(JumpAddress),
                       .In_Instruction(Instruction_ID), //ACAAAAAA
                       .Out_Instruction(Instruction_IDStage),
                       .RegRT_IDEX(RegRT_IDEX),
                       .RegRD_IDEX(RegRD_IDEX), 
                       .RegDst_IDEX(ControlSignal_EX[10:9]),   
                       .RegWrite_IDEX(ControlSignal_EX[2]),
                       .RegWrite_EXMEM(ControlSignal_MEM[2]),
                       .RegisterDst_EXMEM(RegDst_MEM),
                       .PCAdder(PCAdder_ID), 
                       .ForwardData_EXMEM(ALUResult_MEM),     
                       .ControlSignal_Out(ControlSignal_ID), 
                       .ReadData1_out(ReadData1_ID), 
                       .Flush_IF(Flush_IF),
                       .ForwardData_MEMWB(ALUResult_WB),
                       .ReadData2_out(ReadData2_ID), 
                       .ForwardMuxASel(ForwardMuxASel_ID),
                       .ForwardMuxBSel(ForwardMuxBSel_ID),  
                       .ImmediateValue(SignExtend_ID), 
                       .PCWrite(Hazard_PCWrite),
                       .IFIDWrite(Hazard_IFIDWrite),
                       .o_bus_debug (o_registers)
                //       .o_halt(id_halt),
               //        .i_flush(i_flush)
                       ); 
  
    // ID / EX Register
         ID_EX    IDEX(.Clock(Clock),
                         .In_ControlSignal(ControlSignal_ID), 
                         .In_ReadData1(ReadData1_ID), 
                         .In_ReadData2(ReadData2_ID), 
                         .In_PCAdder(PCAdder_ID),
                         .Out_SignExtend(SignExtend_EX),
                         .In_RegRT(Instruction_IDStage[20:16]), //MODIFICAR
                         .In_RegRD(Instruction_IDStage[15:11]), //MODIFICAR
                         .In_RegRS(Instruction_IDStage[25:21]), //MODIFICAR
                         .Out_ControlSignal(ControlSignal_EX), 
                         .Out_ReadData1(ReadData1_EX), 
                         .Out_ReadData2(ReadData2_EX),
                         .In_isBranch(isBranchID),
                         .In_SignExtend(SignExtend_ID), 
                         .Out_PCAdder(PCAdder_EX),
                         .Out_RegRT(RegRT_IDEX), 
                         .Out_RegRD(RegRD_IDEX), 
                         .Out_RegRS(RegRS_IDEX)
                  //       .i_halt (id_halt),
                  //       .o_halt (o_id_ex_halt)
                 //        .i_enable(i_enable),
                //         .i_flush(i_flush)
                         );

    Forward  Forward(.RegWrite_EXMEM(ControlSignal_MEM[2]),
                              .RegWrite_MEMWB(ControlSignal_WB[2]),  
                              .RegDst_EXMEM(RegDst_MEM),
                             // .DelayHazardAlu(DelayHazardAlu),
                              .RegDst_MEMWB(RegDst_WB),
                              .isLoad(ControlSignal_WB[5]),
                              .RegRS_IDEX(RegRS_IDEX),
                              .RegRT_IDEX(RegRT_IDEX),
                              .isBranch(isBranchID),
                              .RegRS_IFID(Instruction_ID[25:21]),
                              .RegRT_IFID(Instruction_ID[20:16]),      
                              .ForwardMuxA_EX(ForwardMuxASel_EX),
                              .ForwardMuxB_EX(ForwardMuxBSel_EX),
                              .ForwardMuxA_ID(ForwardMuxASel_ID),
                              .ForwardMuxB_ID(ForwardMuxBSel_ID));  ////???????????????????????????????????
    

    // Execute Stage
    EX_Stage         EX_Stage(// Inputs 
                       .ALUBMuxSel(ControlSignal_EX[11]),
                       .ForwardMuxASel(ForwardMuxASel_EX),
                       .ForwardMuxBSel(ForwardMuxBSel_EX),  
                       .ALUOp(ControlSignal_EX[17:12]), 
                       .RegDst(ControlSignal_EX[10:9]),
                       .RegWrite(ControlSignal_EX[2]),      
                       .ReadData1(ReadData1_EX),
                       .MemToReg_WB(WriteData_WB), 
                       .ReadData2(ReadData2_EX), 
                       .SignExtend(SignExtend_EX),  
                       .RegRT(RegRT_IDEX), 
                       .RegRD(RegRD_IDEX),              
                       .ALUResult_MEM(ALUResult_MEM), 
                       .Shamt(SignExtend_EX[10:6]),      
      
                       // Outputs        
                       .ALUZero(ALUZero_EX), 
                       .ALUResult(ALUResult_EX),           
                       .RegDst32_Out(RegDst32_EX),  
                       .RegWrite_Out(ALURegWrite),                  
                       .ALURT(RegRTData_EX)); 

        
                       

    // EX / MEM Register
    EX_MEM   EXMEM(.Clock(Clock), 
                          .In_ControlSignal({ControlSignal_EX[31:3], ALURegWrite, ControlSignal_EX[1:0]}), 
                          .In_ALUZero(ALUZero_EX), 
                          .In_ALUResult(ALUResult_EX), 
                          .In_RegRTData(RegRTData_EX), 
                          .In_RegDst32(RegDst32_EX), 
                          .In_PCAdder(PCAdder_EX), 
                          .Out_ControlSignal(ControlSignal_MEM), 
                          .Out_ALUZero(ALUZero_MEM), 
                          .Out_ALUResult(ALUResult_MEM), 
                          .Out_RegRTData(RegRTData_MEM), 
                          .Out_RegDst(RegDst_MEM), 
                          .Out_PCAdder(PCAdder_MEM)
                //          .i_halt (o_id_ex_halt),
                 //         .o_halt (o_ex_mem_halt)
                  //        .i_enable(i_enable),
                  //        .i_flush(i_flush)
                          );


    // Memory Stage
    MEM_Stage        MEM_Stage(.Clock(Clock),     
                               .Reset(Reset),
                              .MemWrite(ControlSignal_MEM[6]), 
                              .MemRead(ControlSignal_MEM[5]),
                              .ALUResult(ALUResult_MEM),         
                              .RegRTData(RegRTData_MEM),
                              .ByteSig(ControlSignal_MEM[8:7]),
                              .MemReadData(MemReadData_MEM)
                  //            .o_bus_debug (o_mem_data),
                        //      .i_flush(i_flush)
                              );    
    

    // MEM / WB Register
    MEM_WB   MEMWB(.Clock(Clock), 
                          .In_ControlSignal(ControlSignal_MEM), 
                          .In_MemReadData(MemReadData_MEM), 
                          .In_ALUResult(ALUResult_MEM), 
                          .In_RegDst(RegDst_MEM), 
                          .In_PCAdder(PCAdder_MEM), 
                          .Out_ControlSignal(ControlSignal_WB), 
                          .Out_MemReadData(MemReadData_WB), 
                          .Out_ALUResult(ALUResult_WB), 
                          .Out_RegDst(RegDst_WB), 
                          .Out_PCAdder(PCAdder_WB)
                   //       .i_halt (o_ex_mem_halt),
                    //      .o_halt (o_end_program)
                     //     .i_enable(i_enable),
                     //     .i_flush(i_flush)
                          );

    
    // Write Back Stage
    WB_Stage         WB_Stage(// Inputs
                       .MemToReg(ControlSignal_WB[1:0]),       // OJOOOOOOOOO
                       .ALUResult(ALUResult_WB), 
                       .MemReadData(MemReadData_WB), 
                       .PCAdder(PCAdder_WB), 
    
                       // Outputs       
                       .MemToReg_Out(WriteData_WB));



    // prueba clock!

    // Instantiate the clock wizard (clk_wiz_0)
    clk_wiz_0 clk_wiz_inst (
        .clk_in1(clk_in),   // Connect your input clock here
        .reset(Reset),       // Connect your reset signal here
        .CLK_50MHZ(Clock), // The generated 50 MHz clock output
        .locked()            // You can use this signal for clock lock status if needed
    );
                       


endmodule
