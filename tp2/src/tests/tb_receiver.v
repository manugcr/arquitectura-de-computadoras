`timescale 1ns / 1ps

module tb_receiver;
    
    // Parameters
    localparam DBIT = 8;          // Número de bits de datos
    localparam TICKS_END = 16;    // Ticks por bit

    // Señales
    reg clk;
    reg reset;
    reg rx;
    reg tick;
    wire data_ready;
    wire [DBIT-1:0] data_out;

    // Instanciar el módulo receptor
    receiver #(
        .DBIT(DBIT),
        .TICKS_END(TICKS_END)
    ) uut (
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .tick(tick),
        .data_ready(data_ready),
        .data_out(data_out)
    );

    // Generar el reloj
    always #5 clk = ~clk;  // Periodo de 10 ns (100 MHz)

    // Generar ticks
    always #10 tick = ~tick;  // Ticks cada 20 ns

    // Proceso de estimulación
    initial begin
        // Inicialización
        clk = 0;
        tick = 0;
        reset = 1;
        rx = 1;    // Línea rx en HIGH (sin transmisión)
        #100;
        
        // Liberar el reset
        reset = 0;
        
        // Simulación de una trama UART (8 bits de datos con 1 bit de inicio y 1 de parada)
        
        // Bit de inicio (start bit: LOW)
        rx = 0;
        repeat(16) @(posedge tick);  // Espera 16 ticks (un bit completo)
        
        // Enviar los 8 bits de datos: 10101010 (paridad alternada)
        rx = 1;  // Bit 0
        repeat(16) @(posedge tick);
        
        rx = 1;  // Bit 1
        repeat(16) @(posedge tick);
        
        rx = 1;  // Bit 2
        repeat(16) @(posedge tick);
        
        rx = 0;  // Bit 3
        repeat(16) @(posedge tick);
        
        rx = 1;  // Bit 4
        repeat(16) @(posedge tick);
        
        rx = 1;  // Bit 5
        repeat(16) @(posedge tick);
        
        rx = 1;  // Bit 6
        repeat(16) @(posedge tick);
        
        rx = 0;  // Bit 7
        repeat(16) @(posedge tick);

        // Bit de parada (stop bit: HIGH)
        rx = 1;
        repeat(16) @(posedge tick);

        // Esperar unos ciclos adicionales para ver el resultado
        #100;
        
        // Finalizar simulación
        $stop;
    end
endmodule
