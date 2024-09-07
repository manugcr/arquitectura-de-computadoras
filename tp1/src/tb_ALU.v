`timescale 1ns/1ps

module tb_ALU;

// Parameters must match ALU parameters.
parameter NB_DATA = 8;
parameter NB_OP = 6;

// Test signals
reg signed [NB_DATA-1:0] i_data_a;
reg signed [NB_DATA-1:0] i_data_b;
reg [NB_OP-1:0] i_op;
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

// Testbench logic
initial begin
    // Dump VCD file for gtkwave
    $dumpfile("alu_dump.vcd");
    $dumpvars(0, tb_ALU);

    seed = $time;
    
    // Display the header for results
    $display("Time\t A\t B\t OP\t Result");

    // Start simulation
    #10

    // Test 1 ADD
    i_data_a = $random(seed) % 256;
    i_data_b = $random(seed) % 256;
    i_op = 6'b100000;
    #10;
    $display("%0t\t %d\t %d\t ADD\t %d", $time, i_data_a, i_data_b, o_data);

    // Test 2 SUB
    i_data_a = $random(seed) % 256;
    i_data_b = $random(seed) % 256;
    i_op = 6'b100010;
    #10;
    $display("%0t\t %d\t %d\t SUB\t %d", $time, i_data_a, i_data_b, o_data);

    // Test 3 AND
    i_data_a = $random(seed) % 256;
    i_data_b = $random(seed) % 256;
    i_op = 6'b100100;
    #10;
    $display("%0t\t %d\t %d\t AND\t %d", $time, i_data_a, i_data_b, o_data);

    // Test 4 OR
    i_data_a = $random(seed) % 256;
    i_data_b = $random(seed) % 256;
    i_op = 6'b100101;
    #10;
    $display("%0t\t %d\t %d\t OR\t %d", $time, i_data_a, i_data_b, o_data);

    // Test 5 XOR
    i_data_a = $random(seed) % 256;
    i_data_b = $random(seed) % 256;
    i_op = 6'b100110;
    #10;
    $display("%0t\t %d\t %d\t XOR\t %d", $time, i_data_a, i_data_b, o_data);

    // Test 6 SRA
    i_data_a = $random(seed) % 256;
    i_op = 6'b000011;
    #10;
    $display("%0t\t %d\t %d\t SRA\t %d", $time, i_data_a, i_data_b, o_data);

    // Test 7 SRL
    i_data_a = $random(seed) % 256;
    i_op = 6'b000010;
    #10;
    $display("%0t\t %d\t %d\t SRL\t %d", $time, i_data_a, i_data_b, o_data);

    // Test 8 NOR
    i_data_a = $random(seed) % 256;
    i_data_b = $random(seed) % 256;
    i_op = 6'b100111;
    #10;
    $display("%0t\t %d\t %d\t NOR\t %d", $time, i_data_a, i_data_b, o_data);

    $finish;
end

endmodule
