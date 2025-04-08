module MIPS
(
    input wire          clk                 ,
    input wire          i_reset             ,
    input wire          i_we_IF             ,
    input wire [31:0]   i_instruction_data  ,
    input wire          i_halt              , 
    input wire [31:0]   i_inst_addr         ,

    output wire                 o_end,

    output wire [23:0]  o_Control_data,
    output wire [31:0]  o_EX_MEM_data,
    output wire [143:0] o_ID_EX_data,
    output wire [47:0]  o_MEM_WB_data,
    output wire [39:0]  o_WB_data,

    output wire [15:0]  PC_IF
);


   


    // P A R A M S
    localparam  NB_DATA = 32,
                NB_ADDR = 5 ;

    // step by step

    wire haltIF;

    // IF 2 ID
    wire [31:0]
                pcounterIF2ID       ,
                instructionIF2ID    ;

    wire [31:0]
                addr2jumpID2IF;
    
    // ID 2 EX

    wire stop;

    wire [4:0]
                rsID2EX,
                rtID2EX,
                rdID2EX;


    wire [NB_DATA-1:0]
                        datoAID2EX                          ,
                        datoBID2EX                          ,
                        immediateID2EX                      ;
    //ctrl out
    wire jumpID2EX, branchID2EX, regDstID2EX, mem2RegID2EX  , 
         memWriteID2EX, immediate_flagID2EX, sign_flagID2EX , 
         regWriteID2EX, memReadID2EX                        ;

    wire [5:0]
                opcodeID2EX                                 ,
                funcID2EX                                   ;

    wire [4:0]
                shamtID2EX                                  ;
    wire [1:0]
                aluSrcID2EX                                 , 
                widthID2EX                                  , 
                aluOpID2EX                                  ;
        
    // FU 2 EX
    parameter NB_FW = 2;
    wire [NB_FW-1 : 0]
                        fwB_FU2EX,
                        fwA_FU2EX;

    // EX 2 MEM
    //ctrl
    wire [1:0]
                aluSrcEX2MEM , 
                widthEX2MEM  ;
    
    wire    jumpEX2MEM, branchEX2MEM, regDstEX2MEM, mem2RegEX2MEM   , 
            memWriteEX2MEM, immediate_flagEX2MEM, sign_flagEX2MEM   , 
            regWriteEX2MEM, memReadEX2MEM                           ;

    wire [4:0] write_regEX2MEM;
    wire [NB_DATA-1:0] data4MemEX2MEM, resultALUEX2MEM;


    // MEM 2 WB
    wire [NB_DATA-1:0] reg_readMEM2WB, resultALUMEM2WB;
    wire [NB_ADDR-1:0] reg2writeMEM2WB;
    //ctrl
    wire mem2regMEM2WB, regWriteMEM2WB;

    // WB2ID
    wire [NB_DATA-1:0] write_dataWB2ID  ;
    wire [NB_ADDR-1:0] reg2writeWB2ID   ;
    wire               regWriteWB2ID    ; // write enable


    // HDU
    wire stall;
    wire [4:0] rsIF2ID;
    wire [4:0] rtIF2ID;

    wire [1:0] jumpType;

    wire [31:0] inst_addr_from_interface;
    wire [4 :0] aux_rdEX;
    assign inst_addr_from_interface = i_inst_addr;
    assign aux_rdEX = regDstID2EX ? rtID2EX : rdID2EX;


    Hazard Hazard_unit (
            // Inputs
        .i_ID_EX_RegisterRt (rtID2EX),//out decode
        .i_IF_ID_RegisterRs (rsIF2ID),//inst en pipeline.v//
        .i_IF_ID_RegisterRt (rtIF2ID),//inst en pipeline.v
        .i_ID_EX_MemRead    (memReadID2EX),
        .i_jumpType         (jumpType),
        .i_EX_RegisterRd    (aux_rdEX),
        .i_MEM_RegisterRd   (write_regEX2MEM),
        .i_WB_RegisterRd    (reg2writeMEM2WB),
        .i_EX_WB_Write      (regWriteID2EX), //regWriteEX2MEM
        .i_MEM_WB_Write     (regWriteEX2MEM ),
        .i_WB_WB_Write      (regWriteMEM2WB ),
        // Output   
        .o_stall            (stall)     // Signal to stall the pipeline
    );

    IF_Stage IF_inst (
        .clk            (clk),
        .i_reset        (i_reset),
        // ID
        .i_jump         (jumpID2EX),
        .i_we           (i_we_IF),  
        .i_addr2jump    (addr2jumpID2IF),  
        // uart
        .i_inst_data   (i_instruction_data ),  
        .i_inst_addr    (inst_addr_from_interface),
        .i_halt         (haltIF),
        .i_stall        (stall), // from HDU
        //out
        .o_instruction  (instructionIF2ID),
        .o_pcounter     (pcounterIF2ID)
    );
    
    assign rsIF2ID = instructionIF2ID[25:21];
    assign rtIF2ID = instructionIF2ID[20:16];
    
    ID_Stage #(
        .NB_DATA        (NB_DATA),
        .NB_ADDR        (NB_ADDR)
    ) ID_inst (
        .clk                      (clk ),
        .i_reset                  (i_reset),
        // IF
        .i_instruction            (instructionIF2ID ),
        .i_pcounter4              (pcounterIF2ID ),
        // WB
        .i_we_wb                  ( ),
        .i_we                     (regWriteWB2ID ),
        .i_wr_addr                (reg2writeWB2ID),
        .i_wr_data_WB             (write_dataWB2ID),

        .i_stall                  (stall || stop),
        .i_halt                   (i_halt ),
        //------------------------------------
        //out
        .o_rs                     (rsID2EX),
        .o_rt                     (rtID2EX),
        .o_rd                     (rdID2EX),
        .o_reg_DA                 (datoAID2EX),
        .o_reg_DB                 (datoBID2EX),
        .o_immediate              (immediateID2EX),
        .o_opcode                 (opcodeID2EX),
        .o_shamt                  (shamtID2EX),
        .o_func                   (funcID2EX ),
        //id-if
        .o_addr2jump              (addr2jumpID2IF),
        .o_jump_cases             (jumpType),
            //ctrl unit
        .o_jump                   (jumpID2EX), 
        .o_branch                 (branchID2EX), 
        .o_regDst                 (regDstID2EX), 
        .o_mem2Reg                (mem2RegID2EX), 
        .o_memRead                (memReadID2EX), 
        .o_memWrite               (memWriteID2EX ), 
        .o_immediate_flag         (immediate_flagID2EX), 
        .o_sign_flag              (sign_flagID2EX),
        .o_regWrite               (regWriteID2EX ),
        .o_aluSrc                 (aluSrcID2EX),
        .o_width                  (widthID2EX ),
        .o_aluOp                  (aluOpID2EX ),
        .o_stop                   (stop)

    );

    EX_Stage #(
        .NB_DATA(NB_DATA)
    ) EX_inst
    (
        .clk                             (clk),
        .i_reset                         (i_reset),
        .i_stall                         (stall),
        .i_halt                          (i_halt),
        .i_rt                            (rtID2EX),
        .i_rd                            (rdID2EX),
    
        .i_reg_DA                        (datoAID2EX),
        .i_reg_DB                        (datoBID2EX),
    
        .i_immediate                     (immediateID2EX ),
        .i_opcode                        (opcodeID2EX ),
        .i_shamt                         (shamtID2EX),
        .i_func                          (funcID2EX),
        .i_addr                          (),//jmp
    
        //ctrl unit
        .i_regDst                        (regDstID2EX ), 
        .i_mem2Reg                       (mem2RegID2EX), 
        .i_memRead                       (memReadID2EX), 
        .i_memWrite                      (memWriteID2EX), 
        .i_immediate_flag                (immediate_flagID2EX), 
        .i_regWrite                      (regWriteID2EX),
        .i_aluSrc                        (aluSrcID2EX ),
        .i_aluOP                         (aluOpID2EX),
        .i_width                         (widthID2EX),
        .i_sign_flag                     (sign_flagID2EX ),
        //fwd unit
        .i_fw_a                          (fwA_FU2EX),
        .i_fw_b                          (fwB_FU2EX),
        .i_output_MEMWB                  (write_dataWB2ID), //result wb stage
        .i_output_EXMEM                  (resultALUEX2MEM), // o_result 
        
        
        // ctrl signals
        .o_mem2reg                       (mem2RegEX2MEM),
        .o_memWrite                      (memWriteEX2MEM ),
        .o_regWrite                      (regWriteEX2MEM ),
        //.o_jump                          (),
    
        .o_sign_flag                     (sign_flagEX2MEM),
        .o_width                         (widthEX2MEM ),
        .o_write_reg                     (write_regEX2MEM), // EX/MEM.RegisterRd for control unit
        .o_data4Mem                      (data4MemEX2MEM ),
        .o_result                        (resultALUEX2MEM)
    
    );
    
    Forward #(
        .NB_ADDR(NB_ADDR),
        .NB_FW  (NB_FW)

    ) Forward_inst ( 
        .i_rs_IFID       (rsID2EX),
        .i_rt_IFID       (rtID2EX),

        .i_rd_IDEX       (write_regEX2MEM), //rd out EX
        .i_rd_EX_MEMWB   (reg2writeMEM2WB), //rd out WB

        .i_wr_WB         (regWriteEX2MEM),
        .i_wr_MEM        (regWriteMEM2WB),
        .o_fw_b          (fwB_FU2EX),
        .o_fw_a          (fwA_FU2EX)
    );

    DataMemory #(
        .NB_DATA(),
        .NB_ADDR()
    ) MEM_inst (
        .clk                             (clk),
        .i_reset                         (i_reset),
        .i_halt                          (i_halt),

        .i_reg2write                     (write_regEX2MEM), //! o_write_reg from instruction_execute
        .i_result                        (resultALUEX2MEM), //! o_result from instruction_execute
        .i_width                         (widthEX2MEM), //! width
        .i_sign_flag                     (sign_flagEX2MEM), //! sign flag || 1 = signed, 0 = unsigned
        .i_mem2reg                       (mem2RegEX2MEM),
        .i_memWrite                      (memWriteEX2MEM ), //! Si 1 -> STORE || escribo en memoria
        .i_regWrite                      (regWriteEX2MEM ),
        .i_data4Mem                      (data4MemEX2MEM ), //! src data for store ops
    
    
    
        .o_reg_read                      (reg_readMEM2WB ), //! data from memory 
        .o_ALUresult                     (resultALUMEM2WB), //! alu result
        .o_reg2write                     (reg2writeMEM2WB), //! o_write_reg from execute (rd or rt)
    
        // ctrl signals
        .o_mem2reg                       (mem2regMEM2WB), //! 0-> guardo el valor de leído || 1-> guardo valor de alu
        .o_regWrite                      (regWriteMEM2WB ),  //! writes the value

        //DU
        .o_data2mem                      (o_data2mem ),
        .o_dataAddr                      (o_dataAddr ),
        .o_memWrite                      (o_memWriteDebug)
    );
    
    WB_Stage #(
        .NB_DATA (NB_DATA),
        .NB_ADDR (NB_ADDR)
    ) WB_inst
    (
        .i_reg_read      (reg_readMEM2WB ),//! data from memory 
        .i_ALUresult     (resultALUMEM2WB),//! alu result
        .i_reg2write     (reg2writeMEM2WB),//! o_write_reg from execute (rd or rt)

        .i_mem2reg       (mem2regMEM2WB), //! 1-> guardo el valor de leído || 0-> guardo valor de alu
        .i_regWrite      (regWriteMEM2WB ), //! writes the value

        .o_write_data    (write_dataWB2ID), //! data2write
        .o_reg2write     (reg2writeWB2ID ), //! dst reg
        .o_regWrite      (regWriteWB2ID)  //!ctrl signal
    );

    // ctrl unit flags (ID)
    assign o_jump          = jumpID2EX          ;// revisar
    assign o_branch        = branchID2EX        ;
    assign o_regDst        = regDstID2EX        ;
    assign o_mem2reg       = mem2RegID2EX       ;
    assign o_memRead       = memReadID2EX       ;
    assign o_memWrite      = memWriteID2EX      ;
    assign o_immediate_flag= immediate_flagID2EX;
    assign o_sign_flag     = sign_flagID2EX     ;
    assign o_regWrite      = regWriteID2EX      ;
    assign o_aluSrc        = aluSrcID2EX        ;
    assign o_width         = widthID2EX         ;
    assign o_aluOp         = aluOpID2EX         ;

    // ID out
    assign o_addr2jump     = addr2jumpID2IF     ;//! ID 2 IF

    assign o_reg_DA        = datoAID2EX         ;
    assign o_reg_DB        = datoBID2EX         ;

    assign o_opcode        = opcodeID2EX        ;
    assign o_func          = funcID2EX          ;
    assign o_shamt         = shamtID2EX         ;

    assign o_rs            = rsID2EX            ;
    assign o_rd            = rdID2EX            ;
    assign o_rt            = rtID2EX            ;

    assign o_immediate     = immediateID2EX     ;

    // EX 2 MEM

    assign o_ALUresult     = resultALUEX2MEM    ;

    // fu2ex
    assign o_fwA           = fwA_FU2EX          ;
    assign o_fwB           = fwB_FU2EX          ;

    assign o_write_dataWB2ID= write_dataWB2ID   ;
    assign o_reg2writeWB2ID = reg2writeWB2ID    ;
    assign o_write_enable   = regWriteWB2ID     ;

    // program finishHHHHHH

    assign o_end = stop;
    assign haltIF = (i_halt || stop) ? 1 : 0;

        //FOR DEBUG IN GUI  

     assign o_ID_EX_data = {
        datoAID2EX    , // 32 bits
        datoBID2EX    , // 32 bits
        opcodeID2EX    , // 6 bits
        rsID2EX        , // 5 bits
        rtID2EX        , // 5 bits
        rdID2EX        , // 5 bits
        shamtID2EX     , // 5 bits
        funcID2EX     , // 6 bits
        immediateID2EX , // 16 bits
        addr2jumpID2IF   // 32 bits
    }; // 144 bits
    assign o_EX_MEM_data = {
        resultALUMEM2WB // 32 bits
    }; // 32 bits
    assign o_MEM_WB_data = {
        o_data2mem  , // 32 bits
        o_dataAddr  ,  // 8 bits
        o_memWriteDebug  ,
        7'b0000000
    }; // 48 bits
    assign o_WB_data = {
        write_dataWB2ID   , // 32 bits
        reg2writeWB2ID    , // 5 bits
        regWriteWB2ID      ,
        2'b00
    }; // 40 bits
    assign o_Control_data = {
        jumpID2EX              , // 1 bit
        branchID2EX            , // 1 bit
        regDstID2EX            , // 1 bit
        mem2RegID2EX           , // 1 bit
        memReadID2EX           , // 1 bit  
        memWriteID2EX          , // 1 bit
        immediate_flagID2EX    , // 1 bit
        sign_flagID2EX         , // 1 bit
        regWriteID2EX          , // 1 bit
        aluSrcID2EX            , // 2 bits
        widthID2EX             , // 2 bits
        aluOpID2EX             , // 2 bits
        fwA_FU2EX               , // 2 bits
        fwB_FU2EX               , // 2 bits
        5'b00000
    }; // 24 bits

 assign PC_IF = pcounterIF2ID[15:0];

endmodule
