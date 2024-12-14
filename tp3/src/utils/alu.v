module alu
#(
    parameter NB_DATA   = 32,
    parameter NB_OP     = 6
)
(
    input   wire    signed  [NB_DATA-1 : 0]  i_data_a,
    input   wire    signed  [NB_DATA-1 : 0]  i_data_b,
    input   wire            [NB_OP-1 : 0]    i_op,
    input   wire            [4 : 0]          i_shamt,
    output  wire    signed  [NB_DATA-1 : 0]  o_alu_result
);

    // R-type instructions
    localparam OP_IDLE      =   6'b111111;
    localparam OP_ADD       =   6'b100000;
    localparam OP_SUB       =   6'b100010;
    localparam OP_SLL       =   6'b000000;
    localparam OP_SRL       =   6'b000010;
    localparam OP_SRA       =   6'b000011;
    localparam OP_SLLV      =   6'b000100;
    localparam OP_SRLV      =   6'b000110;
    localparam OP_SRAV      =   6'b000111;
    localparam OP_ADDU      =   6'b100001;
    localparam OP_SUBU      =   6'b100011;
    localparam OP_AND       =   6'b100100;
    localparam OP_OR        =   6'b100101;
    localparam OP_XOR       =   6'b100110;
    localparam OP_NOR       =   6'b100111;
    localparam OP_SLT       =   6'b101010;
    localparam OP_SLTU      =   6'b101011;

    // I-type instructions
    localparam  OP_ADDI     =   6'b001000;
    localparam  OP_ADDIU    =   6'b001001;
    localparam  OP_ANDI     =   6'b001100;
    localparam  OP_ORI      =   6'b001101;
    localparam  OP_XORI     =   6'b001110;
    localparam  OP_LUI      =   6'b001111;
    localparam  OP_SLTI     =   6'b001010;
    localparam  OP_SLTIU    =   6'b001011;

    reg signed  [NB_DATA-1 : 0] res;
    reg         [NB_DATA-1 : 0] res_u;
    wire        [NB_DATA-1:0]   i_data_a;
    wire        [NB_DATA-1:0]   i_data_b;
    wire                        is_unsigned;

    always @(*) begin
        res     = 0;
        res_u   = 0;
        case (i_op)
            OP_IDLE:  res   = {NB_DATA{1'b0}};
            OP_ADD:   res   = i_data_a + i_data_b;
            OP_SUB:   res   = i_data_a - i_data_b;
            OP_SLL:   res   = i_data_b << i_shamt;
            OP_SRL:   res   = i_data_b >> i_shamt;
            OP_SRA:   res   = i_data_b >>> i_shamt;      
            OP_SLLV:  res   = i_data_b << i_data_a;      
            OP_SRLV:  res   = i_data_b >> i_data_a;      
            OP_SRAV:  res   = i_data_b >>> i_data_a;
            OP_ADDU:  res_u = dato_A_u + dato_B_u;
            OP_SUBU:  res_u = dato_A_u - dato_B_u;
            OP_AND:   res   = i_data_a & i_data_b;
            OP_OR:    res   = i_data_a | i_data_b;
            OP_XOR:   res   = i_data_a ^ i_data_b;
            OP_NOR:   res   = ~(i_data_a | i_data_b);        
            OP_SLT:   res   = (i_data_a < i_data_b) ? 1 : 0;
            OP_SLTU:  res_u = (dato_A_u < dato_B_u) ? 1 : 0;
            OP_ADDI:  res   = i_data_a + i_data_b;
            OP_ADDIU: res_u = dato_A_u + dato_B_u;
            OP_ANDI:  res   = i_data_a & i_data_b;
            OP_ORI:   res   = i_data_a | i_data_b;
            OP_XORI:  res   = i_data_a ^ i_data_b;
            OP_LUI:   res   = i_data_b << 16;
            OP_SLTI:  res   = (i_data_a < i_data_b) ? 1 : 0;
            OP_SLTIU: res_u = (dato_A_u < dato_B_u) ? 1 : 0;                                   
            default: begin
                res   = res;
                res_u = res_u;
            end   
        endcase
    end

    assign o_alu_result = is_unsigned ? res_u : res;
    assign is_unsigned = (i_op == OP_ADDU) || (i_op == OP_SUBU) || (i_op == OP_SLTU) || (i_op == OP_SLTIU) || (i_op == OP_ADDIU);

endmodule
