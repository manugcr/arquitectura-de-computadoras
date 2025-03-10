`timescale 1ns / 1ps

module Registers(
    input [4:0] ReadRegister1, ReadRegister2, WriteRegister,
    input [31:0] WriteData,
    input RegWrite, Clock,Reset,
    output reg [31:0] ReadData1, ReadData2,
    output wire [32 * 32 - 1 : 0] o_bus_debug, // Debug bus showing all registers
    input i_flush
);

    reg [31:0] registers [0:31];
    integer i;

    /*  VALORES DEL FOR:
        $zero = 0, $at = 1, $v0 = 2, $v1 = 3, $a0 = 4, $a1 = 5, $a2 = 6, $a3 = 7,  
        $t0 = 8, $t1 = 9, $t2 = 10, $t3 = 11, $t4 = 12, $t5 = 13, $t6 = 14, $t7 = 15,  
        $s0 = 16, $s1 = 17, $s2 = 18, $s3 = 19, $s4 = 20, $s5 = 21, $s6 = 22, $s7 = 23,  
        $t8 = 24, $t9 = 25, $k0 = 26, $k1 = 27, $gp = 28, $sp = 29, $fp = 30, $ra = 31  
        */


    // Inicialización de los registros

    // integer i;

    /*  initial begin
        // Inicializa todos los registros a 0
       for (i = 0; i < 32; i = i + 1) begin
            registers[i] = i;
        end
        // Inicializa el puntero de pila (registro 29)

    
        // Crea o limpia el archivo registers.mem
        $writememh("registers.mem", registers);
    end */

    // Escritura sincronizada con el flanco de BAJADA del reloj, cuando estaba en subida, generaba problemas de concurrencia
    // ya que queria escribir y leer en el mismo momento (primero se leia ANTES de que se actualizara el registro)
    always @(negedge Clock) begin
        if(i_flush)begin

            for (i = 0; i < 32; i = i + 1) begin
            registers[i]  <= 'b0;
             end

        end 

        if(Reset) begin

             for (i = 0; i < 32; i = i + 1) begin
            registers[i] <= i;
            end

        end 

       // else if (RegWrite && WriteRegister != 0) begin   //ZERO siempre zero
         if (RegWrite && WriteRegister != 0) begin   //ZERO siempre zero

             // Almacena las señales intermedias en registros
           // WriteData_reg <= WriteData;
          //*  WriteRegister_reg <= WriteRegister;

            // Escribe en el registro alineando WriteData y WriteRegister
            registers[WriteRegister] <= WriteData;

            
            // Actualiza el archivo de memoria para depuración
           // $writememh("registers.mem", registers);

               $display("Tiempo: %0t, Escritura en registro[%0d]: %0h", $time, WriteRegister, WriteData);

            

        end

    end

    // Lectura combinacional
    always @(*) begin
        ReadData1 = registers[ReadRegister1];
        ReadData2 = registers[ReadRegister2];
    end



    /// debug

    // Generate a debug bus showing all registers
    generate
        genvar j;
        for (j = 0; j < 32; j = j + 1) begin : GEN_DEBUG_BUS
            assign o_bus_debug[(j + 1) * 32 - 1 : j * 32] = registers[j];
        end
    endgenerate

    /*
    el código generate genera cableado combinacional que conecta todos los registros al bus de
    depuración o_bus_debug. Como las asignaciones dentro del bloque generate son assign (combinacionales),
    las herramientas de síntesis pueden implementarlo correctamente en hardware.

    Este bus de depuración (o_bus_debug) permite leer todos los registros en paralelo, lo que facilita la 
    visualización en una herramienta de simulación o depuración sin acceder uno por uno.

    En lugar de escribir manualmente 32 líneas de asignación como:

    assign o_bus_debug[31:0] = registers[0];
    assign o_bus_debug[63:32] = registers[1];
    ...
    assign o_bus_debug[1023:992] = registers[31];

    se usa generate para hacer esto automáticamente en la etapa de síntesis.
    GEN_DEBUG_BUS es simplemente un nombre de bloque de generación dentro del generate.
    
    */



endmodule
