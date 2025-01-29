# MIPS Instruction Encoder
import os

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

def get_instruction_type(op):
    if op in R_TYPE_FUNCTIONS:
        return "R"
    elif op in I_TYPE_OPCODES:
        return "I"
    return "Unknown"

def format_encoding(binary):
    hex_encoding = hex(int(binary, 2))
    decimal_encoding = int(binary, 2)
    return binary, hex_encoding, decimal_encoding

# Function to encode R-type instructions
# OP_TYPE (6 bits) | RS (5 bits) | RT (5 bits) | RD (5 bits) | SHAMT (5 bits) | OP (6 bits)
def encode_r_type(op, rs, rt, rd, shamt=0):
    binary = f"000000{rs:05b}{rt:05b}{rd:05b}{shamt:05b}{R_TYPE_FUNCTIONS[op]}"
    return format_encoding(binary)

# Function to encode I-type instructions
# OP (6 bits) | RS (5 bits) | RT (5 bits) | Offset (16 bits)
def encode_i_type(op, rs, rt, offset):
    binary = f"{I_TYPE_OPCODES[op]}{rs:05b}{rt:05b}{offset & 0xFFFF:016b}"
    return format_encoding(binary)

def process_instruction(instruction):
    if len(instruction) < 4:
        print("Invalid input. Please follow the format guidelines above.")
        return

    op = instruction[0]
    instr_type = get_instruction_type(op)
    
    try:
        if instr_type == "R":
            rd, rs, rt = map(int, instruction[1:4])
            binary_instruction, hex_instruction, decimal_instruction = encode_r_type(op, rs, rt, rd)
        elif instr_type == "I":
            rs, rt, offset = map(int, instruction[1:4])
            binary_instruction, hex_instruction, decimal_instruction = encode_i_type(op, rs, rt, offset)
        elif instr_type == "J":
            print("J-type instructions are not supported yet.")
            return
        else:
            print("Unsupported instruction type or unknown operation.")
            return
    except ValueError:
        print("Invalid input. Ensure all operands are integers.")
        return
    
    print(f"{'Format':<18}{'Value'}")
    print("-" * 50)
    print(f"{'Bin encoding:':<18}{binary_instruction}")
    print(f"{'Hex encoding:':<18}{hex_instruction}")
    print(f"{'Dec encoding:':<18}{decimal_instruction}")

    save_to_file(decimal_instruction)
 
def save_to_file(instruction):
    file_path = os.path.join(os.path.dirname(__file__), "../Src/Instruction_memory.mem")
    
    try:
        with open(file_path, "w") as file:
            file.write(f"{instruction}\n")
    except Exception as e:
        print(f"Error writing to file: {e}")

def main():
    print("Usage:")
    print("  R-Type format: <operation> <rd> <rs> <rt>")
    print("  I-Type format: <operation> <rs> <rt> <offset>")
    print("Examples:")
    print("  add 8 9 10  (R-Type) -> add $rd, $rs, $rt")
    print("  sw 14 5 10  (I-Type) -> sw $s0, 14($s1)")
    
    try:
        while True:
            instruction = input("\nEnter instruction: ").strip().split()
            if instruction[0].lower() == 'exit':
                break
            process_instruction(instruction)
    except KeyboardInterrupt:
        print("\nExiting...")

if __name__ == "__main__":
    main()
