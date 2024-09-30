#!/bin/bash

# Check if the correct number of arguments was provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <design_file_name> <testbench_file_name>"
    echo "Example: $0 baudrate_gen tb_baudrate_gen"
    exit 1
fi

# Change to the src/tests directory
cd ./src/tests || { echo "Directory ./src/tests not found!"; exit 1; }

# Assign parameters to variables
design_name=$1
testbench_name=$2

# Construct design and testbench file paths
design_file="../${design_name}.v"
testbench_file="${testbench_name}.v"

# Check if design file exists
if [ ! -f "$design_file" ]; then
    echo "Error: Design file '$design_file' not found."
    exit 1
fi

# Check if testbench file exists
if [ ! -f "$testbench_file" ]; then
    echo "Error: Testbench file '$testbench_file' not found."
    exit 1
fi

# Remove old files if they exist
echo "  ->  Removing old files if they exist..."
[ -f sim ] && rm sim
[ -f dump.vcd ] && rm dump.vcd

# Compile and run the testbench
echo "  ->  Compiling and running $design_file with $testbench_file..."
iverilog -o sim "$design_file" "$testbench_file" || { echo "Compilation failed!"; exit 1; }

echo "  ->  Running simulation..."
vvp sim || { echo "Simulation failed!"; exit 1; }

# Generate waveform
echo "  ->  Generating waveform..."
gtkwave dump.vcd || { echo "Failed to open gtkwave!"; exit 1; }

echo "Simulation and waveform generation complete!"
