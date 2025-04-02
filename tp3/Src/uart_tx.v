module uart_tx #(
    parameter NB_DATA = 8, // Tamaño del dato en bits
    parameter NB_STOP = 16 // Duración del bit de parada
)(
    input  wire                   clk,         // Reloj del sistema
    input  wire                   i_rst_n,     // Reset activo en bajo
    input  wire                   i_tick,      // Pulso de reloj para la transmisión
    input  wire                   i_start_tx,  // Señal para iniciar la transmisión
    input  wire [NB_DATA - 1 : 0]  i_data,      // Dato a transmitir
    output wire                   o_txdone,    // Indica que la transmisión ha finalizado
    output wire                   o_data       // Salida de datos serializados
);

    // Registros internos
    reg [3:0] tick_counter, next_tick_counter; // Contador de ticks para sincronización
    reg [3:0] state, next_state;               // Estado actual y siguiente de la FSM
    reg [2:0] txBits, next_txBits;             // Contador de bits transmitidos
    reg [NB_DATA-1:0] txByte, next_txByte;     // Registro del byte a transmitir
    reg done_bit, next_done_bit;               // Bandera de finalización
    reg tx_reg, next_tx;                       // Registro de salida de datos
    
    // Definición de estados de la FSM
    localparam [3:0] 
        IDLE     = 4'b0001, // Estado inactivo
        START    = 4'b0010, // Enviando bit de inicio
        TRANSMIT = 4'b0100, // Transmitiendo datos
        STOP     = 4'b1000; // Enviando bit de parada

    // Lógica secuencial: Cambio de estado en flancos de reloj
    always @(posedge clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            state         <= IDLE;
            tick_counter  <= 0;
            txBits        <= 0;
            txByte        <= 0;
            done_bit      <= 0;
            tx_reg        <= 1'b1; // La salida se mantiene en alto cuando no se transmite
        end else begin  
            state         <= next_state;
            tick_counter  <= next_tick_counter;
            txBits        <= next_txBits;
            txByte        <= next_txByte;
            tx_reg        <= next_tx;
            done_bit      <= next_done_bit;
        end
    end

    // Lógica combinacional: Control de la transmisión
    always @(*) begin
        next_done_bit      = 1'b0;
        next_state         = state;
        next_tick_counter  = tick_counter;
        next_txBits        = txBits;
        next_txByte        = txByte;
        next_tx            = tx_reg;
        
        case (state)
            IDLE: begin
                next_tx = 1'b1;
                if (i_start_tx) begin
                    next_state        = START;
                    next_tick_counter = 0;
                    next_txByte       = i_data; // Cargar el dato en el buffer
                end
            end
            
            START: begin
                next_tx = 1'b0; // Enviar bit de inicio
                if (i_tick) begin
                    if (tick_counter == (NB_STOP - 1)) begin
                        next_state        = TRANSMIT;
                        next_tick_counter = 0;
                        next_txBits       = 0;
                    end else begin
                        next_tick_counter = tick_counter + 1;
                    end
                end
            end
            
            TRANSMIT: begin
                next_tx = txByte[0]; // Enviar bit menos significativo
                if (i_tick) begin
                    if (tick_counter == (NB_STOP - 1)) begin
                        next_tick_counter = 0;
                        next_txByte       = txByte >> 1; // Desplazar los bits a la derecha
                        if (txBits == (NB_DATA - 1)) begin
                            next_state = STOP;
                        end else begin
                            next_txBits = txBits + 1;
                        end
                    end else begin
                        next_tick_counter = tick_counter + 1;
                    end
                end
            end
            
            STOP: begin 
                next_tx = 1'b1; // Enviar bit de parada
                if (i_tick) begin
                    if (tick_counter == (NB_STOP - 1)) begin
                        next_state    = IDLE;
                        next_done_bit = 1'b1; // Indicar que la transmisión ha terminado
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

    // Asignaciones de salida
    assign o_data   = tx_reg;   // Salida serial de datos
    assign o_txdone = done_bit; // Indica que la transmisión ha finalizado

endmodule
