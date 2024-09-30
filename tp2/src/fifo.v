`timescale 1ns / 1ps

module fifo
   #(
    parameter B=8, // número de bits en una palabra
              W=4  // número de bits de dirección, define el tamaño del FIFO (2^W palabras)
   )
   (
    input wire clk, reset,
    input wire rd, wr,
    input wire [B-1:0] write_data,  // Datos de entrada a escribir en el FIFO.
    output wire empty, full,         // Indica si el FIFO está vacío y lleno.
    output wire [B-1:0] read_data  
   );

   localparam NO_OP = 2'b00;
   localparam READ = 2'b01;
   localparam WRITE = 2'b10;
   localparam READ_WRITE = 2'b11;

   reg [B-1:0] array_reg [2**W-1:0];  // registros que almacena los datos del FIFO
   reg [W-1:0] w_ptr_reg, w_ptr_next, w_ptr_succ;   // Puntero de escritura actual, siguiente ciclo y de la posición siguiente
   reg [W-1:0] r_ptr_reg, r_ptr_next, r_ptr_succ;   // Puntero de lectura actual, siguiente ciclo y de la posición siguiente
   reg full_reg, empty_reg, full_next, empty_next;  // Estados actuales de si el FIFO está lleno o vacío
   wire wr_en;                       // Señal de habilitación de escritura

   always @(posedge clk) begin
      if (wr_en)
         array_reg[w_ptr_reg] <= write_data;
   end

   assign read_data = array_reg[r_ptr_reg];
   assign wr_en = wr & ~full_reg;

   always @(posedge clk) begin
      if (reset) begin
         w_ptr_reg <= 0;
         r_ptr_reg <= 0;
         full_reg <= 1'b0;
         empty_reg <= 1'b1;
      end else begin
         w_ptr_reg <= w_ptr_next;
         r_ptr_reg <= r_ptr_next;
         full_reg <= full_next;
         empty_reg <= empty_next;
      end
   end

   // next-state logic for read and write pointers
   always @* begin
      // successive pointer values
      w_ptr_succ = w_ptr_reg + 1;
      r_ptr_succ = r_ptr_reg + 1;
      // default: keep old values
      w_ptr_next = w_ptr_reg;
      r_ptr_next = r_ptr_reg;
      full_next = full_reg;
      empty_next = empty_reg;

      case ({wr, rd})
         NO_OP: ; 
         READ: begin
            if (~empty_reg) begin // not empty
               r_ptr_next = r_ptr_succ;
               full_next = 1'b0;
               if (r_ptr_succ == w_ptr_reg)
                  empty_next = 1'b1;
            end
         end
         WRITE: begin
            if (~full_reg) begin // not full
               w_ptr_next = w_ptr_succ;
               empty_next = 1'b0;
               if (w_ptr_succ == r_ptr_reg)
                  full_next = 1'b1;
            end
         end
         READ_WRITE: begin
            w_ptr_next = w_ptr_succ;
            r_ptr_next = r_ptr_succ;
         end
      endcase
   end

   // output
   assign full = full_reg;
   assign empty = empty_reg;

endmodule
