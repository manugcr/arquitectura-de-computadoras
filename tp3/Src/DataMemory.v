`timescale 1ns / 1ps


module DataMemory(Address, WriteData, Clock, MemWrite, MemRead, ReadData, ByteSig, o_bus_debug, i_flush,Reset); 

//module DataMemory(Address, WriteData, Clock, MemWrite, MemRead, ReadData, ByteSig, Reset); 


    input [31:0] Address;       // Input Address 
    input [31:0] WriteData;     // Data that needs to be written into the address 
    input Clock;
    input MemWrite;             // Control signal for memory write 
    input MemRead;              // Control signal for memory read 
    input [1:0] ByteSig;
    input Reset;

    output reg[31:0] ReadData;  // Contents of memory location at Address
    
    reg [31:0] memory [0:31];    // Reminder: Update stack pointer

    //DEBUGG

    output wire [32 * 32 - 1 : 0] o_bus_debug; // Debug bus showing entire memory content

    input i_flush;
    integer i;
    // Variable para inicialización
   /* integer i;

    // Inicialización de la memoria desde un archivo y valores por defecto
    initial begin
        $readmemh("Data_memory.mem", memory, 0, 31); // Cargar datos iniciales desde archivo
        
        // Inicializar la memoria con valores incrementales (opcional)
        for (i = 0; i < 31; i = i + 1) begin
            memory[i] = 0;
        end
            
          memory[5] = 32'h0000000A   ;   
          memory[6] = 32'h0000000A   ;   


        // Escribir los valores iniciales en un archivo para referencia
        $writememh("Data_memory.mem", memory);
        

        
    end */

    // Bloque siempre para escritura en memoria (controlado por reloj)
    always @ (posedge Clock) begin
        if(i_flush)begin
            begin
            // Reset or flush: clear all memory locations
            for (i = 0; i < 32; i = i + 1)
                memory[i] <= 'b0;
            end
        end 
        else begin
        if(Reset)begin
            for (i = 0; i < 31; i = i + 1) begin
            memory[i] = 0;
             end

            memory[5] = 32'h0000000A   ;   
          memory[6] = 32'h0000000A   ;   

        end
        if (MemWrite == 1'b1) begin // Verificar señal de escritura activa
            // Escritura de palabra completa (sw)

            if (ByteSig == 2'b00) begin
 
                memory[Address[31:2]] <= WriteData;  

            end

            // Escritura de media palabra (sh)
            else if (ByteSig == 2'b01) begin
                if      (Address[1:0] == 2'b00) memory[Address[31:2]][15:00] <= WriteData[15:0]; // Media palabra inferior
                else if (Address[1:0] == 2'b10) memory[Address[31:2]][31:16] <= WriteData[15:0]; // Media palabra superior
            end
            
            // Escritura de byte (sb)
            else if (ByteSig == 2'b10) begin
                if      (Address[1:0] == 2'b00) memory[Address[31:2]][07:00] <= WriteData[7:0];  // Byte inferior
                else if (Address[1:0] == 2'b01) memory[Address[31:2]][15:08] <= WriteData[7:0];  // Segundo byte
                else if (Address[1:0] == 2'b10) memory[Address[31:2]][23:16] <= WriteData[7:0];  // Tercer byte
                else if (Address[1:0] == 2'b11) memory[Address[31:2]][31:24] <= WriteData[7:0];  // Byte superior
            end
            
             //   $writememh("Data_memory.mem", memory);
        end
    end
    end


     // load
    always @ (*) begin
        ReadData = 32'b0; // Inicializar dato leído en 0 por defecto
        
        if (MemRead == 1'b1) begin // Verificar señal de lectura activa
            // Lectura de palabra completa (lw)
            if (ByteSig == 2'b00) begin
                ReadData = memory[Address[31:2]];
            //    $display("LOAD en memoria: Direccion = %h, ReadData = %h, ByteSig = %b", Address[31:2], ReadData, ByteSig);
            end
            
            // Lectura de media palabra (lh)
            else if (ByteSig == 2'b01) begin
                if      (Address[1:0] == 2'b00) 
                    ReadData = {{16{memory[Address[31:2]][15]}}, memory[Address[31:2]][15:00]}; // Signo extendido, mitad inferior
                else if (Address[1:0] == 2'b10) 
                    ReadData = {{16{memory[Address[31:2]][31]}}, memory[Address[31:2]][31:16]}; // Signo extendido, mitad superior
            end
            
            // Lectura de byte (lb)
            else if (ByteSig == 2'b10) begin
                if      (Address[1:0] == 2'b00) 
                    ReadData = {{24{memory[Address[31:2]][07]}}, memory[Address[31:2]][07:00]}; // Signo extendido, byte inferior
                else if (Address[1:0] == 2'b01) 
                    ReadData = {{24{memory[Address[31:2]][15]}}, memory[Address[31:2]][15:08]}; // Signo extendido, segundo byte
                else if (Address[1:0] == 2'b10) 
                    ReadData = {{24{memory[Address[31:2]][23]}}, memory[Address[31:2]][23:16]}; // Signo extendido, tercer byte
                else if (Address[1:0] == 2'b11) 
                    ReadData = {{24{memory[Address[31:2]][31]}}, memory[Address[31:2]][31:24]}; // Signo extendido, byte superior
            end

            /* else begin
                ReadData = 32'b0;
            end*/

        end
    end


     /// DEBUGGG

    // Bloque generate para mapear la memoria al bus de depuración
    generate
        genvar j;
        for (j = 0; j < 32; j = j + 1) begin : GEN_DEBUG_BUS
            assign o_bus_debug[(j + 1) * 32 - 1 : j * 32] = memory[j];
        end
    endgenerate
    /// VER SI ESTA BIEN ESTO!, EL GENERATE O SI SE MANDA AL REVES, (EN VEZ DE MANDAR LA PRIMERA PALABRA MANDA LA ULTIMA PRIMERO) */

endmodule
