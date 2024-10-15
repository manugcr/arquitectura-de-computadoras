module baud_rate (
    input  wire i_clk,
    input  wire i_reset,
    output wire o_tick,
    output wire [7:0] o_counter  // Agregamos una salida para el contador
);

  localparam NCYCLES_PER_TICK = 163;  // Valor constante
  localparam NB_COUNTER = 8;           // Asignado directamente

  reg [NB_COUNTER-1:0] counter;

  always @(posedge i_clk) begin
    if (i_reset) begin
      counter <= 0;
    end else if (counter == NCYCLES_PER_TICK - 1) begin
      // volver a empezar
      counter <= 0;
    end else begin
      counter <= counter + 1;
    end
  end

  // se genera un tick de un ciclo de reloj cada NCYCLES_PER_TICK ciclos
  assign o_tick = (counter == NCYCLES_PER_TICK - 1);
  assign o_counter = counter;  // Asignar el valor del contador a la salida

endmodule
