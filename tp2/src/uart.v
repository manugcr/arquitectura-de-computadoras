module uart #(
    parameter NB_DATA   = 8,    // Número de bits de datos
    parameter NB_ALU_OP = 6     // Número de bits para el código de operación de la ALU
) (
    input wire i_clk,                     // Señal de reloj
    input wire i_reset,                   // Señal de reinicio
    input wire i_rx_end,                  // Señal que indica el final de la recepción
    input wire [NB_DATA-1:0] i_rx_array,  // Array de datos recibidos
    input wire [NB_DATA-1:0] i_result_alu, // Resultado de la ALU
    output wire [NB_DATA-1:0] o_tx_array, // Array de datos a transmitir
    output wire [5:0]         o_operation, // Operación a realizar
    output wire [NB_DATA-1:0] o_operator_A, // Operador A para la ALU
    output wire [NB_DATA-1:0] o_operator_B, // Operador B para la ALU
    output wire o_tx_start                // Señal que indica el inicio de la transmisión
);

  // Definición de estados
  localparam st_idle         = 2'b00; // Estado de inactividad
  localparam st_receive      = 2'b01; // Estado de recepción de datos
  localparam st_transmitting = 2'b10; // Estado de transmisión de datos

  // Definición de códigos de operación (opcodes)
  localparam OP_LOAD_A     =  2'b00; // Opcode para cargar el Operador A
  localparam OP_LOAD_B     =  2'b01; // Opcode para cargar el Operador B
  localparam OP_RESULT     =  2'b10; // Opcode para obtener el resultado
  localparam OP_OPERATION  =  2'b11; // Opcode para especificar la operación

  // Registros para mantener el estado y las señales
  reg [1:0] state, next_state;                 // Estado actual y siguiente
  reg [7:0] control, next_control;             // Código de operación actual y siguiente
  reg [NB_DATA-1:0] operator_A, next_operator_A; // Operador A actual y siguiente
  reg [NB_DATA-1:0] operator_B, next_operator_B; // Operador B actual y siguiente
  reg [NB_ALU_OP-1:0] operation, next_operation; // Código de operación de la ALU actual y siguiente
  reg [NB_DATA-1:0] tx_data, next_tx_data;     // Datos a transmitir actual y siguiente
  reg tx_start, next_tx_start;                 // Señal de inicio de transmisión actual y siguiente
  reg control_error_flag, next_control_error_flag; // Flag de error en el control actual y siguiente

  // Manejo de estados y registros en flanco de reloj
  always @(posedge i_clk) begin
    if (i_reset) begin
      // Reinicia los registros y el estado
      state <= st_idle;                    // Restablecer al estado inactivo
      control <= 2'b00;                    // Reiniciar el control
      operator_A <= 0;                     // Reiniciar el Operador A
      operator_B <= 0;                     // Reiniciar el Operador B
      operation <= 0;                      // Reiniciar la operación
      tx_data <= 0;                        // Reiniciar los datos a transmitir
      tx_start <= 0;                       // Reiniciar la señal de inicio de transmisión
      control_error_flag <= 0;             // Reiniciar el flag de error
    end else begin
      // Actualiza los registros con los valores siguientes
      state <= next_state;                 // Cambiar al siguiente estado
      control <= next_control;             // Cambiar al siguiente control
      operator_A <= next_operator_A;       // Cambiar al siguiente Operador A
      operator_B <= next_operator_B;       // Cambiar al siguiente Operador B
      operation <= next_operation;         // Cambiar a la siguiente operación
      tx_data <= next_tx_data;             // Cambiar a los siguientes datos a transmitir
      tx_start <= next_tx_start;           // Cambiar a la siguiente señal de inicio de transmisión
      control_error_flag <= next_control_error_flag; // Cambiar al siguiente flag de error
    end
  end

  // Lógica combinacional para la transición de estados
  always @(*) begin
    // Inicializa los valores siguientes
    next_state = state;
    next_control = control;
    next_operator_A = operator_A;
    next_operator_B = operator_B;
    next_operation = operation;
    next_tx_data = tx_data;
    next_tx_start = 1'b0;                  // Inicialmente no se inicia la transmisión
    next_control_error_flag = control_error_flag; // Inicializa el flag de error

    case (state)
      st_idle: begin
        if (i_rx_end) begin
          // Verificar el control
          next_control = i_rx_array;         // Cargar el nuevo control desde el array de recepción
          case (i_rx_array)
            OP_RESULT: begin
              next_state = st_transmitting;   // Cambiar al estado de transmisión
            end
            OP_LOAD_A: begin
              next_state = st_receive;        // Cambiar al estado de recepción
            end
            OP_LOAD_B: begin
              next_state = st_receive;        // Cambiar al estado de recepción
            end
            OP_OPERATION: begin
              next_state = st_receive;        // Cambiar al estado de recepción
            end
            default: begin
              next_control_error_flag = 1'b1; // Marcar error de control
              next_state = st_transmitting;   // Cambiar al estado de transmisión
            end
          endcase
        end
      end

      st_receive: begin
        // Esperar a recibir un valor
        if (i_rx_end) begin
          // Cargar datos según el control
          case (control)
            OP_LOAD_A: begin
              next_operator_A = i_rx_array;   // Cargar el Operador A
            end
            OP_LOAD_B: begin
              next_operator_B = i_rx_array;   // Cargar el Operador B
            end
            OP_OPERATION: begin
              next_operation = i_rx_array[NB_ALU_OP-1:0]; // Cargar la operación de la ALU
            end
            default: begin
              // No hacer nada si el control no coincide
            end
          endcase

          next_state = st_idle;               // Volver al estado inactivo
        end
      end

      st_transmitting: begin
        // Enviar el resultado de la ALU
        if (control_error_flag) begin
          next_control_error_flag = 1'b0;    // Restablecer el flag de error
          next_tx_data = 8'b11111111;        // Enviar un código de error
        end else begin
          next_tx_data = i_result_alu;       // Enviar el resultado de la ALU
        end
        next_tx_start = 1'b1;                 // Iniciar la transmisión
        next_state = st_idle;                 // Volver al estado inactivo
      end

      default: next_state = st_idle;         // Regresar al estado inactivo por defecto
    endcase
  end

  // Asignaciones a las salidas del módulo
  assign o_tx_array = tx_data;             // Datos a transmitir
  assign o_operation = operation;           // Operación a realizar
  assign o_operator_A = operator_A;         // Operador A
  assign o_operator_B = operator_B;         // Operador B
  assign o_tx_start = tx_start;             // Señal de inicio de transmisión

endmodule
