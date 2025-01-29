`timescale 1ns / 1ps

/*
        Si se cumple la condición: Mem_Read_EX && ((rt_EX == rs_ID)||(rt_EX == rt_ID))) entonces
        se debe bloquear el pipeline por un ciclo!!!

        Mem_Read_EX: La primera parte de la condición comprueba si la instrucción anterior es una carga (load), ya que
        es la única instrucción que lee de memoria.
        
        ((rt_EX == rs_ID)||(rt_EX == rt_ID)): Verifican si el registro destino (rt) de
        la carga en la etapa EX coincide con cualquiera de los dos registros fuente de la instrucción actual en
        ID. Si la condición se cumple, la instrucción actual se bloquea por un ciclo.

*/



module Hazard(
    // --- Entradas ---

    RegRS_IFID, RegRT_IFID,       // Registros fuente en la etapa IF/ID
    RegRT_IDEX, RegRD_IDEX,       // Registros en la etapa ID/EX
    MemRead_IDEX,   // Señales de control en ID/EX
    RegDst_IDEX,                  // Selección del registro destino en ID/EX
    ControlStall,
    RegWrite_IDEX,
    RegWrite_EXMEM,
    RegisterDst_EXMEM,
    // --- Salidas ---  
    PCWrite, IFIDWrite            // Señales de control para manejar peligros
);

    //--------------------------------
    // Entradas
    //--------------------------------
    input RegWrite_EXMEM,MemRead_IDEX, RegWrite_IDEX;   // Señales de control para lectura y escritura
    input [1:0] RegDst_IDEX;             // Selección del registro destino en la etapa ID/EX
    input [4:0] RegisterDst_EXMEM,RegRS_IFID, RegRT_IFID;  // Registros fuente en la etapa IF/ID
    input [4:0] RegRT_IDEX, RegRD_IDEX;  // Registros destino en la etapa ID/EX

    //--------------------------------
    // Salidas
    //--------------------------------
    output reg PCWrite, IFIDWrite , ControlStall ;       // Señales para detener la ejecución (stalls)

    //--------------------------------
    // Inicialización de salidas
    //--------------------------------
    initial begin
        PCWrite   <= 1'b1;  // Inicialmente, permitir que el PC avance
        IFIDWrite <= 1'b1;  // Inicialmente, permitir que el pipeline avance
        ControlStall <= 1'b0;
    end
    
    //--------------------------------
    // Lógica de detección de peligros
    //--------------------------------
    always @(*) begin

        // Caso 1: Peligro de datos de carga (Load-Use Hazard)
        // Ocurre cuando una instrucción `lw` en la etapa ID/EX tiene como destino
        // un registro que se está utilizando en la etapa IF/ID.
        if (MemRead_IDEX && 
           ((RegDst_IDEX == 2'b00 && ((RegRT_IDEX == RegRS_IFID) || (RegRT_IDEX == RegRT_IFID))) || 
            (RegDst_IDEX == 2'b01 && ((RegRD_IDEX == RegRS_IFID) || (RegRD_IDEX == RegRT_IFID))))) begin

                $display("PROBLEMAAAAAAAAAAAAAAAAAAAAAAAA! con valores:");
                $display("MemRead_IDEX = %b", MemRead_IDEX);
                $display("RegDst_IDEX = %b", RegDst_IDEX);
                $display("RegRT_IDEX = %b, RegRS_IFID = %b, RegRT_IFID = %b", RegRT_IDEX, RegRS_IFID, RegRT_IFID);
                $display("RegRD_IDEX = %b", RegRD_IDEX);
                $display("Condicion 1: %b", (RegDst_IDEX == 2'b00 && ((RegRT_IDEX == RegRS_IFID) || (RegRT_IDEX == RegRT_IFID)))); //ACA ESTA
                $display("Condicion 2: %b", (RegDst_IDEX == 2'b01 && ((RegRD_IDEX == RegRS_IFID) || (RegRD_IDEX == RegRT_IFID))));
        
            
            PCWrite   <= 1'b0;  // Detener la actualización del PC
            IFIDWrite <= 1'b0;  // Detener la actualización del registro IF/ID
            ControlStall <= 1'b1;
        end 
        else begin 
            // Caso por defecto: No hay peligro detectado.
            // Permitir que el pipeline avance normalmente.
            PCWrite   <= 1'b1;  // Permitir la actualización del PC
            IFIDWrite <= 1'b1;  // Permitir la actualización del registro IF/ID
            ControlStall <= 1'b0;
        end

    end

endmodule
