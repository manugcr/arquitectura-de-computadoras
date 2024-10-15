module receiver #(
    NB_DATA = 8,      // Número de bits de datos a recibir
    NB_STOP = 1       // Número de bits de parada
) (
    input wire i_reset,          // Señal de reset
    input wire i_clk,            // Señal de reloj
    input wire i_tick,           // Señal que indica un ciclo de reloj válido
    input wire i_rx,             // Línea de recepción UART
    output wire [NB_DATA-1:0] o_rx_array, // Datos recibidos
    output wire o_rx_end         // Señal que indica la finalización de la recepción
);

  // Definición de estados como constantes
  localparam st_idle  = 2'b00;  // Estado de espera
  localparam st_start = 2'b01;  // Estado de inicio (bit de start)
  localparam st_data  = 2'b10;  // Estado de recepción de datos
  localparam st_stop  = 2'b11;  // Estado de parada (bits de stop)

  // Registros para el estado actual y el siguiente
  reg [1:0] state_reg, state_next;

  // Registros para contar ticks y datos recibidos
  reg [3:0] tick_count, next_tick_count; // Contador de ticks
  reg [2:0] data_count, next_data_count; // Contador de bits de datos recibidos
  reg [NB_DATA-1:0] data, next_data;     // Registro para almacenar los datos recibidos
  reg rx_done;                            // Señal que indica que la recepción ha terminado

  // Gestión de estados (FSM)
  always @(posedge i_clk) begin
    if (i_reset) begin
      // Al reset, inicializar registros a valores por defecto
      state_reg <= st_idle;             // Establecer estado a IDLE
      tick_count <= 0;                  // Reiniciar contador de ticks
      data_count <= 0;                  // Reiniciar contador de datos
      data <= {NB_DATA{1'b0}};          // Inicializar datos a cero
    end else begin
      // Actualizar el estado actual y los contadores
      state_reg <= state_next;          // Actualizar al siguiente estado
      tick_count <= next_tick_count;    // Actualizar contador de ticks
      data_count <= next_data_count;     // Actualizar contador de datos
      data <= next_data;                 // Actualizar datos
    end
  end

  // Lógica combinacional para determinar el siguiente estado y las acciones
  always @(*) begin
    // Inicializar valores por defecto para la lógica de transición
    state_next = state_reg;             // Establecer el siguiente estado al actual
    rx_done = 1'b0;                     // Inicializar la señal de finalización de recepción
    next_tick_count = tick_count;       // Mantener el contador de ticks
    next_data_count = data_count;       // Mantener el contador de datos
    next_data = data;                   // Mantener los datos actuales

    // Control de estados
    case (state_reg)
      st_idle: begin
        if (~i_rx) begin
          // Si se detecta el bit de inicio (i_rx en bajo), cambiar al estado de inicio
          state_next = st_start;
          next_tick_count = 0;          // Reiniciar contador de ticks
        end
      end

      st_start: begin
        // Alinearse con la mitad del bit de inicio
        if (i_tick) begin
          if (tick_count < 7) begin
            next_tick_count = tick_count + 1; // Incrementar contador de ticks
          end else begin
            // Si estamos alineados, cambiar al estado de recepción de datos
            state_next = st_data;
            next_tick_count = 4'b0;         // Reiniciar contador de ticks
            next_data_count = 3'b0;         // Reiniciar contador de datos
          end
        end
      end

      st_data: begin
        // Recepción de datos (NB_DATA bits)
        if (i_tick) begin
          if (tick_count < 15) begin
            next_tick_count = tick_count + 1; // Incrementar contador de ticks
          end else begin
            // Se ha recibido el siguiente bit de datos
            next_tick_count = 4'b0;             // Reiniciar contador de ticks
            // Ingresar nuevo valor de i_rx al MSB y desplazar los demás bits
            next_data = {i_rx, data[NB_DATA-1:1]};
            if (data_count == (NB_DATA - 1)) begin
              // Si se han recibido todos los bits de datos, cambiar al estado de parada
              state_next = st_stop;
            end else begin
              // Aumentar contador de datos
              next_data_count = data_count + 1;
            end
          end
        end
      end

      st_stop: begin
        if (i_tick) begin
          // Esperar la cantidad de ticks correspondientes a los bits de parada
          if (tick_count < (NB_STOP * 16 - 1)) begin
            next_tick_count = tick_count + 1; // Incrementar contador de ticks
          end else begin
            // Se ha completado la trama UART, volver al estado IDLE
            state_next = st_idle;
            rx_done = 1'b1; // Indicar que la recepción ha terminado
          end
        end
      end

      default: state_next = st_idle; // Volver al estado IDLE en caso de un estado no reconocido
    endcase
  end

  // Asignar las salidas
  assign o_rx_array = data; // Salida de datos recibidos
  assign o_rx_end = rx_done; // Salida que indica que la recepción ha terminado

endmodule
