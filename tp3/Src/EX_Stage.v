module EX_Stage
#(
    parameter NB_DATA = 32
)
(
    input wire                  clk                             ,
    input wire                  i_rst_n                         ,
    input wire                  i_stall                         ,
    input wire                  i_halt                          ,
    input wire [4:0]            i_rt                            ,
    input wire [4:0]            i_rd                            ,

    input wire [NB_DATA-1:0]    i_reg_DA                        ,
    input wire [NB_DATA-1:0]    i_reg_DB                        ,

    input wire [NB_DATA-1:0]    i_immediate                     ,
    input wire [5 :0]           i_opcode                        ,
    input wire [4 :0]           i_shamt                         ,
    input wire [5 :0]           i_func                          ,
    input wire [15:0]           i_addr                          ,//jmp

    //ctrl unit
    input wire                  i_regDst                        , 
    input wire                  i_mem2Reg                       , 
    input wire                  i_memRead                       , 
    input wire                  i_memWrite                      , 
    input wire                  i_immediate_flag                , 
    input wire                  i_regWrite                      ,
    input wire [1:0]            i_aluSrc                        ,
    input wire [1:0]            i_aluOP                         ,
    input wire [1:0]            i_width                         ,
    input wire                  i_sign_flag                     ,
    //fwd unit
    input wire [1:0]            i_fw_a                          ,
    input wire [1:0]            i_fw_b                          ,
    input wire [NB_DATA-1:0]    i_output_MEMWB                  , //! result wb stage
    input wire [NB_DATA-1:0]    i_output_EXMEM                  , //! o_result 
    
    
    // ctrl signals
    output wire                  o_mem2reg                       ,
    output wire                  o_memWrite                      ,
    output wire                  o_regWrite                      ,
    //output wire                  o_jump                          ,

    output wire                  o_sign_flag                     ,
    output wire [1:0]            o_width                         ,
    output wire [4:0]            o_write_reg                     , //! EX/MEM.RegisterRd for control unit
    output wire [NB_DATA-1:0]    o_data4Mem                      ,
    output wire [NB_DATA-1:0]    o_result                        

);
    localparam [5:0]
                    ADD = 6'b100000                             ,
                    IDLE= 6'b111111                             ;

    localparam [2:1]
                ADDI    = 3'b000                                ,
                ANDI    = 3'b100                                ,
                ORI     = 3'b101                                ,
                XORI    = 3'b110                                ,
                SLTI    = 3'b010                                ,
                LUI     = 3'b111                                ;

    localparam [5:0] 
                JARL_TYPE   = 6'b001001                         ,
                R_TYPE_OP   = 6'b000000                         ,
                JAL_TYPE    = 6'b000011                         ;

    localparam [1:0]
                    LOAD_STORE = 2'b00                           ,
                    BRANCH     = 2'b01                           ,
                    R_TYPE     = 2'b10                           ,
                    I_TYPE     = 2'b11                           ;

    reg  [5:0]           opcode                                  ;
    reg  signed [NB_DATA-1:0]   alu_datoA, alu_datoB, data4Mem   ; //data4Mem_aux
    reg  [1:0]           aluOP                                   ;
    wire [NB_DATA-1:0]   alu_result                              ;

    //! state machine for alu
    always @(*) begin

        case(i_aluOP)
            LOAD_STORE: begin // load - store - jalr - jal type
                opcode = ADD                                    ; 
            end
            BRANCH: begin
                opcode = IDLE                                   ;
            end
            R_TYPE: begin
                // and
                opcode = i_func                                 ;
            end
            I_TYPE: begin
                // or
                opcode = i_opcode                               ;
            end
            default: begin
                // nop
                opcode= 6'b0                                    ;
            end
        endcase
    end

    //! mux to determine dato A.
    //!  For JAL or  JARL type there is no forwarding
    always @(*) begin
        case(i_fw_a)
            2'b00: begin
                // datoA = reg[rs]
                alu_datoA = i_reg_DA                            ;
            end
            2'b10: begin
                // datoA = datoB
                alu_datoA = i_output_MEMWB                      ;
            end
            2'b11: begin
                // datoA = datoB
                alu_datoA = i_output_EXMEM                      ;
            end
            default: begin
                // nop
                alu_datoA = 8'b0                                ;
            end
        endcase
    
        if((i_opcode == JAL_TYPE) || ((i_opcode== R_TYPE_OP) && (i_func == JARL_TYPE))) begin
            alu_datoA = i_reg_DA;
        end
    end


    //! mux to determine datoB. For JAL or JARL type there is no forwarding. 
    //! For immediate ops datoB = immediate value
    always @(*) begin
        case(i_fw_b)
            2'b00: begin
                // datoB = reg[rt]
                alu_datoB = i_reg_DB                            ;
            end
            2'b10: begin
                // datoB = datoB
                alu_datoB = i_output_MEMWB                      ;
            end
            2'b11: begin
                // datoB = datoB
                alu_datoB = i_output_EXMEM                      ;
            end
            default: begin
                // nop
                alu_datoB = 8'b0                                ;
            end
        endcase
        data4Mem = alu_datoB;

        if((i_opcode == JAL_TYPE) || ((i_opcode== R_TYPE_OP) && (i_func == JARL_TYPE))) begin
            alu_datoB = i_reg_DB;
        end

        if(i_immediate_flag) alu_datoB = i_immediate            ;

    end
    
   
    EXMEM #(
        .NB_DATA(NB_DATA),
        .NB_REG()
    ) exmem_sreg (
        .clk         (clk),
        .i_rst_n     (i_rst_n),
        .i_halt      (i_halt),

        .i_mem2reg   (i_mem2reg),
        .i_memRead   (i_memRead),
        .i_memWrite  (i_memWrite),
        .i_regWrite  (i_regWrite),
        .i_aluSrc    (i_aluSrc),
        .i_aluOP     (i_aluOP),
        .i_width     (i_width),
        .i_sign_flag (i_sign_flag),
        .i_result    (alu_result),
        .i_data4Mem  (i_dataB),     // para SW: este dato se va a la MEM

        .i_regDst    (i_regDst),
        .i_rt        (i_rt),
        .i_rd        (i_rd),

        .o_mem2reg   (o_mem2reg),
        .o_memWrite  (o_memWrite),
        .o_regWrite  (o_regWrite),
        .o_result    (o_result),
        .o_data4Mem  (o_data4Mem),
        .o_write_reg (o_write_reg),
        .o_width     (o_width),
        .o_sign_flag (o_sign_flag)
    );

    //! alu instance
    ALU #(
        .NB_DATA    (NB_DATA),
        .NB_OP      (6)
    ) alu1
    (
        .i_op       (opcode),
        .i_datoA    (alu_datoA),
        .i_datoB    (alu_datoB),
        .i_shamt    (i_shamt),
        .o_resultALU(alu_result)
    );


endmodule
