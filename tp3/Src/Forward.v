`timescale 1ns / 1ps

// -------------------------------------------------------------------------
// Implementa la lógica de reenvío para un procesador 
//  segmentado, resolviendo peligros de datos.
// -------------------------------------------------------------------------

module Forward(
    // --- Entradas ---
    RegWrite_EXMEM, RegWrite_MEMWB,     // Señales de control RegWrite desde las etapas EX/MEM y MEM/WB
    RegDst_EXMEM, RegDst_MEMWB,         // Direcciones de registros destino desde las etapas EX/MEM y MEM/WB
    RegRS_IDEX, RegRT_IDEX,             // Direcciones de registros fuente desde la etapa ID/EX
    RegRS_IFID, RegRT_IFID,             // Direcciones de registros fuente desde la etapa IF/ID
    
    // --- Salidas ---
    ForwardMuxA_EX, ForwardMuxB_EX,     // Señales de reenvío para los multiplexores de la etapa EX
    ForwardMuxA_ID, ForwardMuxB_ID      // Señales de reenvío para los multiplexores de la etapa ID
);

    //--------------------------------
    // Entradas
    //--------------------------------
    
    input       RegWrite_EXMEM, RegWrite_MEMWB;   // Señales de escritura habilitada para las etapas EX/MEM y MEM/WB
    input [4:0] RegDst_EXMEM, RegDst_MEMWB;       // Direcciones de registros destino desde las etapas EX/MEM y MEM/WB
    input [4:0] RegRS_IDEX, RegRT_IDEX;           // Direcciones de registros fuente desde la etapa ID/EX
    input [4:0] RegRS_IFID, RegRT_IFID;           // Direcciones de registros fuente desde la etapa IF/ID
    
    //--------------------------------
    // Salidas
    //--------------------------------
    
    output reg [1:0] ForwardMuxA_EX, ForwardMuxB_EX; // Señales de reenvío para las entradas de la ALU en la etapa EX
    output reg ForwardMuxA_ID, ForwardMuxB_ID;       // Señales de reenvío para los multiplexores de la etapa ID
    
    //--------------------------------
    // Lógica de Reenvío
    //--------------------------------

    // Inicializar salidas con valores por defecto
    initial begin
        ForwardMuxA_ID <= 1'b0;
        ForwardMuxB_ID <= 1'b0;
        ForwardMuxA_EX <= 2'b00;
        ForwardMuxB_EX <= 2'b00;
    end
    
    // Lógica combinacional para el reenvío
    always @ (*) begin
        
        //-----------------
        // Reenvío - Etapa ID
        //-----------------
        
        // ForwardMuxA: Reenvío de datos desde EX/MEM a RS en la etapa IF/ID
        if ((RegWrite_EXMEM && (RegDst_EXMEM != 0)) && (RegDst_EXMEM == RegRS_IFID))      
            ForwardMuxA_ID <= 1'd1; // Reenvío habilitado
        else 
            ForwardMuxA_ID <= 1'd0; // Sin reenvío
        
        // ForwardMuxB: Reenvío de datos desde EX/MEM a RT en la etapa IF/ID
        if ((RegWrite_EXMEM && (RegDst_EXMEM != 0)) && (RegDst_EXMEM == RegRT_IFID))      
            ForwardMuxB_ID <= 1'd1; // Reenvío habilitado
        else 
            ForwardMuxB_ID <= 1'd0; // Sin reenvío
        
        //-----------------
        // Reenvío - Etapa EX
        //-----------------
        
        // ForwardMuxA: Reenvío de datos desde EX/MEM o MEM/WB a RS en la etapa ID/EX
        if ((RegWrite_EXMEM && (RegDst_EXMEM != 0)) && (RegDst_EXMEM == RegRS_IDEX))      
            ForwardMuxA_EX <= 2'd1; // Reenvío desde EX/MEM
        else if ((RegWrite_MEMWB && (RegDst_MEMWB != 0)) && (RegDst_MEMWB == RegRS_IDEX)) 
            ForwardMuxA_EX <= 2'd2; // Reenvío desde MEM/WB
        else 
            ForwardMuxA_EX <= 2'b00; // Sin reenvío
    
        // ForwardMuxB: Reenvío de datos desde EX/MEM o MEM/WB a RT en la etapa ID/EX
        if ((RegWrite_EXMEM && (RegDst_EXMEM != 0)) && (RegDst_EXMEM == RegRT_IDEX))      
            ForwardMuxB_EX <= 2'd1; // Reenvío desde EX/MEM
        else if ((RegWrite_MEMWB && (RegDst_MEMWB != 0)) && (RegDst_MEMWB == RegRT_IDEX)) 
            ForwardMuxB_EX <= 2'd2; // Reenvío desde MEM/WB
        else 
            ForwardMuxB_EX <= 2'b00; // Sin reenvío
     
    end
    
endmodule
