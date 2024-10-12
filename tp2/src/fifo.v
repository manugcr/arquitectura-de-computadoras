`timescale 1ns / 1ps

module fifo
#(
    parameter B = 8,                                   	// Number of bits in a word
    parameter W = 4                                    	// Number of address bits, defines FIFO size (2^W words)
)
(
    input wire clk, 
    input wire reset,
    input wire rd, 
    input wire wr,
    input wire [B-1:0] write_data,                    	// Input data to write into the FIFO
    output wire empty, 
    output wire full,                                  	// Indicates if the FIFO is empty and full
    output wire [B-1:0] read_data  
);

    localparam NO_OP = 2'b00;
    localparam READ = 2'b01;
    localparam WRITE = 2'b10;
    localparam READ_WRITE = 2'b11;

    reg [B-1:0] array_reg [0:(2**W)-1];					// Registers that store the data in the FIFO
    reg [W-1:0] w_ptr_reg, w_ptr_next, w_ptr_succ;  	// Current write pointer, next cycle pointer, and next position
    reg [W-1:0] r_ptr_reg, r_ptr_next, r_ptr_succ;  	// Current read pointer, next cycle pointer, and next position
    reg full_reg, empty_reg, full_next, empty_next;  	// Current states of whether the FIFO is full or empty
    wire wr_en;                                       	// Write enable signal

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

    // Next-state logic for read and write pointers
    always @* begin
        // Successive pointer values
        w_ptr_succ = w_ptr_reg + 1;
        r_ptr_succ = r_ptr_reg + 1;
        
        // Default: keep old values
        w_ptr_next = w_ptr_reg;
        r_ptr_next = r_ptr_reg;
        full_next = full_reg;
        empty_next = empty_reg;

        case ({wr, rd})
            NO_OP: ; 
            
            READ: begin
                if (~empty_reg) begin // Not empty
                    r_ptr_next = r_ptr_succ;
                    full_next = 1'b0;
                    if (r_ptr_succ == w_ptr_reg)
                        empty_next = 1'b1;
                end
            end
            
            WRITE: begin
                if (~full_reg) begin // Not full
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

    assign full = full_reg;
    assign empty = empty_reg;

endmodule
