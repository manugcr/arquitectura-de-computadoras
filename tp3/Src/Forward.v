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

    /* 
            NOTA: Se agrega la señal DelayHazardAlu porque, al ocurrir un hazard de datos, hay un ciclo 
            en el cual una de las entradas de la ALU recibe el forwarding, pero la otra queda desactualizada. 
            Por lo tanto, es necesario un ciclo adicional (en el que la ALU NO trabaje) para que las entradas 
            se actualicen.
    */

   // DelayHazardAlu,                     
    
    
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
        if ((RegWrite_EXMEM && (RegDst_EXMEM != 0)) && (RegDst_EXMEM == RegRS_IFID))   begin   
            ForwardMuxA_ID <= 1'd1; // Reenvío habilitado

          
            /*
                RegWrite_EXMEM = 1 ->  la instrucción que se encuentra en la etapa EX/MEM escribe un valor en un registro
                RegDst_EXMEM != 0   ->  Registro en el que se va a guardar un resultado 
                RegRS_IFID          -> suponiendo ADD $t1, $t2, $t3,  t2 es RS
            */
        end
        else begin
            ForwardMuxA_ID <= 1'd0; // Sin reenvío
        end 
        
        // ForwardMuxB: Reenvío de datos desde EX/MEM a RT en la etapa IF/ID
        if ((RegWrite_EXMEM && (RegDst_EXMEM != 0)) && (RegDst_EXMEM == RegRT_IFID))    begin   
            ForwardMuxB_ID <= 1'd1; // Reenvío habilitado

         
             /*
                RegWrite_EXMEM = 1 ->  la instrucción que se encuentra en la etapa EX/MEM escribe un valor en un registro
                RegDst_EXMEM != 0   ->  Registro en el que se va a guardar un resultado 
                RegRT_IFID          -> suponiendo ADD $t1, $t2, $t3,  t3 es RT
            */
           
        end
        else begin
            ForwardMuxB_ID <= 1'd0; // Sin reenvío
        end 

        //-----------------
        // Reenvío - Etapa EX
        //-----------------
        
        // ForwardMuxA: Reenvío de datos desde EX/MEM o MEM/WB a RS en la etapa ID/EX
        if ((RegWrite_EXMEM && (RegDst_EXMEM != 0)) && (RegDst_EXMEM == RegRS_IDEX)) begin     
            ForwardMuxA_EX <= 2'd1; // Reenvío desde EX/MEM

        
            /*
                RegWrite_EXMEM = 1 ->  la instrucción que se encuentra en la etapa EX/MEM escribe un valor en un registro
                RegDst_EXMEM != 0   ->  Registro en el que se va a guardar un resultado 
            */
           
         end
        else if ((RegWrite_MEMWB && (RegDst_MEMWB != 0)) && (RegDst_MEMWB == RegRS_IDEX)) begin
            ForwardMuxA_EX <= 2'd2; // Reenvío desde MEM/WB

        

             /*
                RegWrite_EXMEM = 1 ->  la instrucción que se encuentra en la etapa MEM/WB escribe un valor en un registro
                RegDst_MEMWB != 0   ->  Registro en el que se va a guardar un resultado 
            */
         

        end
        else begin
            ForwardMuxA_EX <= 2'b00; // Sin reenvío
        end 
    
        // ForwardMuxB: Reenvío de datos desde EX/MEM o MEM/WB a RT en la etapa ID/EX
        if ((RegWrite_EXMEM && (RegDst_EXMEM != 0)) && (RegDst_EXMEM == RegRT_IDEX))   begin   
            ForwardMuxB_EX <= 2'd1; // Reenvío desde EX/MEM

      
           
        end 
        else if ((RegWrite_MEMWB && (RegDst_MEMWB != 0)) && (RegDst_MEMWB == RegRT_IDEX)) begin
            ForwardMuxB_EX <= 2'd2; // Reenvío desde MEM/WB

        
            
        end
        else 
            ForwardMuxB_EX <= 2'b00; // Sin reenvío
     
    end

    
endmodule
