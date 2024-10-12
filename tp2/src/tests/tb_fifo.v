module tb_fifo;

    // Parameters
    localparam B = 8;  // Data width
    localparam W = 4;  // Address width

    // Testbench signals
    reg clk;
    reg reset;
    reg rd;
    reg wr;
    reg [B-1:0] write_data;
    wire empty;
    wire full;
    wire [B-1:0] read_data;

    // Instantiate the FIFO module
    fifo #(B, W) uut (
        .clk(clk),
        .reset(reset),
        .rd(rd),
        .wr(wr),
        .write_data(write_data),
        .empty(empty),
        .full(full),
        .read_data(read_data)
    );

    // Clock generation
    always #10 clk = ~clk;  // 50MHz clock

    initial begin
        // Initialize signals
        clk = 0;
        reset = 1;
        rd = 0;
        wr = 0;
        write_data = 0;

        // Release reset
        #50 reset = 0;  // Release reset after 50ns

        // Write operations
        wr = 1; write_data = 8'hA1;  // Write A1
        #20 wr = 0;  // Deassert write
        #40 wr = 1; write_data = 8'hB2;  // Write B2
        #20 wr = 0;  // Deassert write
        #40 wr = 1; write_data = 8'hC3;  // Write C3
        #20 wr = 0;  // Deassert write

        // Read operations
        rd = 1;  // Start reading
        #20;  // Read the first value
        $display("[%0t] Read Data: %h", $time, read_data);
        #20;  // Read the second value
        $display("[%0t] Read Data: %h", $time, read_data);
        #20;  // Read the third value
        $display("[%0t] Read Data: %h", $time, read_data);
        rd = 0;  // Deassert read

        // Wait and finish
        #100 $finish;
    end

    // VCD dump for GTKWave
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_fifo);
    end

endmodule
