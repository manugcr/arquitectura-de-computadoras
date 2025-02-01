import os
from enum import Enum


class RegisterMap(Enum):
    ZERO    = 0
    V0      = 2
    V1      = 3
    A0      = 4
    A1      = 5
    A2      = 6
    A3      = 7
    T0      = 8
    T1      = 9
    T2      = 10
    T3      = 11
    T4      = 12
    T5      = 13
    T6      = 14
    T7      = 15
    S0      = 16
    S1      = 17
    S2      = 18
    S3      = 19
    S4      = 20
    S5      = 21
    S6      = 22
    S7      = 23
    T8      = 24
    T9      = 25
    GP      = 28
    SP      = 29
    FP      = 30
    RA      = 31


class RTypeFunctions(Enum):
    ADD     = "100000"
    SUB     = "100010"
    AND     = "100100"
    OR      = "100101"
    XOR     = "100110"
    NOR     = "100111"
    SLL     = "000000"
    SRL     = "000010"
    SRA     = "000011"
    SLT     = "101010"
    SLTU    = "101011"
    JR      = "001000"


class ITypeOpcodes(Enum):
    LW      = "100011"
    SW      = "101011"
    ADDI    = "001000"
    ORI     = "001101"
    ANDI    = "001100"
    SLTI    = "001010"


class InstructionEncoder:

    # R-Type: add $t0, $t1, $t2
    #   6           5   5   5   5       6       [bits]
    #   OP_TYPE     RS  RT  RD  SHAMT   OP_CODE
    # 
    # I-Type: lw $t0, 4($s0)
    #   6           5   5   16                  [bits]
    #   OP_CODE     RS  RT  OFFSET
    #
    # J-Type: j 0x00400000
    #   6           26                          [bits]
    #   OP_CODE     ADDRESS

    @staticmethod
    def encode_r_type(op, rs, rt, rd, shamt=0):
        binary = f"000000{rs:05b}{rt:05b}{rd:05b}{shamt:05b}{RTypeFunctions[op.upper()].value}"
        return InstructionEncoder.format_encoding(binary)

    @staticmethod
    def encode_i_type(op, rs, rt, offset):
        binary = f"{ITypeOpcodes[op.upper()].value}{rs:05b}{rt:05b}{offset & 0xFFFF:016b}"
        return InstructionEncoder.format_encoding(binary)

    @staticmethod
    def format_encoding(binary):
        hex_encoding = format(int(binary, 2), '08x')
        return binary, hex_encoding, int(binary, 2)


class InstructionParser:
    @staticmethod
    def clean_register(reg: str):
        """Removes '$' and converts register names to uppercase for consistency."""
        return reg.upper().replace("$", "")

    @staticmethod
    def parse_operands(op, operands):
        operands = [o.strip() for o in operands.split(',')]
        op_upper = op.upper()

        if op_upper in RTypeFunctions.__members__:
            rd = RegisterMap[InstructionParser.clean_register(operands[0])].value
            rs = RegisterMap[InstructionParser.clean_register(operands[1])].value
            rt = RegisterMap[InstructionParser.clean_register(operands[2])].value
            print(f"[DEBUG] {op} {operands}")
            print(f"[DEBUG] rd: {rd}, rs: {rs}, rt: {rt}")
            return rs, rd, rt

        if op_upper in ITypeOpcodes.__members__:
            rs, rt_offset = operands
            offset, rt = rt_offset.strip("()").split('(')

            rs_value = RegisterMap[InstructionParser.clean_register(rs)].value
            rt_value = RegisterMap[InstructionParser.clean_register(rt)].value
            offset_value = int(offset)
            print(f"[DEBUG] {op} {operands}")
            print(f"[DEBUG] rs: {rs_value}, rt: {rt_value}, offset: {offset_value}")
            return rt_value, rs_value, offset_value

        print(f"[ERROR] Unknown operation: {op}")
        return None


class MIPSAssembler:
    def __init__(self, input_file, output_file):
        self.input_file = input_file
        self.output_file = output_file

    def process_instruction(self, instruction):
        op, operands = instruction.split(' ', 1)
        instr_type = self.get_instruction_type(op)
        
        print(f"[DEBUG] Instruction: {instruction}")

        try:
            parsed_operands = InstructionParser.parse_operands(op, operands)
            print(f"[DEBUG] Parsed operands: {parsed_operands}")
            if instr_type == "R":
                binary, hex_encoding, decimal_encoding = InstructionEncoder.encode_r_type(op, *parsed_operands)
            elif instr_type == "I":
                binary, hex_encoding, decimal_encoding = InstructionEncoder.encode_i_type(op, *parsed_operands)
            else:
                print(f"Unsupported instruction: {instruction}")
                return None
            
            print(f"[DEBUG] Hex: {hex_encoding}")
            print(f"[DEBUG] Bin: {binary}")
            print(f"[DEBUG] Dec: {decimal_encoding}")
            print("-" * 50)
            return hex_encoding
        except Exception as e:
            print(f"Error processing instruction: {instruction}, Error: {e}")
            return None

    def get_instruction_type(self, op):
        if op.upper() in RTypeFunctions.__members__:
            return "R"
        elif op.upper() in ITypeOpcodes.__members__:
            return "I"
        return "Unknown"

    def assemble(self):
        if not os.path.exists(self.input_file):
            print(f"Error: {self.input_file} not found.")
            return

        print(f"Processing instructions from {self.input_file} and saving to {self.output_file}...\n")

        try:
            with open(self.input_file, 'r') as infile, open(self.output_file, 'w') as outfile:
                written_instructions = []
                for line in infile:
                    instruction = line.strip()
                    if instruction:
                        encoded_instruction = self.process_instruction(instruction)
                        if encoded_instruction:
                            outfile.write(encoded_instruction + '\n')
                            written_instructions.append(encoded_instruction)

                # Pad the file with '00000000' if fewer than 512 instructions
                while len(written_instructions) < 512:
                    outfile.write("00000000\n")
                    written_instructions.append("00000000")
            print("\nInstructions have been successfully written.")
        except KeyboardInterrupt:
            print("\nExiting...")


if __name__ == "__main__":
    script_dir  = os.path.dirname(os.path.abspath(__file__))
    input_file  = os.path.join(script_dir, "code.txt")
    output_file = os.path.join(script_dir, "..", "Src", "Instruction_memory.mem")
    os.makedirs(os.path.dirname(output_file), exist_ok=True)

    assembler = MIPSAssembler(input_file, output_file)
    assembler.assemble()
