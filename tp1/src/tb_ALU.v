`timescale 1ns/1ps

module tb_ALU;

// Parameters must match ALU parameters.
parameter NB_DATA = 8;
parameter NB_OP = 6;

// Test signals
reg [NB_DATA-1:0] i_data_a;                               // 8-bit unsigned input A
reg [NB_DATA-1:0] i_data_b;                               // 8-bit unsigned input B
reg [NB_OP-1:0] i_op;                                     // 6-bit operation code
wire [NB_DATA-1:0] o_data;                                // 8-bit unsigned output
wire carry_borrow;                                        // Carry/Borrow flag

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
    .o_data(o_data),
    .carry_borrow(carry_borrow)
);

// Testbench logic
initial begin
    // Dump VCD file for gtkwave
    $dumpfile("alu_dump.vcd");
    $dumpvars(0, tb_ALU);

    seed = $time;
    
    // Display the header for results
    $display("Time\t A\t B\t OP\t Result\t Carry");

    // Start simulation
    #10

    // Test 1 ADD (Expect carry)
    i_data_a = 8'b11111111;  // 255
    i_data_b = 8'b00000001;  // 1
    i_op = 6'b100000;        // ADD operation
    #10;
    $display("%0t\t %d\t %d\t ADD\t %d\t %b", $time, i_data_a, i_data_b, o_data, carry_borrow);

    // Test 2 SUB (Expect borrow)
    i_data_a = 8'b00000011;  // 3
    i_data_b = 8'b00000101;  // 5
    i_op = 6'b100010;        // SUB operation
    #10;
    $display("%0t\t %d\t %d\t SUB\t %d\t %b", $time, i_data_a, i_data_b, o_data, carry_borrow);

    // Test 3 AND
    i_data_a = $random(seed) % 256;
    i_data_b = $random(seed) % 256;
    i_op = 6'b100100;        // AND operation
    #10;
    $display("%0t\t %d\t %d\t AND\t %d\t %b", $time, i_data_a, i_data_b, o_data, carry_borrow);

    // Test 4 OR
    i_data_a = $random(seed) % 256;
    i_data_b = $random(seed) % 256;
    i_op = 6'b100101;        // OR operation
    #10;
    $display("%0t\t %d\t %d\t OR\t %d\t %b", $time, i_data_a, i_data_b, o_data, carry_borrow);

    // Test 5 XOR
    i_data_a = $random(seed) % 256;
    i_data_b = $random(seed) % 256;
    i_op = 6'b100110;        // XOR operation
    #10;
    $display("%0t\t %d\t %d\t XOR\t %d\t %b", $time, i_data_a, i_data_b, o_data, carry_borrow);

    // Test 6 SRA
    i_data_a = $random(seed) % 256;
    i_op = 6'b000011;        // SRA operation
    #10;
    $display("%0t\t %d\t %d\t SRA\t %d\t %b", $time, i_data_a, i_data_b, o_data, carry_borrow);

    // Test 7 SRL
    i_data_a = $random(seed) % 256;
    i_op = 6'b000010;        // SRL operation
    #10;
    $display("%0t\t %d\t %d\t SRL\t %d\t %b", $time, i_data_a, i_data_b, o_data, carry_borrow);

    // Test 8 NOR
    i_data_a = $random(seed) % 256;
    i_data_b = $random(seed) % 256;
    i_op = 6'b100111;        // NOR operation
    #10;
    $display("%0t\t %d\t %d\t NOR\t %d\t %b", $time, i_data_a, i_data_b, o_data, carry_borrow);

    $finish;
end

endmodule
