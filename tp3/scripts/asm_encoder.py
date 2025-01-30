import os

# Register mapping as per the given table
REGISTER_MAP = {
    "$zero": 0, "$v0": 2, "$v1": 3, "$a0": 4, "$a1": 5, "$a2": 6, "$a3": 7,
    "$t0": 8, "$t1": 9, "$t2": 10, "$t3": 11, "$t4": 12, "$t5": 13, "$t6": 14, "$t7": 15,
    "$s0": 16, "$s1": 17, "$s2": 18, "$s3": 19, "$s4": 20, "$s5": 21, "$s6": 22, "$s7": 23,
    "$t8": 24, "$t9": 25, "$gp": 28, "$sp": 29, "$fp": 30, "$ra": 31
}

# Define function codes for R-type instructions
R_TYPE_FUNCTIONS = {
    "add": "100000", "addu": "100001", "and": "100100", "jr": "001000",
    "madd": "000000", "mfhi": "010000", "mflo": "010010", "movn": "001011",
    "movz": "001010", "msub": "000100", "mthi": "010001", "mtlo": "010011",
    "mul": "000010", "mult": "011000", "multu": "011001", "nor": "100111",
    "or": "100101", "sll": "000000", "slt": "101010", "sltu": "101011",
    "sra": "000011", "srl": "000010", "sub": "100010", "xor": "100110"
}

# Define opcodes for I-type instructions
I_TYPE_OPCODES = {
    "lw": "100011", "sw": "101011", "addi": "001000", "addiu": "001001",
    "ori": "001101", "xori": "001110", "lui": "001111", "lb": "100000",
    "lh": "100001", "andi": "001100", "slti": "001010", "sltiu": "001011"
}

# Function to encode R-type instructions
def encode_r_type(op, rs, rt, rd, shamt=0):
    binary = f"000000{rs:05b}{rt:05b}{rd:05b}{shamt:05b}{R_TYPE_FUNCTIONS[op]}"
    return format_encoding(binary)

# Function to encode I-type instructions
def encode_i_type(op, rs, rt, offset):
    binary = f"{I_TYPE_OPCODES[op]}{rs:05b}{rt:05b}{offset & 0xFFFF:016b}"
    return format_encoding(binary)

# Function to format binary encoding into hex and decimal
def format_encoding(binary):
    hex_encoding = format(int(binary, 2), 'x')
    decimal_encoding = int(binary, 2)
    return binary, hex_encoding, decimal_encoding


def get_instruction_type(op):
    if op in R_TYPE_FUNCTIONS:
        return "R"
    elif op in I_TYPE_OPCODES:
        return "I"
    return "Unknown"

def parse_operands(op, operands):

    if op in R_TYPE_FUNCTIONS:
        # Example: $s1, $s2, $s3
        # Split the operands by comma and map the registers to their respective values
        # [$s1, $s2, $s3] -> [17, 18, 19]
        rd, rs, rt = map(lambda reg: REGISTER_MAP[reg.strip()], operands.split(','))
        return rd, rs, rt
    elif op in I_TYPE_OPCODES:
        # Example: $t0, 4($s0)
        # Split the operands by comma, then split the second part by the opening parenthesis
        # Then map the registers to their respective values
        # [$t0, 4, $s0] -> [8, 4, 16]
        rs, rt_offset = operands.split(',', 1)
        offset, rt = rt_offset.strip('()').split('(', 1)
        offset = int(offset)
        rt, rs = map(lambda reg: REGISTER_MAP[reg.strip()], [rs, rt])
        return rs, rt, offset

def process_instruction(instruction, file):
    # First we split the operation and operands
    # Example: add $s1, $s2, $s3 -> ['add', '$s1, $s2, $s3']
    # Then we get the instruction type (R, I, J) so we can handle the operands accordingly.
    op, operands = instruction.split(' ', 1)
    instr_type = get_instruction_type(op)
    
    # Once we have the instruction type, we can parse the operands accordingly
    # We then encode the instruction and output the result
    try:
        if instr_type == "R":
            rd, rs, rt = parse_operands(op, operands)
            binary_instruction, hex_instruction, decimal_instruction = encode_r_type(op, rs, rt, rd)
        elif instr_type == "I":
            rs, rt, offset = parse_operands(op, operands)
            binary_instruction, hex_instruction, decimal_instruction = encode_i_type(op, rs, rt, offset)
        else:
            print("Unsupported instruction type or unknown operation.")
            return
    except KeyError:
        print("Invalid register name. Make sure the registers are correctly typed.")
        return
    except ValueError:
        print("Invalid input. Ensure all operands are integers where required.")
        return

    # Output the result
    print(f"\n{'Instruction:':<18}{instruction}")
    print("-" * 50)
    print(f"{'Bin encoding:':<18}{binary_instruction}")
    print(f"{'Hex encoding:':<18}{hex_instruction}")
    print(f"{'Dec encoding:':<18}{decimal_instruction}")

    # Write the hex encoding to the file
    file.write(hex_instruction + '\n')

def main():
    # Get the absolute path of the directory where the script is located
    script_dir = os.path.dirname(os.path.abspath(__file__))
    
    # Construct the path to code.txt in the same directory as the script
    code_file_path = os.path.join(script_dir, "code.txt")
    
    # Construct the path to Instruction_memory.mem in the ../Src/ directory
    output_dir = os.path.join(script_dir, "..", "Src")
    os.makedirs(output_dir, exist_ok=True)
    output_file_path = os.path.join(output_dir, "Instruction_memory.mem")
    
    # Check if the code.txt file exists
    if not os.path.exists(code_file_path):
        print(f"Error: {code_file_path} not found.")
        return
    
    print(f"Processing instructions from {code_file_path} and saving to {output_file_path}...")
    
    try:
        with open(code_file_path, 'r') as input_file, open(output_file_path, 'w') as output_file:
            for line in input_file:
                instruction = line.strip()
                if instruction:  # Skip empty lines
                    process_instruction(instruction, output_file)
        print("\nInstructions have been successfully written to Instruction_memory.mem.")
    except KeyboardInterrupt:
        print("\nExiting...")

if __name__ == "__main__":
    main()
