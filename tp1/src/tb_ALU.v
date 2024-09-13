`timescale 1ns/1ps

module tb_ALU;

    // ALU parameters
    parameter NB_DATA   = 8;
    parameter NB_OP     = 6;

    reg [NB_OP-1:0] i_op;
    reg signed [NB_DATA-1:0] i_data_a;
    reg signed [NB_DATA-1:0] i_data_b;
    wire signed [NB_DATA-1:0] o_data;

    // Seed for random generation
    integer seed;

    // Instantiate the ALU module
    ALU #(
        .NB_DATA(NB_DATA),
        .NB_OP(NB_OP)
    ) uut (
        .i_data_a(i_data_a),
        .i_data_b(i_data_b),
        .i_op(i_op),
        .o_data(o_data)
    );

    // Task to perform an ALU operation and display results
    task perform_test;
        input [NB_OP-1:0] op;
        input [NB_DATA-1:0] data_a;
        input [NB_DATA-1:0] data_b;
        begin
            i_data_a    = data_a;
            i_data_b    = data_b;
            i_op        = op;
            #10;
            $display("%0t\t %b\t %b\t %b\t %b", $time, i_data_a, i_data_b, i_op, o_data);
        end
    endtask

    initial begin
        // Dump VCD file for gtkwave
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_ALU);

        seed = $random;

        // Start simulation
        $display("Time\t A\t\t B\t\t OP\t Res");
        #10;

        // Test cases
        perform_test(6'b100000, $random(seed), $random(seed));
        perform_test(6'b100010, $random(seed), $random(seed));
        perform_test(6'b100100, $random(seed), $random(seed));
        perform_test(6'b100101, $random(seed), $random(seed));
        perform_test(6'b100110, $random(seed), $random(seed));
        perform_test(6'b000011, $random(seed), 0);
        perform_test(6'b000010, $random(seed), 0);
        perform_test(6'b100111, $random(seed), $random(seed));

        $finish;
    end

endmodule
