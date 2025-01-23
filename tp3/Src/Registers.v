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

        

       /* registers[9] = 10;  // ah
        registers[10] = 20; // 14h
        registers[11] = 30; // 1eh
        registers[12] = 40; // 28h
        */


        // Inicializa el puntero de pila (registro 29)
       // registers[29] = 54400;

      //  registers[16] = 8;
       // registers[18] = 4;

       // flag_end = 1'b0;



      //registers[19] = 4 ;  // ah


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
