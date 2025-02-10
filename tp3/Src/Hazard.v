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
    OpCode, Func,  
    RegRS_IFID, RegRT_IFID,       // Registros fuente en la etapa IF/ID
    RegRT_IDEX, RegRD_IDEX,       // Registros en la etapa ID/EX
    MemRead_IDEX,   // Señales de control en ID/EX
    RegDst_IDEX,                  // Selección del registro destino en ID/EX
    ControlStall,
    RegWrite_IDEX,
    RegWrite_EXMEM,
    RegisterDst_EXMEM,
    BranchFlush,
    // --- Salidas ---  
    PCWrite, IFIDWrite            // Señales de control para manejar peligros
);

    //--------------------------------
    // Entradas
    //--------------------------------
    input [5:0] OpCode, Func;
    input RegWrite_EXMEM,MemRead_IDEX, RegWrite_IDEX;   // Señales de control para lectura y escritura
    input [1:0] RegDst_IDEX;             // Selección del registro destino en la etapa ID/EX
    input [4:0] RegisterDst_EXMEM,RegRS_IFID, RegRT_IFID;  // Registros fuente en la etapa IF/ID
    input [4:0] RegRT_IDEX, RegRD_IDEX;  // Registros destino en la etapa ID/EX

    //--------------------------------
    // Salidas
    //--------------------------------
    output reg PCWrite, IFIDWrite ,BranchFlush,  ControlStall ;       // Señales para detener la ejecución (stalls)

    //--------------------------------
    // Inicialización de salidas
    //--------------------------------
    initial begin
        PCWrite   <= 1'b1;  // Inicialmente, permitir que el PC avance
        IFIDWrite <= 1'b1;  // Inicialmente, permitir que el pipeline avance
        ControlStall <= 1'b0;
        BranchFlush  <= 1'b1;
    end

    // OpCodes
    localparam [5:0] 
                     OP_ZERO_JR        = 6'b000000,   // 
                     OP_J           = 6'b000010,   // J
                     OP_JAL         = 6'b000011,   // JAL
                     OP_LW          = 6'b100011,   // LW
                     OP_SW          = 6'b101011,   // SW
                     OP_ADDI        = 6'b001000,   // ADDI
                     OP_ADDIU       = 6'b001001,   // ADDIU
                     LHU_TYPE       = 6'b100101,  //AGREGAR
                     LBU_TYPE       = 6'b100100,  //AGREGAR
                     LWU_TYPE       = 6'b100111,  //AGREGAR
                     OP_SB          = 6'b101000,   // SB
                     OP_SH          = 6'b101001,   // SH
                     OP_ORI         = 6'b001101,   // ORI
                     OP_XORI        = 6'b001110,   // XORI
                     OP_LUI         = 6'b001111,   // LUI
                     OP_LB          = 6'b100000,   // LB
                     OP_LH          = 6'b100001,   // LH
                     OP_ANDI        = 6'b001100,   // ANDI
                     OP_SLTI        = 6'b001010,   // SLTI
                     OP_SLTIU       = 6'b001011;   // SLTUI
    
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
            
            PCWrite      <= 1'b0;
            IFIDWrite    <= 1'b0;
            ControlStall <= 1'b1;
            BranchFlush  <= 1'b0;   // funcionaaaa
        end 

        /*  El problema es que en ambas situaciones, el JR está intentando leer un registro que está siendo modificado
        por una instrucción que se ejecuta en EX o MEM (JAL o LW). Esto genera una dependencia de control o de datos
            que necesita ser resuelta mediante el control de stall y flush para asegurar que las instrucciones se ejecuten
            correctamente sin leer o escribir datos incorrectos.*/


            // JR in ID and JAL in EX or MEM
            else if ( OpCode == OP_ZERO_JR && Func == 6'b001000 && 
                    ((RegWrite_IDEX && RegDst_IDEX == 2'b10) || (RegWrite_EXMEM && RegisterDst_EXMEM == 5'd31)) ) begin

                   /* - OpCode == JR && Func == 6'b001000     -> instruccion JR
                    - RegWrite_IDEX && RegDst_IDEX == 2'b10 -> si la instruccion que esta en EX quiere escribir 
                                        y el valor que se guardara en ese registro viene del resultado de la ALU
                    - (RegWrite_EXMEM && RegisterDst_EXMEM == 5'd31) -> si la instruccion que esta en MEM quiere escribir 
                                        y el valor que se guardara es en el registro 31 (ra)   */                  
                

                PCWrite      <= 1'b0;
                IFIDWrite    <= 1'b0;
                ControlStall <= 1'b1;
                BranchFlush  <= 1'b1;
            
            end
            
            // JR in ID and lw in EX or MEM
            else if ( OpCode == OP_ZERO_JR && Func == 6'b001000 && 
                    ((RegWrite_IDEX && (RegRT_IDEX == RegRS_IFID || RegRD_IDEX == RegRS_IFID)) || 
                    (RegWrite_EXMEM && RegisterDst_EXMEM == RegRS_IFID)) ) begin

                    /*       - OpCode == JR && Func == 6'b001000     -> instruccion JR
                    - RegWrite_IDEX -> si la instruccion que esta en EX quiere escribir 
                    - RegRT_IDEX == RegRS_IFID -> Si la instrucción en IDEX escribe en un registro 
                        (por ejemplo, el registro de destino de un LW o SW) y la instrucción en IFID está 
                        intentando leer ese mismo registro, entonces esa condición se cumple.    
                    - RegRD_IDEX == RegRS_IFID -> La instrucción en IDEX escribe en un registro (RD), y la 
                    instrucción en IFID usa el mismo registro como fuente (RS). Esto implica que la instrucción
                    en IFID depende de un valor que aún no ha sido escrito por la instrucción en IDEX.                 
                    - (RegWrite_EXMEM && RegisterDst_EXMEM == RegRS_IFID) -> si la instruccion que esta en MEM quiere escribir 
                                        y el valor que se guardara es en el registro RegRS_IFID (ra) 
                                    ESTE ELSE RESUELVE EL CASO:  add $v0, $t2, $t6               
                                                                 jr  $v0       
                                        */  
                                                          


                PCWrite      <= 1'b0;
                IFIDWrite    <= 1'b0;
                ControlStall <= 1'b1;
                BranchFlush  <= 1'b0;
                
        
            end 

       // J    FUNCIONAA
        else if ( OpCode == OP_J || OpCode == OP_JAL || (OpCode == OP_ZERO_JR && (Func == 6'b001000 || Func == 6'b001001)) ) begin
            PCWrite      <= 1'b1;
            IFIDWrite    <= 1'b0;
            ControlStall <= 1'b0;
            BranchFlush  <= 1'b1;
        end 

        
        else begin 
            // Caso por defecto: No hay peligro detectado.
            // Permitir que el pipeline avance normalmente.
            PCWrite      <= 1'b1;
            IFIDWrite    <= 1'b1;
            ControlStall <= 1'b0;
            BranchFlush  <= 1'b1;
        end

    end

endmodule
