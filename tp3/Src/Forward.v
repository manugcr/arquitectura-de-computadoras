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

         // DelayHazardAlu = ForwardMuxA_ID || ForwardMuxB_ID; //indica si hay forwarding en alguna de las entradas, por el hazard
        
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

              $display("[Time: %0t] ForwardMuxA_EX activado: Reenvío desde EX/MEM a RS en la etapa ID/EX. RegWrite_EXMEM: %b, RegDst_EXMEM: %d, RegRS_IDEX: %d", $time, RegWrite_EXMEM, RegDst_EXMEM, RegRS_IDEX);
        end
        else if ((RegWrite_MEMWB && (RegDst_MEMWB != 0)) && (RegDst_MEMWB == RegRS_IDEX)) begin
            ForwardMuxA_EX <= 2'd2; // Reenvío desde MEM/WB

            $display("[Time: %0t] ForwardMuxA_EX activado: Reenvío desde MEM/WB a RS en la etapa ID/EX. RegWrite_MEMWB: %b, RegDst_MEMWB: %d, RegRS_IDEX: %d", 
             $time, RegWrite_MEMWB, RegDst_MEMWB, RegRS_IDEX);

             /*
                RegWrite_EXMEM = 1 ->  la instrucción que se encuentra en la etapa MEM/WB escribe un valor en un registro
                RegDst_MEMWB != 0   ->  Registro en el que se va a guardar un resultado 




                [Time: 65000] ForwardMuxA_EX activado: ReenvÃ­o desde MEM/WB a RS en la etapa ID/EX. RegWrite_MEMWB: 1, RegDst_MEMWB:  9, RegRS_IDEX:  9
                Tiempo: 75000, Escritura en registro[9]: 32
                Tiempo: 85000, Escritura en registro[12]: 46
                Tiempo: 95000, Escritura en registro[8]: 46
                Tiempo: 105000, Escritura en registro[8]: 1e 
                Tiempo: 115000, Escritura en registro[8]: 46
                Tiempo: 125000, Escritura en registro[8]: 46

            */

        end
        else begin
            ForwardMuxA_EX <= 2'b00; // Sin reenvío
        end 
    
        // ForwardMuxB: Reenvío de datos desde EX/MEM o MEM/WB a RT en la etapa ID/EX
        if ((RegWrite_EXMEM && (RegDst_EXMEM != 0)) && (RegDst_EXMEM == RegRT_IDEX))   begin   
            ForwardMuxB_EX <= 2'd1; // Reenvío desde EX/MEM
            $display("[Time: %0t] ForwardMuxB_EX activado: Reenvío desde EX/MEM a RT en la etapa ID/EX. RegWrite_EXMEM: %b, RegDst_EXMEM: %d, RegRT_IDEX: %d", 
             $time, RegWrite_EXMEM, RegDst_EXMEM, RegRT_IDEX);
        end 
        else if ((RegWrite_MEMWB && (RegDst_MEMWB != 0)) && (RegDst_MEMWB == RegRT_IDEX)) begin
            ForwardMuxB_EX <= 2'd2; // Reenvío desde MEM/WB
            $display("[Time: %0t] ForwardMuxB_EX activado: Reenvío desde MEM/WB a RT en la etapa ID/EX. RegWrite_MEMWB: %b, RegDst_MEMWB: %d, RegRT_IDEX: %d", 
             $time, RegWrite_MEMWB, RegDst_MEMWB, RegRT_IDEX);
        end
        else 
            ForwardMuxB_EX <= 2'b00; // Sin reenvío
     
    end

/*
    // Monitorizar DelayHazardAlu
    always @ (DelayHazardAlu) begin
        if (DelayHazardAlu) begin
            $display("[Time: %0t] DelayHazardAlu activado.", $time);
        end
    end*/
    
endmodule
