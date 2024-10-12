module tb_transmitter;
    reg clk;
    reg reset;
    reg tx_go;
    reg pulse_tick;
    reg [7:0] din;
    wire tx_done_tick;
    wire tx;

    transmitter uut (
        .clk(clk),
        .reset(reset),
        .tx_go(tx_go),
        .pulse_tick(pulse_tick),
        .din(din),
        .tx_done_tick(tx_done_tick),
        .tx(tx)
    );

    initial begin
        // Inicialización
        clk = 0;
        reset = 1;
        tx_go = 0;
        pulse_tick = 0;
        din = 8'b10101110; // Dato a enviar

        #10 reset = 0; // Desactivar reset
        #10 tx_go = 1; // Comenzar transmisión

        // Generar pulsos de reloj y ticks
        forever begin
            #5 clk = ~clk; // Cambia el reloj cada 5 ns
            pulse_tick = (clk == 1); // Generar pulso en clk
            #5 pulse_tick = 0;
        end
    end

    initial begin
        // Monitorear señales importantes
        $monitor("Time: %0t | TX_GO: %b | DIN: %b | TX: %b | TX_Done: %b",
                 $time, tx_go, din, tx, tx_done_tick);
    end

    initial begin
        #500; // Espera un tiempo para observar la transmisión
        $finish; // Terminar simulación
    end
endmodule
