`timescale 1ns / 1ps

module alu_uart_interface #
(
    parameter BUS_SIZE = 8
)
(
    input wire rx,                    // Entrada de datos serial
    output wire tx,                   // Salida de datos serial
    input wire i_clock,               
    input wire i_reset,               
    output wire full,                 // Indicador de FIFO lleno
    output wire carry,                // Indicador de acarreo
    output wire [BUS_SIZE - 1 : 0] result // Resultado de la ALU
);
    localparam [1:0]
        DATOA = 2'b01,                // primer dato
        DATOB = 2'b10,                // segundo dato
        OPCODE = 2'b11;               // código de operación
        
    reg [BUS_SIZE - 1 : 0] value_a;     // DATOA
    reg [BUS_SIZE - 1 : 0] value_b;     // DATOB
    reg [BUS_SIZE - 1 : 0] opcode;      // OPERACION
    wire [BUS_SIZE - 1 : 0] rx_data;    // Datos recibidos desde la UART
    reg [BUS_SIZE - 1 : 0] tx_data;     // Datos a enviar a la UART
    reg rd_signal;                      // Señal de lectura
    reg wr_signal;                      // Señal de escritura
    wire [BUS_SIZE - 1 : 0] alu_out;    // Salida de la ALU
    reg [BUS_SIZE - 1 : 0] o_result;    // Resultado a enviar
    wire o_carry;                        // Salida de acarreo  ALU
    wire rx_empty;                      // FIFO vacío
    reg [1:0] state_reg, state_next;    // Registro de estado y siguiente 
    
    initial
    begin
        value_a = 0;
        value_b = 0;
        opcode = 0;
        rd_signal = 0;
        wr_signal = 0;
    end
    
    // Estado de registro y transición de estado
    always @(posedge i_clock or posedge i_reset)
    begin
        if (i_reset)
            state_reg <= DATOA; // Reiniciar al estado DATOA
        else
            state_reg <= state_next; // Avanzar al siguiente estado
    end
      
    // Lógica para manejar estados y operaciones
    always @*
    begin
        rd_signal = 1'b0;  
        wr_signal = 1'b0;  
        
        if (~rx_empty) // Verificar si hay datos en el FIFO de RX
        begin    
            case (state_reg)
                DATOA:
                begin
                    rd_signal = 1'b1;        // Leer el primer operando
                    value_a = rx_data;      // Almacenar el primer operando
                    state_next = DATOB;     // Cambiar al siguiente estado
                end
                DATOB:
                begin
                    rd_signal = 1'b1;        // Leer el segundo operando
                    value_b = rx_data;      // Almacenar el segundo operando
                    state_next = OPCODE;    // Cambiar al siguiente estado
                end
                OPCODE:
                begin
                    rd_signal = 1'b1;        // Leer el código de operación
                    opcode = rx_data;       // Almacenar el código de operación
                    tx_data = alu_out;      // Preparar el resultado para la transmisión
                    o_result = alu_out;     // Almacenar el resultado
                    wr_signal = 1'b1;       // Habilitar escritura en el FIFO de TX
                    state_next = DATOA;     // Reiniciar el ciclo de lectura
                end
                default:
                    state_next = DATOA;     // Estado por defecto
            endcase
        end
        else
        begin
            rd_signal = 1'b0;  // No se lee si el FIFO está vacío
            wr_signal = 1'b0;  // No se escribe si no hay resultado
        end 
    end   
    
    // módulo UART
    uart #(
        .DBIT(BUS_SIZE)
    ) uart_instance (
        .clk(i_clock),
        .reset(i_reset),
        .r_data(rx_data),       // Datos recibidos desde la UART
        .w_data(tx_data),       // Datos a enviar a la UART
        .tx(tx),                // Salida de datos
        .rx(rx),                // Entrada de datos
        .rd_uart(rd_signal),    // Señal de lectura
        .wr_uart(wr_signal),    // Señal de escritura
        .rx_empty(rx_empty),    // FIFO vacío
        .tx_full(full)          // FIFO lleno
    );
       
    // módulo ALU
    alu #(
        .NB_DATA(BUS_SIZE),
        .NB_OP(6) 
    ) alu_instance (
        .i_data_a(value_a),     // Primer operando
        .i_data_b(value_b),     // Segundo operando
        .i_op(opcode),          // Código de operación
        .o_data(alu_out)        // Salida de la ALU
    );
        
    assign result = o_result; 
    assign carry = o_carry;   

endmodule
