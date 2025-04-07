module ID_Stage
#(
    parameter NB_DATA = 32,
    parameter NB_ADDR = 5
)(
    input wire                 clk              ,
    input wire                 i_rst_n          ,
    input wire [NB_DATA-1:0]   i_instruction    ,
    input wire [NB_DATA-1:0]   i_pcounter4      ,
    input wire                 i_we_wb          ,
    input wire                 i_we             ,
    input wire [NB_ADDR-1:0]   i_wr_addr        ,
    input wire [NB_DATA-1:0]   i_wr_data_WB     ,
    input wire                 i_stall          ,
    input wire                 i_halt           ,
                                                                
    output reg [4:0]    o_rs                    ,    
    output reg [4:0]    o_rt                    ,
    output reg [4:0]    o_rd                    ,

    output reg [NB_DATA-1:0]   o_reg_DA         ,
    output reg [NB_DATA-1:0]   o_reg_DB         ,

    output reg [NB_DATA-1:0]   o_immediate      ,
    output reg [5 :0]           o_opcode        ,
    output reg [4 :0]           o_shamt         ,
    output reg [5 :0]           o_func          ,
    output reg [31:0]           o_addr2jump     ,
    output reg [1: 0]           o_jump_cases    , //! 00-> no JUMP | 01 -> BRANHC! | 10 -> jump & lINK
    //ctrl unit                                                         
    output reg                  o_jump          , 
    output reg                  o_branch        , 
    output reg                  o_regDst        , 
    output reg                  o_mem2Reg       , 
    output reg                  o_memRead       , 
    output reg                  o_memWrite      , 
    output reg                  o_immediate_flag, 
    output reg                  o_sign_flag     ,
    output reg                  o_regWrite      ,
    output reg [1:0]            o_aluSrc        ,
    output reg [1:0]            o_width         ,
    output reg [1:0]            o_aluOp         ,
    output wire                 o_stop

);
    localparam HALT = 32'hFFFFFFFF;            // last instruction of the program!!!

    wire [NB_DATA-1:0] ReadData1, ReadData2 ;  // VALORES LEIDOS DE LA "MEMORIA DE REGISTROS"

    
    localparam [5:0]                                                            
                    JR_TYPE     = 6'b001000     ,
                    JARL_TYPE   = 6'b001001     ,
                    R_TYPE      = 6'b000000     ,
                    BEQ_TYPE    = 6'b000100     ,
                    J_TYPE      = 6'b000010     ,
                    JAL_TYPE    = 6'b000011     ,
                    BNE_TYPE    = 6'b000101     ;

    // ---- ctrl unit ----
    //reg [5:0] reg_opcode, reg_funct;
    wire w_jump, w_branch, w_regDst, w_mem2Reg, w_memRead, w_memWrite, w_immediate, w_regWrite, w_sign_flag ;
    wire [1:0] w_aluSrc, w_aluOp, w_width;
    wire [NB_DATA -1: 0] w_immediat;

    // ============================================================================
    // |   31-26   |   25-21  |   20-16  |   15-11  | 10-6     |   5-0             |
    // |  opcode   |    rs    |    rt    |    rd    | shamt    |  funct           | ← type R
    // |  [5:0]    |  [4:0]   |  [4:0]   |  [4:0]   | [4:0]    |  [5:0]           |
    // ============================================================================
    // |  opcode   |    rs    |    rt    |           immediate / imm           | ← type I
    // |  [5:0]    |  [4:0]   |  [4:0]   |                 [15:0]                 |
    // ============================================================================
    // |  opcode   |                   jump address (target)                      | ← type J
    // |  [5:0]    |                         [25:0]                               |
    // ============================================================================

    
    wire [4 :0] rs, rt, rd          ;
    wire [5:0] opcode               ;
    wire [15:0] imm                 ;
    wire [5:0] func                 ;

    assign opcode = i_instruction[31:26]            ;
    assign imm    = i_instruction[15:0]             ;
    assign func   = i_instruction[5:0]              ;
    assign rs     = i_instruction[25:21]            ;
    assign rt     = i_instruction[20:16]            ;
    assign rd     = i_instruction[15:11]            ;

    //! registers file
    Registers #()                               
    regist(                               
        .clk        (clk        )               ,
        .i_rst_n    (i_rst_n    )               ,
        .i_we       (i_we       )               , 
        .i_wr_addr  (i_wr_addr  )               , 
        .i_wr_data  (i_wr_data_WB)              ,
        .i_read_reg1 (rs)                       ,
        .i_read_reg2 (rt)                       ,
        .o_ReadData1 (ReadData1)                ,   
        .o_ReadData2 (ReadData2)                                                           
    );                                                          

    //! control unit
    Control #()                                                            
    ctrl                                                           
    (                                                           
        .clk        (clk        )               ,
        .i_rst_n    (i_rst_n    )               ,
        .i_opcode   (opcode     )               ,
        .i_funct    (func       )               ,

        .o_jump     (w_jump     )               ,
        .o_aluSrc   (w_aluSrc   )               ,
        .o_aluOp    (w_aluOp    )               ,
        .o_branch   (w_branch   )               ,
        .o_regDst   (w_regDst   )               ,
        .o_mem2Reg  (w_mem2Reg  )               ,
        .o_regWrite (w_regWrite )               ,
        .o_memRead  (w_memRead  )               ,
        .o_memWrite (w_memWrite )               ,
        .o_width    (w_width    )               ,
        .o_sign_flag(w_sign_flag)               ,
        .o_immediate(w_immediate)
    );

    //! extends sign for immediate|
    SignExtension #()
    signExt
    (
        .i_immediate_flag   (w_immediate)       ,
        .i_immediate_value  (imm)    ,
        .o_data             (w_immediat)
    );


    //! jumps control
    always @(*) begin 

        o_jump       = 1'b0         ;   // does not jump
        o_jump_cases = 2'b00        ;   // does not jump
        o_addr2jump  = 0            ;   // does not jump
       
       
      if (w_jump || w_branch) begin
    // Execute only when a jump or branch opcode is detected
    case (opcode)

        R_TYPE: begin
            // R-type instruction: could be JR or JALR
            o_jump      = 1'b1;
            o_addr2jump = ReadData1; // Target address is the value in register rs
                  if (func == JARL_TYPE)
                      o_jump_cases = 2'b10; // Indicates a JALR case
            end

        BEQ_TYPE: begin
            // Branch if equal (BEQ)
            o_jump_cases = 2'b01; // BRANCH!!!

            if (ReadData1 == ReadData2) begin
                o_jump      = 1'b1;
                o_addr2jump = i_pcounter4 + (w_immediat << 2) + 4; // Calculated target address , immediate × 4 = w_immediat << 2
            end
        end

        BNE_TYPE: begin
            // Branch if not equal (BNE)
            o_jump_cases = 2'b01; // BRANCH!!!

            if (ReadData1 != ReadData2) begin
                o_jump      = 1'b1;
                o_addr2jump = i_pcounter4 + (w_immediat << 2) + 4; // Calculated target address
            end
        end

        JAL_TYPE: begin
            // Jump and Link: save return address and jump
            o_jump       = 1'b1;
            o_jump_cases = 2'b10; // JUMP & link!!!
            o_addr2jump  = {i_pcounter4[NB_DATA-1:NB_DATA-4], i_instruction[25:0], 2'b00}; // Absolute jump address
        end

        J_TYPE: begin
            // Unconditional jump (J)
            o_jump      = 1'b1;
            o_addr2jump = {i_pcounter4[NB_DATA-1:NB_DATA-4], i_instruction[25:0], 2'b00}; // Absolute jump address
        end

        endcase
    end
    end 

    //! update signals
        always @(posedge clk or negedge i_rst_n) begin
            if (!i_rst_n) begin
                o_reg_DA         <= 32'b0;
                o_reg_DB         <= 32'b0;
                o_rd             <= 5'b0;
                o_rs             <= 5'b0;
                o_rt             <= 5'b0;
                o_opcode         <= 6'b0;
                o_shamt          <= 5'b0;
                o_func           <= 6'b0;
                o_width          <= 2'b00;
                o_immediate      <= 0;
                o_immediate_flag <= 1'b0;
            end else begin
                if (!i_halt) begin
                    o_reg_DA         <= ReadData1;
                    o_reg_DB         <= ReadData2;
                    o_rd             <= rd;
                    o_rs             <= rs;
                    o_rt             <= rt;
                    o_opcode         <= opcode;
                    o_shamt          <= i_instruction[10:6];
                    o_func           <= func;
                    o_immediate      <= w_immediat;
                    o_branch         <= w_branch;
                    o_regDst         <= w_regDst;
                    o_mem2Reg        <= w_mem2Reg;
                    o_memRead        <= w_memRead;
                    o_memWrite       <= w_memWrite;
                    o_immediate_flag <= w_immediate;
                    o_regWrite       <= w_regWrite;
                    o_aluSrc         <= w_aluSrc;
                    o_aluOp          <= w_aluOp;
                    o_width          <= w_width;
                    o_sign_flag      <= w_sign_flag;

                    // Instrucciones especiales tipo JAL o JARL type r
                    if ((opcode == JAL_TYPE) || ((opcode == R_TYPE) && (func == JARL_TYPE))) begin
                        o_reg_DA <= i_pcounter4;
                        o_rs     <= 5'b0;
                        o_reg_DB <= 32'd4;
                    end
                    if (opcode == JAL_TYPE) begin
                        o_rt <= 5'b11111;
                    end

                    // Si hay stall, desactiva señales de control!!!
                    if (i_stall) begin
                        o_branch         <= 1'b0;
                        o_regDst         <= 1'b0;
                        o_mem2Reg        <= 1'b0;
                        o_memRead        <= 1'b0;
                        o_memWrite       <= 1'b0;
                        o_immediate_flag <= 1'b0;
                        o_regWrite       <= 1'b0;
                        o_aluSrc         <= 2'b00;
                        o_aluOp          <= 2'b00;
                        o_width          <= 2'b00;
                        o_sign_flag      <= 1'b0;
                    end
                end
            end
        end


    assign o_stop = (i_instruction == HALT )? 1'b1: 1'b0;


endmodule
