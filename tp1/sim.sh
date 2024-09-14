#!/bin/bash

cd ./src || { echo "Directory ./src not found!"; exit 1; }

echo "  ->  Removing old files if they exist..."
[ -f sim ] && rm sim
[ -f dump.vcd ] && rm dump.vcd

echo "  ->  Compiling and running ALU testbench..."
iverilog -o sim alu.v tb_alu.v || { echo "Compilation failed!"; exit 1; }

echo "  ->  Running simulation..."
vvp sim || { echo "Simulation failed!"; exit 1; }

echo "  ->  Generating waveform..."
gtkwave dump.vcd || { echo "Failed to open gtkwave!"; exit 1; }
