`timescale 1ns / 1ps

module Registers(
    input [4:0] ReadRegister1, ReadRegister2, WriteRegister,
    input [31:0] WriteData,
    input RegWrite, Clock,
    output reg [31:0] ReadData1, ReadData2
);

    reg [31:0] registers [0:31];


   // reg flag_end;

    // Inicialización de los registros
    integer i;
    initial begin
        // Inicializa todos los registros a 0
       for (i = 0; i < 32; i = i + 1) begin
            registers[i] = i;
        end
        // Inicializa el puntero de pila (registro 29)*/

        /*  VALORES DEL FOR:
        $zero = 0, $at = 1, $v0 = 2, $v1 = 3, $a0 = 4, $a1 = 5, $a2 = 6, $a3 = 7,  
        $t0 = 8, $t1 = 9, $t2 = 10, $t3 = 11, $t4 = 12, $t5 = 13, $t6 = 14, $t7 = 15,  
        $s0 = 16, $s1 = 17, $s2 = 18, $s3 = 19, $s4 = 20, $s5 = 21, $s6 = 22, $s7 = 23,  
        $t8 = 24, $t9 = 25, $k0 = 26, $k1 = 27, $gp = 28, $sp = 29, $fp = 30, $ra = 31  
        */
        
        
       

        // Crea o limpia el archivo registers.mem
        $writememh("registers.mem", registers);
    end

    // Escritura sincronizada con el flanco de BAJADA del reloj, cuando estaba en subida, generaba problemas de concurrencia
    // ya que queria escribir y leer en el mismo momento (primero se leia ANTES de que se actualizara el registro)
    always @(negedge Clock) begin
        if (RegWrite) begin

             // Almacena las señales intermedias en registros
           // WriteData_reg <= WriteData;
          //*  WriteRegister_reg <= WriteRegister;

            // Escribe en el registro alineando WriteData y WriteRegister
            registers[WriteRegister] = WriteData;

            
            // Actualiza el archivo de memoria para depuración
            $writememh("registers.mem", registers);

               $display("Tiempo: %0t, Escritura en registro[%0d]: %0h", $time, WriteRegister, WriteData);

            

        end

    end

    // Lectura combinacional
    always @(*) begin
        ReadData1 = registers[ReadRegister1];
        ReadData2 = registers[ReadRegister2];
    end

endmodule
