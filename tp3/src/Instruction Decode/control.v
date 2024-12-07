module control_unit
#( 
    // I TYPE
    parameter OPP_LB     = 6'b100000,
    parameter OPP_LH     = 6'b100001,
    parameter OPP_LW     = 6'b100011,
    parameter OPP_LWU    = 6'b100111,
    parameter OPP_LBU    = 6'b100100,
    parameter OPP_LHU    = 6'b100101,
    parameter OPP_SB     = 6'b101000,
    parameter OPP_SH     = 6'b101001,
    parameter OPP_SW     = 6'b101011,
    parameter OPP_ADDI   = 6'b001000,
    parameter OPP_ANDI   = 6'b001100,
    parameter OPP_ORI    = 6'b001101,
    parameter OPP_XORI   = 6'b001110,
    parameter OPP_LUI    = 6'b001111,
    parameter OPP_SLTI   = 6'b001010,
    parameter OPP_BEQ    = 6'b000100,
    parameter OPP_BNE    = 6'b000101,
    parameter OPP_J      = 6'b000010,
    parameter OPP_JAL    = 6'b000011,

    parameter OPP_R_TYPE = 6'b000000, 
    // R TYPE
    parameter FUNCT_SLL  = 6'b000000,
    parameter FUNCT_SRL  = 6'b000010,
    parameter FUNCT_SRA  = 6'b000011,

    // J TYPE
    parameter FUNCT_JR   = 6'b001000,
    parameter FUNCT_JALR = 6'b001001,


    parameter SEQUENTIAL = 2'b00,
    parameter JUMP_TO_REG =2'b01,
    parameter JUMP_TO_DIR =2'b10,
    parameter JUMP_TO_BRANCH = 2'b11,

    parameter RD = 1'b1,
    parameter RT = 1'b0,
    parameter NONE = 1'bx,

    parameter BUS_INMSIG = 3'b110,
    parameter BUS_INMNOSIG = 3'b111,
    parameter X_PC = 3'b000,
    parameter SHAMT_BUS = 3'010,
    parameter BUS_PC = 3'b001,
    parameter BUS_UPPER = 3'b100,
    parameter BUS_BUS = 3'b011,
    parameter X_X = 3'bxxx,

      // ALU control parameters
    parameter LOAD_TYPE = 3'b000, // Load instructions
    parameter STORE_TYPE = 3'b000, // Store instructions
    parameter ADDI = 3'b000, // Add immediate instruction
    parameter BRANCH_TYPE = 3'b001, // Branch instructions
    parameter ANDI = 3'b010, // And immediate instruction
    parameter ORI = 3'b011, // Or immediate instruction
    parameter XORI = 3'b100, // Xor immediate instruction
    parameter SLTI_TYPE = 3'b101, // Set less than immediate instruction
    parameter R_TYPE = 3'b110, // R-Type instructions
    parameter JUMP_TYPE = 3'b111, // Jump instructions
    parameter UNDEFINED = 3'bxxx, // Undefined instruction

    // MEMORY READ SOURCE
    parameter MR_WORD = 3'b000, // Memory read source is word
    parameter SIG_HALFWORD = 3'b001, // Memory read source is signed halfword
    parameter SIG_BYTE = 3'b010, // Memory read source is signed byte
    parameter USIG_HALFWORD = 3'b011, // Memory read source is unsigned halfword
    parameter USIG_BYTE = 3'b100, // Memory read source is unsigned byte
    parameter MR_NOTHING = 3'bxxx, // Memory read source is nothing

    // MEMORY WRITE SOURCE
    parameter WORD = 2'b00 , // Memory write source is word
    parameter HALFWORD = 2'b01 , // Memory write source is halfword
    parameter BYTE = 2'b10 , // Memory write source is byte
    parameter NOTHING = 2'bxx , // Memory write source is nothing

    parameter DISABLE = 1'b0,
    parameter ENABLE  = 1'b1,
   
    parameter to_ALU = 1'b1,
    parameter to_MEM = 1'b0,

)(

    input wire [5:0] i_opp       , //[31:26] instruction
    input wire [5:0] i_funct        , // for R-type [5:0] field
    input wire i_are_equal,
    input  wire i_instr_nop,                // is nop?


    //output
    output wire [1:0]   o_PCSrc     , 
    output wire         o_RegDst    , 
    output wire [2:0]   o_ControlAB , 
    output wire [2:0]   o_OPP       , 
    output wire [2:0]   o_MemRead   , 
    output wire [1:0]   o_widthMW   , 
    output wire         o_MemWrite  , 
    output wire         o_Mem2Reg   , 
    output wire         o_WriteBack , 
);  
    

    reg r_RegDst, r_MemWrite , r_Mem2Reg ,r_WriteBack;
    reg [1:0] r_PCSrc, r_widthMW;
    reg [2:0] r_ControlAB , r_OPP , r_MemRead;

    always @(*) begin
    if(!i_instr_nop)

        case (i_opp)

            LB_TYPE: begin
                r_PCsrc     = SEQUENTIAL                                                      ;                                                     ;
                r_RegDst    = RT                                                     ; 
                r_ControlAB = BUS_INMSIG                                                     ; 
                r_OPP       = LOAD_TYPE                                                     ; 
                r_MemRead   = SIG_BYTE                                                      ;
                r_widthMW   = NOTHING                                                     ;
                r_MemWrite  = DISABLE                                                      ;
                r_WriteBack = ENABLE                                                      ;
                r_Mem2Reg   = to_MEM                                                      ; 
            end

            LH_TYPE: begin
                r_PCsrc     = SEQUENTIAL                                                      ;                                                     ;
                r_RegDst    = RT                                                     ; 
                r_ControlAB = BUS_INMSIG                                                     ; 
                r_OPP       = LOAD_TYPE                                                     ; 
                r_MemRead   = SIG_HALFWORD                                                      ;
                r_widthMW   = NOTHING                                                     ;
                r_MemWrite  = DISABLE                                                      ;
                r_WriteBack = ENABLE                                                      ;
                r_Mem2Reg   = to_MEM                                                      ; 
            end

            LW_TYPE: begin
                r_PCsrc     = SEQUENTIAL                                                      ;                                                     ;
                r_RegDst    = RT                                                     ; 
                r_ControlAB = BUS_INMSIG                                                     ; 
                r_OPP       = LOAD_TYPE                                                     ; 
                r_MemRead   = MR_WORD                                                      ;
                r_widthMW   = NOTHING                                                     ;
                r_MemWrite  = DISABLE                                                      ;
                r_WriteBack = ENABLE                                                      ;
                r_Mem2Reg   = to_MEM                                                      ; 
            end 

            LWU_TYPE: begin
                r_PCsrc     = SEQUENTIAL                                                      ;                                                     ;
                r_RegDst    = RT                                                     ; 
                r_ControlAB = BUS_INMSIG                                                     ; 
                r_OPP       = LOAD_TYPE                                                     ; 
                r_MemRead   = MR_WORD                                                      ;
                r_widthMW   = NOTHING                                                     ;
                r_MemWrite  = DISABLE                                                      ;
                r_WriteBack = ENABLE                                                      ;
                r_Mem2Reg   = to_MEM                                                      ; 
            end 

            LBU_TYPE: begin
                r_PCsrc     = SEQUENTIAL                                                      ;                                                     ;
                r_RegDst    = RT                                                     ; 
                r_ControlAB = BUS_INMSIG                                                     ; 
                r_OPP       = LOAD_TYPE                                                     ; 
                r_MemRead   = USIG_BYTE                                                      ;
                r_widthMW   = NOTHING                                                     ;
                r_MemWrite  = DISABLE                                                      ;
                r_WriteBack = ENABLE                                                      ;
                r_Mem2Reg   = to_MEM                                                      ; 
            end  

            LHU_TYPE: begin
                r_PCsrc     = SEQUENTIAL                                                      ;                                                     ;
                r_RegDst    = RT                                                     ; 
                r_ControlAB = BUS_INMSIG                                                     ; 
                r_OPP       = LOAD_TYPE                                                     ; 
                r_MemRead   = USIG_HALFWORD                                                      ;
                r_widthMW   = NOTHING                                                     ;
                r_MemWrite  = DISABLE                                                      ;
                r_WriteBack = ENABLE                                                      ;
                r_Mem2Reg   = to_MEM                                                      ; 
            end   

            SB_TYPE: begin // rs para mem access - rt dirección del dato a guardar
                r_PCsrc     = SEQUENTIAL                                                      ;                                                     ;
                r_RegDst    = NONE                                                     ; 
                r_ControlAB = BUS_INMSIG                                                     ; 
                r_OPP       = STORE_TYPE                                                     ; 
                r_MemRead   = MR_NOTHING                                                      ;
                r_widthMW   = BYTE                                                     ;
                r_MemWrite  = ENABLE                                                      ;
                r_WriteBack = DISABLE                                                      ;
                r_Mem2Reg   = NONE                                                      ; 
            end      

            SH_TYPE: begin            
                r_PCsrc     = SEQUENTIAL                                                      ;                                                     ;
                r_RegDst    = NONE                                                     ; 
                r_ControlAB = BUS_INMSIG                                                     ; 
                r_OPP       = STORE_TYPE                                                     ; 
                r_MemRead   = MR_NOTHING                                                      ;
                r_widthMW   = HALFWORD                                                     ;
                r_MemWrite  = ENABLE                                                      ;
                r_WriteBack = DISABLE                                                      ;
                r_Mem2Reg   = NONE                                                      ; 
            end   

            SW_TYPE: begin  
                r_PCsrc     = SEQUENTIAL                                                      ;                                                     ;
                r_RegDst    = NONE                                                     ; 
                r_ControlAB = BUS_INMSIG                                                     ; 
                r_OPP       = STORE_TYPE                                                     ; 
                r_MemRead   = MR_NOTHING                                                      ;
                r_widthMW   = WORD                                                     ;
                r_MemWrite  = ENABLE                                                      ;
                r_WriteBack = DISABLE                                                      ;
                r_Mem2Reg   = NONE                                                      ; 
            end  

            ADDI_TYPE: begin
                r_PCsrc     = SEQUENTIAL                                                      ;                                                     ;
                r_RegDst    = RT                                                     ; 
                r_ControlAB = BUS_INMSIG                                                     ; 
                r_OPP       = STORE_TYPE                                                     ; 
                r_MemRead   = MR_NOTHING                                                      ;
                r_widthMW   = NOTHING                                                     ;
                r_MemWrite  = DISABLE                                                      ;
                r_WriteBack = ENABLE                                                      ;
                r_Mem2Reg   = to_ALU                                                      ; 
            end  

            ANDI_TYPE: begin
                r_PCsrc     = SEQUENTIAL                                                      ;                                                     ;
                r_RegDst    = RT                                                     ; 
                r_ControlAB = BUS_INMNOSIG                                                     ; 
                r_OPP       = ANDI                                                     ; 
                r_MemRead   = MR_NOTHING                                                      ;
                r_widthMW   = NOTHING                                                     ;
                r_MemWrite  = DISABLE                                                      ;
                r_WriteBack = ENABLE                                                      ;
                r_Mem2Reg   = to_ALU                                                      ; 
            end  

            ORI_TYPE: begin // 
                r_PCsrc     = SEQUENTIAL                                                      ;                                                     ;
                r_RegDst    = RT                                                     ; 
                r_ControlAB = BUS_INMNOSIG                                                     ; 
                r_OPP       = ORI                                                     ; 
                r_MemRead   = MR_NOTHING                                                      ;
                r_widthMW   = NOTHING                                                     ;
                r_MemWrite  = DISABLE                                                      ;
                r_WriteBack = ENABLE                                                      ;
                r_Mem2Reg   = to_ALU                                                      ; 
            end  

            XORI_TYPE: begin
                r_PCsrc     = SEQUENTIAL                                                      ;                                                     ;
                r_RegDst    = RT                                                     ; 
                r_ControlAB = BUS_INMNOSIG                                                     ; 
                r_OPP       = XORI                                                     ; 
                r_MemRead   = MR_NOTHING                                                      ;
                r_widthMW   = NOTHING                                                     ;
                r_MemWrite  = DISABLE                                                      ;
                r_WriteBack = ENABLE                                                      ;
                r_Mem2Reg   = to_ALU                                                      ; 
            end  

            LUI_TYPE: begin 
                r_PCsrc     = SEQUENTIAL                                                      ;                                                     ;
                r_RegDst    = RT                                                     ; 
                r_ControlAB = BUS_UPPER                                                     ; 
                r_OPP       = LOAD_TYPE                                                     ; 
                r_MemRead   = MR_NOTHING                                                      ;
                r_widthMW   = NOTHING                                                     ;
                r_MemWrite  = DISABLE                                                      ;
                r_WriteBack = ENABLE                                                      ;
                r_Mem2Reg   = to_ALU                                                      ; 
            end    ///

            OPP_SLTI: begin
                r_PCsrc     = SEQUENTIAL                                                      ;                                                     ;
                r_RegDst    = RT                                                     ; 
                r_ControlAB = BUS_INMSIG                                                     ; 
                r_OPP       = SLTI_TYPE                                                     ; 
                r_MemRead   = MR_NOTHING                                                      ;
                r_widthMW   = NOTHING                                                     ;
                r_MemWrite  = DISABLE                                                      ;
                r_WriteBack = ENABLE                                                      ;
                r_Mem2Reg   = to_ALU                                                      ; 
            end

            BEQ_TYPE: begin                                                                                          ;                                                     ;
                r_RegDst    = NONE                                                     ; 
                r_ControlAB = X_X                                                     ; 
                r_OPP       = BRANCH_TYPE                                                    ; 
                r_MemRead   = MR_NOTHING                                                      ;
                r_widthMW   = NOTHING                                                     ;
                r_MemWrite  = DISABLE                                                      ;
                r_WriteBack = DISABLE                                                      ;
                r_Mem2Reg   = NONE                                                      ; 
                                                
                if (i_are_equal == 1'b1) begin
                    r_PCsrc = JUMP_TO_BRANCH; // PC secuencial
                end else begin
                    r_PCsrc = SEQUENTIAL; 
                end      
            end

            BNE_TYPE: begin //                                      
                r_RegDst    = NONE                                                     ; 
                r_ControlAB = X_X                                                     ; 
                r_OPP       = BRANCH_TYPE                                                    ; 
                r_MemRead   = MR_NOTHING                                                      ;
                r_widthMW   = NOTHING                                                     ;
                r_MemWrite  = DISABLE                                                      ;
                r_WriteBack = DISABLE                                                      ;
                r_Mem2Reg   = NONE                                                      ; 
                                                
                if (i_are_equal == 1'b1) begin
                    r_PCsrc = JUMP_TO_BRANCH; // PC secuencial
                end else begin
                    r_PCsrc = SEQUENTIAL; 
                end      
            end ////

            J_TYPE: begin
                r_PCsrc     = JUMP_TO_DIR                                                      ;                                                     ;
                r_RegDst    = NONE                                                     ; 
                r_ControlAB = X_X                                                     ; 
                r_OPP       = JUMP_TYPE                                                     ; 
                r_MemRead   = MR_NOTHING                                                      ;
                r_widthMW   = NOTHING                                                     ;
                r_MemWrite  = DISABLE                                                      ;
                r_WriteBack = DISABLE                                                      ;
                r_Mem2Reg   = NONE                                                      ; 
            end

            JAL_TYPE: begin
                r_PCsrc     = JUMP_TO_DIR                                                      ;                                                     ;
                r_RegDst    = NONE                                                     ; 
                r_ControlAB = X_PC                                                     ; 
                r_OPP       = JUMP_TYPE                                                     ; 
                r_MemRead   = MR_NOTHING                                                      ;
                r_widthMW   = NOTHING                                                     ;
                r_MemWrite  = DISABLE                                                      ;
                r_WriteBack = ENABLE                                                      ;
                r_Mem2Reg   = to_ALU                                                      ; 
            end


            OPP_R_TYPE :
                case (i_funct)
                    FUNCT_SLL: begin
                        r_PCsrc     = SEQUENTIAL                                                      ;                                                     ;
                        r_RegDst    = RD                                                     ; 
                        r_ControlAB = SHAMT_BUS                                                     ; 
                        r_OPP       = R_TYPE                                                     ; 
                        r_MemRead   = MR_NOTHING                                                      ;
                        r_widthMW   = NOTHING                                                     ;
                        r_MemWrite  = DISABLE                                                      ;
                        r_WriteBack = ENABLE                                                      ;
                        r_Mem2Reg   = to_ALU                                                      ; 
                    end
                    FUNCT_SRL: begin
                        r_PCsrc     = SEQUENTIAL                                                      ;                                                     ;
                        r_RegDst    = RD                                                     ; 
                        r_ControlAB = SHAMT_BUS                                                     ; 
                        r_OPP       = R_TYPE                                                     ; 
                        r_MemRead   = MR_NOTHING                                                      ;
                        r_widthMW   = NOTHING                                                     ;
                        r_MemWrite  = DISABLE                                                      ;
                        r_WriteBack = ENABLE                                                      ;
                        r_Mem2Reg   = to_ALU                                                      ; 
                    end
                    FUNCT_SRA: begin
                        r_PCsrc     = SEQUENTIAL                                                      ;                                                     ;
                        r_RegDst    = RD                                                     ; 
                        r_ControlAB = SHAMT_BUS                                                     ; 
                        r_OPP       = R_TYPE                                                     ; 
                        r_MemRead   = MR_NOTHING                                                      ;
                        r_widthMW   = NOTHING                                                     ;
                        r_MemWrite  = DISABLE                                                      ;
                        r_WriteBack = ENABLE                                                      ;
                        r_Mem2Reg   = to_ALU                                                      ; 
                    end
                    FUNCT_JR: begin
                        r_PCsrc     = JUMP_TO_REG                                                      ;                                                     ;
                        r_RegDst    = NONE                                                     ; 
                        r_ControlAB = X_X                                                     ; 
                        r_OPP       = R_TYPE                                                     ; 
                        r_MemRead   = MR_NOTHING                                                      ;
                        r_widthMW   = NOTHING                                                     ;
                        r_MemWrite  = DISABLE                                                      ;
                        r_WriteBack = DISABLE                                                      ;
                        r_Mem2Reg   = NONE                                                      ; 
                    end
                    FUNCT_JALR: begin
                        r_PCsrc     = JUMP_TO_REG                                                      ;                                                     ;
                        r_RegDst    = NONE                                                     ; 
                        r_ControlAB = BUS_PC                                                     ; 
                        r_OPP       = R_TYPE                                                     ; 
                        r_MemRead   = MR_NOTHING                                                      ;
                        r_widthMW   = NOTHING                                                     ;
                        r_MemWrite  = DISABLE                                                      ;
                        r_WriteBack = ENABLE                                                      ;
                        r_Mem2Reg   = to_ALU                                                      ; 
                    end
                    default: begin
                        r_PCsrc     = SEQUENTIAL;
                        r_RegDst    = RD;
                        r_ControlAB = BUS_BUS;
                        r_OPP       = R_TYPE;
                        r_MemRead   = MR_NOTHING;
                        r_widthMW   = NOTHING;
                        r_MemWrite  = DISABLE;
                        r_WriteBack = ENABLE;
                        r_Mem2Reg   = to_ALU;
                    end
                endcase

            default: begin
                        r_PCsrc     = SEQUENTIAL;
                        r_RegDst    = NONE;
                        r_ControlAB = X_X;
                        r_OPP       = R_TYPE;
                        r_MemRead   = MR_NOTHING;
                        r_widthMW   = NOTHING;
                        r_MemWrite  = DISABLE;
                        r_WriteBack = DISABLE;
                        r_Mem2Reg   = NONE;
                    end
        endcase
    else
        r_PCsrc     = SEQUENTIAL                                                      ;                                                     ;
        r_RegDst    = NONE                                                     ; 
        r_ControlAB = X_X                                                     ; 
        r_OPP       = UNDEFINED                                                    ; 
        r_MemRead   = MR_NOTHING                                                      ;
        r_widthMW   = NOTHING                                                     ;
        r_MemWrite  = DISABLE                                                      ;
        r_WriteBack = DISABLE                                                      ;
        r_Mem2Reg   = NONE 
    end

    assign o_PCSrc        = r_PCsrc                                            ;
    assign o_RegDst       = r_RegDst                                           ;
    assign o_ControlAB        = r_ControlAB                                           ;
    assign o_OPP        = r_OPP                                           ;
    assign o_MemRead     = r_MemRead                                      ;
    assign o_widthMW          = r_widthMW                                           ;
    assign o_MemWrite       = r_MemWrite                                       ;
    assign o_WriteBack       = r_WriteBack                                          ;
    assign o_Mem2Reg      = r_Mem2Reg                                       ;
                                    
endmodule