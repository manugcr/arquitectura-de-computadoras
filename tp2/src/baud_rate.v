`timescale 1ns / 1ps

module baud_rate #(
    parameter N=8, // Número de bits en el contador
              M=163 // Valor máximo que el contador alcanzará antes de reiniciarse
   )
   (
    input wire clk,   
    input wire reset,  
    output wire tick, // Salida que indica cuando se ha generado un tick
    output wire [N-1:0] q // Salida que representa el valor actual del contador
   );

   reg [N-1:0] r_reg; // Registro que almacena el valor actual del contador
   wire [N-1:0] r_next; // Señal que representa el siguiente estado del contador

   // Lógica del registro
   always @(posedge clk) // Se activa en el flanco ascendente del reloj
      if (reset) // Si la señal de reinicio está activa
         r_reg <= 0; // Reiniciar el registro a 0
      else
         r_reg <= r_next; // De lo contrario, actualizar el registro al siguiente estado

   // Lógica para determinar el siguiente estado del contador
   assign r_next = (r_reg == (M-1)) ? 0 : r_reg + 1; // Si se alcanza M-1, reiniciar; de lo contrario, incrementar
   assign tick = (r_reg == (M-1)) ? 1'b1 : 1'b0; // Activar tick si se alcanza M-1, de lo contrario, desactivarlo

   assign q = r_reg; // Salida del contador
endmodule
