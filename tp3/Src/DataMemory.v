`timescale 1ns / 1ps



module DataMemory(Address, WriteData, Clock, MemWrite, MemRead, ReadData, ByteSig); 

    input [31:0] Address;       // Input Address 
    input [31:0] WriteData;     // Data that needs to be written into the address 
    input Clock;
    input MemWrite;             // Control signal for memory write 
    input MemRead;              // Control signal for memory read 
    input [1:0] ByteSig;

    output reg[31:0] ReadData;  // Contents of memory location at Address
    
    reg [31:0] memory [0:13600];    // Reminder: Update stack pointer


    
    // Variable para inicialización
    integer i;

    // Inicialización de la memoria desde un archivo y valores por defecto
    initial begin
        $readmemh("Data_memory.mem", memory, 0, 13600); // Cargar datos iniciales desde archivo
        
        // Inicializar la memoria con valores incrementales (opcional)
        for (i = 0; i < 13600; i = i + 1) begin
            memory[i] = 0;
        end
            
           memory[5] = 32'hAAAAAAAA;   //En la simulación, la dirección de memoria se está interpretando como 00000005. 
          //Esto corresponde a la posición memory[5] debido al acceso truncado Address[31:2]
     


        // Escribir los valores iniciales en un archivo para referencia
        $writememh("Data_memory.mem", memory);
        

        
    end

    // Bloque siempre para escritura en memoria (controlado por reloj)
    always @ (posedge Clock) begin
    

        if (MemWrite == 1'b1) begin // Verificar señal de escritura activa
            // Escritura de palabra completa (sw)
            $display("ByteSig: %b", ByteSig);
            if (ByteSig == 2'b00) begin
                $display("Condición ByteSig == 2'b00 cumplida");
                memory[Address[31:2]] <= WriteData;  

        /*   SUPONIENDO: instruccion  sw  $s0 , 14($s1)  ->   sw 8, 14(10)           
                ____                         
            00  |    | 0       Address: 18H = 24d = 10d + 14d (offset) = 000110   00 (Descartado)
            04  |    | 1       
            08  |    | 2
            0C  |    | 3
            10  |    | 4
            14  |    | 5
            18  | 8  | 6
                ----
    */
                
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
            
                   // Depuración: imprimir mensaje de escritura
                 $display("Escritura en memoria: Direccion = %h, WriteData = %h, ByteSig = %b", Address[31:2], WriteData, ByteSig);


                $writememh("Data_memory.mem", memory);
        end
    end


    always @ (posedge Clock) begin
        ReadData <= 32'b0; // Inicializar dato leído en 0 por defecto
        
        if (MemRead == 1'b1) begin // Verificar señal de lectura activa
            // Lectura de palabra completa (lw)
            if (ByteSig == 2'b00) begin
                ReadData <= memory[Address[31:2]];
                $display("LOAD en memoria: Direccion = %h, ReadData = %h, ByteSig = %b", Address[31:2], ReadData, ByteSig);
            end
            
            // Lectura de media palabra (lh)
            else if (ByteSig == 2'b01) begin
                if      (Address[1:0] == 2'b00) 
                    ReadData <= {{16{memory[Address[31:2]][15]}}, memory[Address[31:2]][15:00]}; // Signo extendido, mitad inferior
                else if (Address[1:0] == 2'b10) 
                    ReadData <= {{16{memory[Address[31:2]][31]}}, memory[Address[31:2]][31:16]}; // Signo extendido, mitad superior
            end
            
            // Lectura de byte (lb)
            else if (ByteSig == 2'b10) begin
                if      (Address[1:0] == 2'b00) 
                    ReadData <= {{24{memory[Address[31:2]][07]}}, memory[Address[31:2]][07:00]}; // Signo extendido, byte inferior
                else if (Address[1:0] == 2'b01) 
                    ReadData <= {{24{memory[Address[31:2]][15]}}, memory[Address[31:2]][15:08]}; // Signo extendido, segundo byte
                else if (Address[1:0] == 2'b10) 
                    ReadData <= {{24{memory[Address[31:2]][23]}}, memory[Address[31:2]][23:16]}; // Signo extendido, tercer byte
                else if (Address[1:0] == 2'b11) 
                    ReadData <= {{24{memory[Address[31:2]][31]}}, memory[Address[31:2]][31:24]}; // Signo extendido, byte superior
            end

            /* else begin
                ReadData <= 32'b0;
            end*/

        end
    end

endmodule
