# MIPS Instruction Encoder

# Define function codes for R-type instructions
R_TYPE_FUNCTIONS = {
    "add": "100000",
    "addu": "100001",
    "and": "100100",
    "jr": "001000",
    "madd": "000000",
    "mfhi": "010000",
    "mflo": "010010",
    "movn": "001011",
    "movz": "001010",
    "msub": "000100",
    "mthi": "010001",
    "mtlo": "010011",
    "mul": "000010",
    "mult": "011000",
    "multu": "011001",
    "nor": "100111",
    "or": "100101",
    "sll": "000000",
    "slt": "101010",
    "sltu": "101011",
    "sra": "000011",
    "srl": "000010",
    "sub": "100010",
    "xor": "100110"
}


# Define opcodes for I-type instructions
I_TYPE_OPCODES = {
    "lw": "100011",
    "sw": "101011",
    "addi": "001000",
    "addiu": "001001",
    "ori": "001101",
    "xori": "001110",
    "lui": "001111",
    "lb": "100000",
    "lh": "100001",
    "andi": "001100",
    "slti": "001010",
    "sltiu": "001011"
}


# Define opcodes for J-type instructions
# TODO: Implement J-type instructions
J_TYPE_OPCODES = {
    "j": "000010",
    "jal": "000011"
}


# Function to determine instruction type
def get_instruction_type(op):
    if op in R_TYPE_FUNCTIONS:
        return "R"
    if op in I_TYPE_OPCODES:
        return "I"
    if op in J_TYPE_OPCODES:
        return "J"
    return "Unknown"


# Function to encode R-type instructions
# OP_TYPE (6 bits) | RS (5 bits) | RT (5 bits) | RD (5 bits) | SHAMT (5 bits) | FUNC (6 bits)
def encode_r_type(op, rs, rt, rd, shamt=0):
    op_type     = "000000"                  # R-type opcode is always 000000
    rs_bin      = f"{rs:05b}"               # Convert to 5-bit binary
    rt_bin      = f"{rt:05b}"               # Convert to 5-bit binary
    rd_bin      = f"{rd:05b}"               # Convert to 5-bit binary
    shamt_bin   = f"{shamt:05b}"            # Convert to 5-bit binary
    func_bin    = R_TYPE_FUNCTIONS[op]      # Get function code
    return op_type + rs_bin + rt_bin + rd_bin + shamt_bin + func_bin


# Function to encode I-type instructions
# OP_TYPE (6 bits) | RS (5 bits) | RT (5 bits) | Offset (16 bits)
def encode_i_type(op, rs, rt, off):
    op_type     = I_TYPE_OPCODES[op]        # Get opcode
    rs_bin      = f"{rs:05b}"               # Convert to 5-bit binary
    rt_bin      = f"{rt:05b}"               # Convert to 5-bit binary
    off_bin     = f"{off:016b}"             # Convert to 16-bit binary
    return op_type + rs_bin + rt_bin + off_bin


def main():
    print("Usage:")
    print("  R-Type format: <operation> <rs> <rt> <rd>")
    print("  I-Type format: <operation> <base> <rt> <offset>")
    print("Examples:")
    print("  add 9 10 8   (R-Type) -> add $s1, $s2, $s3")
    print("  sw 17 16 14  (I-Type) -> sw $base, offset($rt)")
    
    instruction = input("Enter instruction: ").strip().split()
    if len(instruction) < 4:
        print("Invalid input.")
        return

    op          = instruction[0]
    instr_type  = get_instruction_type(op)
    
    if instr_type == "R":
        rs, rt, rd          = map(int, instruction[1:4])
        binary_instruction  = encode_r_type(op, rs, rt, rd)
    elif instr_type == "I":
        rs, rt, off         = map(int, instruction[1:4])
        binary_instruction  = encode_i_type(op, rs, rt, off)
    elif instr_type == "J":
        print("J-type instructions not supported yet.")
        return
    else:
        print("Unsupported instruction type or unknown operation.")

    print(f"{'Bin encoding:':<18} {binary_instruction}")
    print(f"{'Hex encoding:':<18} {hex(int(binary_instruction, 2))}")
    print(f"{'Dec encoding:':<18} {int(binary_instruction, 2)}")

if __name__ == "__main__":
    main()
