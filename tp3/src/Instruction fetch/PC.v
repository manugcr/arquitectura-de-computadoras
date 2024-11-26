`timescale 1ns / 1ps

// Módulo PC (Program Counter) que gestiona el valor actual del contador de programa
// y sus transiciones entre diferentes estados. Permite realizar operaciones de reinicio, 
// detención, carga condicional de un nuevo valor y limpieza del PC.

module pc
    #(
        // Parámetros configurables del módulo
        parameter PC_WIDTH = 32,                // Ancho del contador de programa en bits
        parameter STATES_WIDTH = $clog2(3),    // Ancho en bits para representar los estados (3)
        
        // Definición de los estados del PC
        parameter PC_IDLE = 2'b00,              // Estado inactivo, PC en espera
        parameter PC_NEXT = 2'b01,              // Estado de transición al siguiente valor del PC
        parameter PC_END = 2'b10                // Estado de fin de ejecución
    )
    (
        // Entradas
        input wire i_clk,                       // Reloj del sistema
        input wire i_reset,                    // Señal para reiniciar el PC
        input wire i_halt,                     // Señal para detener el PC
        input wire i_not_load,                 // Señal que indica no cargar un nuevo valor al PC
        input wire i_enable,                   // Señal para habilitar la transición de estados
        input wire i_flush,                    // Señal de limpieza
        input wire i_clear,                    // Señal para borrar el PC
        input wire [PC_WIDTH - 1 : 0] i_next_pc, // Valor del próximo contador de programa a cargar

        // Salida
        output wire [PC_WIDTH - 1 : 0] o_pc     // Valor actual del contador de programa
    );

    // Registros internos para manejar el estado actual y siguiente del PC
    reg [STATES_WIDTH - 1 : 0] state, state_next; // Estado actual y estado siguiente del PC
    reg [PC_WIDTH - 1 : 0] pc, pc_next;          // Valor actual y siguiente del PC

    // Bloque secuencial para actualizar el estado y el valor del PC en el flanco negativo del reloj
    always @ (negedge i_clk) 
    begin
        // Si se activa la señal de reinicio, limpieza o borrado, el PC y el estado se reinician
        if (i_reset || i_flush || i_clear) 
        begin
            state <= PC_IDLE;   // Cambia al estado inactivo
            pc <= 32'b0;        // Reinicia el valor del PC a cero
        end
        else 
        begin
            // Si no hay reinicio, limpieza o borrado, actualiza los valores al siguiente estado
            state <= state_next;
            pc <= pc_next;
        end
    end

    // Bloque combinacional para determinar el siguiente estado y valor del PC
    always @ (*) 
    begin
        // Inicializa los valores siguientes con los valores actuales
        state_next = state;
        pc_next = pc;

        // Lógica de transición de estados
        case (state)
            PC_IDLE: 
            begin
                // Estado inactivo: el PC se reinicia a cero y se transita al estado de carga
                pc_next = 32'b0;
                state_next = PC_NEXT;
            end

            PC_NEXT: 
            begin
                // Estado de carga: realiza transiciones basadas en las señales de entrada
                if (i_enable) // Transición solo si está habilitado
                begin
                    if (i_halt) 
                    begin
                        // Si la señal de detención está activa, pasa al estado final
                        state_next = PC_END;
                    end
                    else 
                    begin
                        if (~i_not_load) 
                        begin
                            // Si no se bloquea la carga, actualiza el PC con el nuevo valor
                            pc_next = i_next_pc;
                            state_next = PC_NEXT; // Permanece en el estado de carga
                        end
                    end
                end
            end

            PC_END: 
            begin
                // Estado de fin: regresa al estado inactivo si se desactiva la señal de detención
                if (~i_halt) 
                begin
                    state_next = PC_IDLE;
                end
            end

        endcase
    end

    // Asigna el valor actual del PC a la salida
    assign o_pc = pc;

endmodule
