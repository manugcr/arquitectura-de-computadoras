`timescale 1ns / 1ps

module tb_alu_uart_interface;
    // Testbench signals
    reg tb_rx;
    reg tb_clock;
    reg tb_reset;
    wire tb_tx;
    wire tb_full;
    wire tb_carry;
    wire [7:0] tb_result;

    // Clock generation (50MHz)
    initial tb_clock = 0;
    always #10 tb_clock = ~tb_clock; // 20ns period -> 50MHz

    // Instantiate the module under test
    alu_uart_interface #(
        .BUS_SIZE(8)
    ) dut (
        .rx(tb_rx),
        .tx(tb_tx),
        .i_clock(tb_clock),
        .i_reset(tb_reset),
        .full(tb_full),
        .carry(tb_carry),
        .result(tb_result)
    );

    // Test logic
    initial begin
        // Initialize
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_alu_uart_interface);
        
        tb_rx = 1'b1;  // Idle state for UART (high)
        tb_reset = 1'b1;  // Assert reset

        // Hold reset for a few cycles
        #100;
        tb_reset = 1'b0;  // Deassert reset

        // Send first operand (DATOA) through UART
        send_uart_byte(8'h0A);  // Example value for A

        // Send second operand (DATOB) through UART
        send_uart_byte(8'h05);  // Example value for B

        // Send opcode (e.g., 8'h01 for ADD operation)
        send_uart_byte(8'h01);  // Opcode for ADD

        // Wait some time for ALU operation to complete
        #1000;

        // Check result and carry flag
        $display("ALU Result: %h, Carry: %b", tb_result, tb_carry);

        // Finish simulation
        #5000;
        $finish;
    end

    // UART transmission task (simplified)
    task send_uart_byte;
        input [7:0] byte;
        integer i;
        begin
            // Start bit
            tb_rx = 1'b0;
            #8680;  // 1 baud period (assuming 115200 baud rate)

            // Send 8 data bits (LSB first)
            for (i = 0; i < 8; i = i + 1) begin
                tb_rx = byte[i];
                #8680;
            end

            // Stop bit
            tb_rx = 1'b1;
            #8680;
        end
    endtask

endmodule
