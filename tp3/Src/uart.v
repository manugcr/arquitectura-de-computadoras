module uart 
 #(
    parameter NB_DATA = 32,  // Número de bits de datos
    parameter NB_STOP = 16,  // Número de bits de parada
    parameter  BAUD_RATE       = 19200, // Tasa de baudios
    parameter  CLK_FREQ        = 45_000_000, //! Frecuencia del reloj
    parameter  OVERSAMPLING    = 16 //! Factor de sobremuestreo
)(
    input   wire clk,           // Señal de reloj
    input   wire i_rst_n,       // Señal de reset activo en bajo
    input   wire i_rx,          // Entrada de datos serie (recepción)
    input [7:0]  data_Interface2Tx, // Datos de interfaz para transmisión
    input        tx_start,      // Señal de inicio de transmisión
    output  wire o_tx,          // Salida de datos serie (transmisión)
    output  wire o_txDone,      // Indicador de finalización de transmisión
    output  wire o_rxdone,      // Indicador de finalización de recepción
    output [7:0] data_Rx2Interface // Datos recibidos para la interfaz
);
 
// Instancia del generador de baudios
baudrate_generator #(
        .BAUD_RATE      (BAUD_RATE),  // Tasa de baudios configurada
        .CLK_FREQ       (CLK_FREQ),   // Frecuencia del reloj
        .OVERSAMPLING   (OVERSAMPLING) // Factor de sobremuestreo
    ) baudrate_generator_inst (
        .clk    (clk),      // Conexión de la señal de reloj
        .i_rst_n  (i_rst_n), // Señal de reset
        .o_tick (tick)      // Señal de tick para sincronización
    );

// Instancia del módulo receptor UART
uart_rx #(
        .NB_DATA    (NB_DATA), // Número de bits de datos
        .NB_STOP    (NB_STOP)  // Número de bits de parada
    ) uart_rx_inst (
        .clk        (clk),        // Reloj
        .i_rst_n    (i_rst_n),    // Reset activo en bajo
        .i_tick     (tick),       // Señal de sincronización
        .i_data     (i_rx),       // Datos de entrada serial
        .o_data     (data_Rx2Interface), // Salida de datos recibidos
        .o_rxdone   (o_rxdone)    // Señal de dato recibido correctamente
    );

// Instancia del módulo transmisor UART
uart_tx #(
        .NB_DATA    (NB_DATA), // Número de bits de datos
        .NB_STOP    (NB_STOP)  // Número de bits de parada
    ) uart_tx_inst (
        .clk        (clk),        // Reloj
        .i_rst_n    (i_rst_n),    // Reset activo en bajo
        .i_tick     (tick),       // Señal de sincronización
        .i_start_tx (tx_start),   // Señal para iniciar la transmisión
        .i_data     (data_Interface2Tx), // Datos de entrada para transmitir
        .o_txdone   (o_txDone),   // Señal que indica que la transmisión finalizó
        .o_data     (o_tx)        // Salida de datos serial transmitidos
    );
    
endmodule