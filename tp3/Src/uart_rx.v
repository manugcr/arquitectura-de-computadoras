/*
    Proceso de recepción de datos en la UART
        Suponiendo un total de N bits de datos y M bits de Stop:
    
        1) Permanecer en espera hasta que la señal de entrada pase a 0, 
           lo que indica el inicio del bit de Start. Iniciar el contador de ticks. ---> IDLE

        2) Cuando el contador alcance el valor 7, la señal de entrada se encontrará 
           en la mitad del bit de Start. Reiniciar el contador. ---> START
        
        3) Al llegar a 15, la señal de entrada habrá avanzado un bit y se ubicará 
           en la mitad del primer bit de datos. Capturar este valor y almacenarlo 
           en un registro de desplazamiento. Reiniciar el contador. ---> RECEIVE
        
        4) Repetir el paso 3 un total de N-1 veces para capturar los bits restantes.
        
        5) Si se usa un bit de paridad, repetir nuevamente el paso 3.
        
        6) Repetir el paso 3 un total de M veces para procesar los bits de Stop. ---> STOP
*/

module uart_rx
#(
    parameter NB_DATA  = 8,  // Número de bits de datos
    parameter NB_STOP  = 16  // Número de bits de Stop
)(
    input   wire                    clk,        // Señal de reloj
    input   wire                    i_reset,    // Reset activo en bajo
    input   wire                    i_tick,     // Pulso de sincronización
    input   wire                    i_data,     // Entrada de datos serial
    output  wire [NB_DATA - 1 : 0]  o_data,     // Datos recibidos
    output  wire                    o_rxdone    // Señal de recepción completa
);

    reg [3:0]   tick_counter;       // Contador de ticks
    reg [3:0]   next_tick_counter;  // Próximo valor del contador de ticks
    
    reg [3:0]   state, next_state;  // Estado actual y siguiente

    reg [3:0]   recBits;            // Contador de bits recibidos
    reg [3:0]   next_recBits;

    reg [NB_DATA-1:0] recByte;       // Registro para almacenar los datos recibidos
    reg [NB_DATA-1:0] next_recByte;

    reg          done_bit, next_done_bit; // Señal de recepción completa

    // Definición de estados
    localparam [3:0] 
                    IDLE    = 4'b0001, // Espera de bit de inicio
                    START   = 4'b0010, // Sincronización con el bit de inicio
                    RECEIVE = 4'b0100, // Recepción de bits de datos
                    STOP    = 4'b1000; // Recepción de bits de Stop
 
    // Registro de estado y datos
    always @(posedge clk or negedge i_reset) begin
        if(!i_reset) begin
            state         <= IDLE;
            tick_counter  <= 0;
            recBits       <= 0;
            recByte       <= 8'b00000000;
            done_bit      <= 0;
        end else begin              
            state         <= next_state;
            tick_counter  <= next_tick_counter;
            recBits       <= next_recBits;
            recByte       <= next_recByte;
            done_bit      <= next_done_bit;
        end
    end

    // Máquina de estados
    always @(*) begin
        next_state         = state;
        next_tick_counter  = tick_counter;
        next_recBits       = recBits;
        next_recByte       = recByte;
        next_done_bit      = done_bit; 

        case (state) 
            IDLE: begin
                next_done_bit = 0; 
                if(!i_data) begin  // Detección del bit de inicio
                    next_state        = START;
                    next_tick_counter = 0;
                end
            end
            START: begin
                if(i_tick) begin
                    if(tick_counter == 7) begin  // Sincronización con el bit de inicio
                        next_state        = RECEIVE;
                        next_tick_counter = 0;
                        next_recBits      = 0;
                    end else begin 
                        next_tick_counter = tick_counter + 1;
                    end
                end
            end
            RECEIVE: begin
                if(i_tick) begin
                    if(tick_counter == 15) begin  // Muestreo en la mitad del bit
                        next_tick_counter = 0;
                        next_recByte = {i_data, recByte[NB_DATA-1:1]}; // Shift register
                        if(recBits == (NB_DATA-1)) begin 
                            next_state = STOP; // Pasar a estado STOP cuando se reciben todos los bits
                        end else begin 
                            next_recBits = recBits + 1;
                        end
                    end else begin 
                        next_tick_counter = tick_counter + 1;
                    end
                end
            end
            STOP: begin
                if(i_tick) begin
                    if(tick_counter == (NB_STOP-1)) begin  // Finalización de la trama
                        next_state = IDLE;
                        if(i_data) next_done_bit = 1;  // Dato recibido correctamente
                    end else begin
                        next_tick_counter = tick_counter + 1;
                    end
                end
            end
            default: begin 
                next_state = IDLE;
            end
        endcase
    end

    assign o_data   = recByte;   // Salida de datos recibidos
    assign o_rxdone = done_bit;  // Indicación de recepción completa
    
endmodule
