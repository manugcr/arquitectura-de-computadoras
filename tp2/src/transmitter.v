module transmitter #(
    NB_DATA = 8,  // Número de bits de datos a transmitir
    NB_STOP = 1   // Número de bits de parada
) (
    input wire i_reset,                   // Señal de reset
    input wire i_tick,                    // Señal de reloj de ticks para la transmisión
    input wire i_clk,                     // Reloj del sistema
    input wire i_tx_start,                // Señal para iniciar la transmisión
    input wire [NB_DATA-1:0] i_tx_array,  // Datos a transmitir
    output wire o_tx_end,                 // Señal que indica que la transmisión ha terminado
    output wire o_tx                      // Señal que transmite el bit actual
);

  localparam st_idle = 1'b0;            // Estado de reposo (idle)
  localparam st_transmitting = 1'b1;    // Estado de transmisión (sending)
  
  localparam size_data = 10;             // Tamaño total del marco (10 bits: 8 de datos, 1 de inicio, 1 de parada)

  reg state, next_state;                  // Registro para el estado actual y el siguiente estado
  reg [3:0] tick_count, next_tick_count; // Contador de ticks
  reg [3:0] data_count, next_data_count; // Contador de datos transmitidos
  reg tx, next_tx;                        // Registro para la señal de transmisión actual
  reg [size_data-1:0] data, next_data;   // Registro para almacenar la trama completa a transmitir (datos + bits de inicio y parada)
  reg tx_done;                            // Registro que indica si la transmisión ha terminado

  // Gestor de estados
  always @(posedge i_clk) begin
    if (i_reset) begin
      // Si se recibe un reset, inicializa los registros
      state <= st_idle;                 // Establece el estado en idle
      tick_count <= 0;                  // Reinicia el contador de ticks
      data_count <= 0;                  // Reinicia el contador de datos
      data <= {size_data{1'b0}};        // Inicializa la trama con ceros
      tx <= 1'b1;                       // Establece la señal de transmisión en alto (idle)
    end else begin
      // Actualiza los registros al siguiente estado
      state <= next_state;
      tick_count <= next_tick_count;
      data_count <= next_data_count;
      data <= next_data;
      tx <= next_tx;
    end
  end

  always @(*) begin
    // Lógica combinacional para determinar el siguiente estado
    next_state = state;                  // Inicializa el siguiente estado
    tx_done = 1'b0;                      // Inicializa la señal de finalización en bajo
    next_tick_count = tick_count;        // Inicializa el siguiente contador de ticks
    next_data_count = data_count;        // Inicializa el siguiente contador de datos
    next_data = data;                    // Inicializa el siguiente dato
    next_tx = tx;                        // Inicializa la siguiente señal de transmisión
    case (state)
      st_idle: begin
        next_tx = 1'b1;                  // En el estado idle, la señal de transmisión está en alto
        if (i_tx_start) begin            // Si se recibe la señal de inicio de transmisión
          // Prepara la trama a enviar (bits de parada + datos + bit de inicio)
          next_data = {{NB_STOP{1'b1}}, i_tx_array, 1'b0}; 
          next_state = st_transmitting; // Cambia al estado de transmisión
          next_data_count = 0;           // Reinicia el contador de datos
          next_tick_count = 0;           // Reinicia el contador de ticks
        end
      end

      st_transmitting: begin
        next_tx = data[0];               // Envía el siguiente bit (el LSB de la trama)
        if (i_tick) begin                 // Si se recibe un tick
          if (tick_count < 15) begin      // Cuenta hasta 15 ticks
            next_tick_count = tick_count + 1; // Incrementa el contador de ticks
          end else begin                  // Después de 15 ticks
            next_tick_count = 0;          // Reinicia el contador de ticks
            next_data = data >> 1;        // Desplaza la trama hacia la derecha (envía el siguiente bit)
            if (data_count < (size_data - 1)) begin
              next_data_count = data_count + 1; // Aumenta el contador de datos
            end else begin
              // Si se ha terminado de enviar, regresa al estado idle
              next_state = st_idle;
              tx_done = 1'b1;              // Indica que la transmisión ha terminado
            end
          end
        end
      end

      default: begin
        next_state = st_idle;             // Si el estado no es válido, regresa al estado idle
      end
    endcase
  end

  // Salidas del módulo
  assign o_tx = tx;                     // Salida de transmisión actual
  assign o_tx_end = tx_done;            // Salida que indica que la transmisión ha terminado

endmodule
