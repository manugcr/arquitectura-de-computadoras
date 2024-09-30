`timescale 1ns / 1ps

module transmitter
   #(
     parameter DBIT = 8,        // # data bits
               TICKS_END = 16   // # ticks for stop bits
   )
   (
    input wire clk, reset,
    input wire tx_go, pulse_tick,
    input wire [7:0] din,
    output reg tx_done_tick,
    output wire tx
   );

   // symbolic state declaration
   localparam [1:0]
      waiting  = 2'b00,
      start = 2'b01,
      data  = 2'b10,
      stop  = 2'b11;

   // signal declaration
   reg [1:0] state_reg, state_next;
   reg [3:0] tick_counter, tick_counter_next;
   reg [2:0] bit_counter, bit_counter_next;
   reg [7:0] data_shift_reg, data_shift_reg_next;
   reg tx_signal, tx_next;

   // body
   // FSMD state & data registers
   

   always @(posedge clk)
      if (reset)
         begin
            state_reg <= waiting;
            tick_counter <= 0;
            bit_counter <= 0;
            data_shift_reg <= 0;
            tx_signal <= 1'b1;
         end
      else
         begin
            state_reg <= state_next;
            tick_counter <= tick_counter_next;
            bit_counter <= bit_counter_next;
            data_shift_reg <= data_shift_reg_next;
            tx_signal <= tx_next;
         end

   // FSMD next-state logic & functional units: ejecuta cada vez que cualquiera de las señales dentro de él cambian
   always @*
   begin
      state_next = state_reg;
      tx_done_tick = 1'b0;
      tick_counter_next = tick_counter;
      bit_counter_next = bit_counter;
      data_shift_reg_next = data_shift_reg;
      tx_next = tx_signal ;
      case (state_reg)
      /* El sistema pasará del estado "stop" al estado "waiting" cuando:
         después de 16 ticks en total
         Y pulse_tick esté activo para avanzar el contador de ticks.
        Justo antes de cambiar al estado "waiting", el sistema activa tx_done_tick para 
         señalar que la transmisión ha finalizado.
      */
         waiting:
            begin
               tx_next = 1'b1;
               if (tx_go)
                  begin
                     state_next = start;
                     tick_counter_next = 0;
                     data_shift_reg_next = din;
                  end
            end
         start:
            begin
               tx_next = 1'b0;
               if (pulse_tick)
                  if (tick_counter==(TICKS_END-1))
                     begin
                        state_next = data;
                        tick_counter_next = 0;
                        bit_counter_next = 0;
                     end
                  else
                     tick_counter_next = tick_counter + 1;
            end
             /*  DATA:   Se transmitirán 8 bits de datos.
                    TICKS_END = 16: Cada bit de datos requerirá 16 ticks.
                    Total de ticks = 8×16  =  128  ticks        */
         data:
            begin
               tx_next = data_shift_reg[0];
               if (pulse_tick)
                  if (tick_counter==(TICKS_END-1))
                     begin
                        tick_counter_next = 0;
                        data_shift_reg_next = data_shift_reg >> 1;
                        if (bit_counter==(DBIT-1))
                           state_next = stop ;
                        else
                           bit_counter_next = bit_counter + 1;
                     end
                  else
                     tick_counter_next = tick_counter + 1;
            end
         /*  
            El transmisor pasará del estado "data" al estado "stop" cuando:
            Se hayan transmitido todos los bits de datos (cuando bit_counter == DBIT - 1).
            Y el contador de ticks haya llegado al final para el último bit (tick_counter == TICKS_END - 1).*/      
         stop:
            begin
               tx_next = 1'b1;
               if (pulse_tick)
                     begin
                        state_next = waiting;
                        tx_done_tick = 1'b1;
                     end
                  else
                     tick_counter_next = tick_counter + 1;
            end
      endcase
   end
   // output
   assign tx = tx_signal;

endmodule


