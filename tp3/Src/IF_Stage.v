`timescale 1ns / 1ps

// Módulo IFStage: Implementa la etapa de Instruction Fetch (IF) de un procesador.
module IF_Stage(
    Clock, Reset,               // Señales del sistema
    PCWrite,                   // Control de escritura del PC (señal de control de riesgos)
    Instruction, PCAdder_Out,  PCResult // Salidas del módulo
    );             
          
    // Entradas del sistema
    input Clock, Reset; // Señales de reloj y reset del sistema
    
    // Señales de control de riesgos
    input PCWrite; // Habilita o deshabilita la escritura en el PC, utilizada para manejar riesgos
    
    // Salidas
    output wire [31:0] Instruction;    // Instrucción obtenida de la memoria de instrucciones
    output wire [31:0] PCAdder_Out;    // Resultado del PC + 4 (dirección de la siguiente instrucción)
    output wire [31:0] PCResult;       // Dirección actual del PC
    
    // Cables internos
    wire [31:0] PCInput;           // Entrada al PC (sin usar en este módulo)
    wire [31:0] ScheduledPC;       // Dirección programada del PC (sin usar en este módulo)
    wire [31:0] TargetOffset;      // Desplazamiento objetivo (sin usar en este módulo)
    wire [31:0] TargetAddress;     // Dirección objetivo (sin usar en este módulo)
    wire [31:0] ShiftedOffset;     // Desplazamiento desplazado (sin usar en este módulo)
    wire stall;
    // Instancia del módulo PC (Program Counter)
    // Mantiene la dirección actual de la instrucción a ejecutar
    PC PC(
        .PC_In(PCAdder_Out),    // Dirección de la siguiente instrucción (PC + 4)
        .PCResult(PCResult),    // Dirección actual del PC
        .stall(stall),
        .Enable(PCWrite),          // Habilitación constante a 1 lógico
        .Reset(Reset),          // Señal de reinicio
        .Clock(Clock)           // Señal de reloj
    );
                           
    // Instancia del módulo InstructionMemory
    // Obtiene la instrucción correspondiente a la dirección actual del PC
    InstructionMemory InstructionMemory(
        .Address(PCResult),     // Dirección de memoria (PC actual)
        .Instruction(Instruction), // Instrucción obtenida de la memoria
        .stall(stall)
    );
    
    // Instancia del módulo Adder
    // Calcula la dirección de la siguiente instrucción (PC + 4)
    Adder PCAdder(
        .A(PCResult),           // Dirección actual del PC
        .B(32'd4),              // Constante 4 (tamaño de instrucción en bytes)
        .AddResult(PCAdder_Out), // Resultado del sumador (PC + 4)
        .stall(stall)
    );
    
endmodule
