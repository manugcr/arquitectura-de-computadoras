#!/bin/bash
# sim.sh script to compile and run Verilog simulation with Icarus Verilog and GTKWave

design_name=$1
testbench_name=tb_$1

echo "  ->  Removing old files if they exist..."
rm -f ./dump.vcd
rm -f ./out

echo "  ->  Compiling and running ../$design_name.v with $testbench_name.v..."

iverilog -o out ./src/$design_name.v ./src/alu.v ./src/uart.v ./src/transmitter.v ./src/fifo.v ./src/baud_rate.v ./src/receiver.v ./src/tests/$testbench_name.v
if [ $? -eq 0 ]; then
    vvp out
    echo "  ->  Simulation complete, launching GTKWave..."
    gtkwave dump.vcd &
else
    echo "  ->  Compilation failed."
fi
