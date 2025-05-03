module top (
    input   wire clk_100MHz ,
    input   wire i_rst_n    , 
    input   wire i_rx       ,
    output  wire o_tx       
);
    // Pipeline parameters
    localparam  NB_DATA_32      = 32                ;
    localparam  NB_ADDR         = 5                 ;

    // UART parameters
    localparam  NB_DATA_8       = 8                 ;
    localparam  NB_STOP         = 16                ;
    localparam  NB_5            = 5                 ;
    localparam  NB_STATES       = 4                 ;
    localparam  NB_ID_EX        = 144               ;                                         
    localparam  NB_EX_MEM       = 32                ;                                         
    localparam  NB_MEM_WB       = 48                ;                                         
    localparam  NB_WB_ID        = 40                ;                                         
    localparam  NB_CONTROL      = 24                ;       

    // Baudrate parameters
    localparam  BAUD_RATE       = 19200             ;
    localparam  CLK_FREQ        = 45_000_000       ; //! Frecuencia del reloj
    localparam  OVERSAMPLING    = 16                ; //! Oversampling

    wire clk_45MHz;
    wire clk;

    // Baudrate_generator 
    wire tick;  //! Tick signal for the UART
    // Rx
    wire [NB_DATA_8-1:0] data_Rx2Interface;
    wire rxDone;
    // Tx
    wire [NB_DATA_8-1:0] data_Interface2Tx;
    wire txDone;
    wire tx_start;
    // wire [NB_DATA_8-1:0] tx;
    wire tx;    
    // Uart Interface - pipeline
    wire we;
    wire [NB_DATA_32-1:0] instruction;
    wire halt;
    wire start;

    // Pipeline
    wire                            i_end                     ; //! End of the program HAY QUE VER COMO SALE DEL PIPELINE

    //ID_EX
    wire        [NB_DATA_32 -1 : 0] reg_DA                    ; //! Register A
    wire        [NB_DATA_32 -1 : 0] reg_DB                    ; //! Register B
    wire        [6     -1 : 0]      opcode                    ; //! Opcode
    wire        [NB_5  -1 : 0]      rs                        ; //! rs
    wire        [NB_5  -1 : 0]      rt                        ; //! rt
    wire        [NB_5  -1 : 0]      rd                        ; //! rd
    wire        [NB_5  -1 : 0]      shamt                     ; //! shamt
    wire        [6     -1 : 0]      funct                     ; //! funct
    wire        [16    -1 : 0]      immediate                 ; //! immediate
    wire        [NB_DATA_32 -1 : 0] addr2jump                 ; //! jump address
    wire        [NB_DATA_32 -1 : 0] ALUresult                 ; //! ALU result                                      
    wire        [NB_DATA_32 -1 : 0] data2mem                  ; //! Memory data
    wire        [NB_DATA_8-1: 0]      dataAddr                ; //! Memory address 
    wire                            memWriteDebug             ;                                                                 
    wire        [NB_DATA_32  -1: 0] write_dataWB2ID           ; //! Write data
    wire        [NB_5   -1: 0]      reg2writeWB2ID            ; //! Register to write
    wire                            write_enable              ; //! Write enable                                                
    wire                            jump                      ; //! Jump
    wire                            branch                    ; //! Branch
    wire                            regDst                    ; //! RegDst
    wire                            mem2Reg                   ; //! MemToReg
    wire                            memRead                   ; //! MemRead
    wire                            memWrite                  ; //! MemWrite
    wire                            inmediate_flag            ; //! Inmediate flag
    wire                            sign_flag                 ; //! Sign flag
    wire                            regWrite                  ; //! RegWrite
    wire        [2     -1 : 0]      aluSrc                    ; //! ALU source
    wire        [2     -1 : 0]      width                     ; //! ALU operation
    wire        [2     -1 : 0]      aluOp                     ; //! ALU operation                                      
    wire        [2     -1 : 0]      fwA                       ; //! Forward A
    wire        [2     -1 : 0]      fwB                       ; //! Forward B

    wire [NB_ID_EX   -1 : 0] concatenated_data_ID_EX    ; 
    wire [NB_EX_MEM  -1 : 0] concatenated_data_EX_MEM   ;
    wire [NB_MEM_WB  -1 : 0] concatenated_data_MEM_WB   ;
    wire [NB_WB_ID   -1 : 0] concatenated_data_WB_ID    ; 
    wire [NB_CONTROL -1 : 0] concatenated_data_CONTROL  ;
    

    assign clk = clk_45MHz;
    //assign clk = clk_100MHz;

    clk_wiz_0 clk_wz_inst(
        .reset(!i_rst_n),
        .locked(),
        .clk_in1(clk_100MHz),
        .clk_out1(clk_45MHz)
    );

   
    wire [31:0] inst_addr_from_interface;
    debug_unit #(
        .NB_DATA(NB_DATA_8),
        .NB_STOP(NB_STOP),
        .NB_32(NB_DATA_32),
        .NB_5(NB_5),
        .NB_STATES(NB_STATES),
        .NB_ID_EX(NB_ID_EX),
        .NB_EX_MEM(NB_EX_MEM),
        .NB_MEM_WB(NB_MEM_WB),
        .NB_WB_ID(NB_WB_ID),
        .NB_CONTROL(NB_CONTROL)
    ) debug_unit_inst (
        .clk                (clk),
        .i_rx               (data_Rx2Interface),
        .i_rxDone           (rxDone), 
        .i_txDone           (txDone),
        .i_rst_n            (i_rst_n),
        .o_tx_start         (tx_start),
        .o_data             (data_Interface2Tx),
        .i_end              (i_end), 
        .o_instruction      (instruction),   
        .o_instruction_address(inst_addr_from_interface), 
        .o_valid              (we),
        .o_step               (halt),
        .o_start              (start),
        .i_concatenated_data_ID_EX  (concatenated_data_ID_EX  ), 
        .i_concatenated_data_EX_MEM (concatenated_data_EX_MEM ),
        .i_concatenated_data_MEM_WB (concatenated_data_MEM_WB ),
        .i_concatenated_data_WB_ID  (concatenated_data_WB_ID  ), 
        .i_concatenated_data_CONTROL(concatenated_data_CONTROL)
        
    );
    wire aux_halt;
    assign aux_halt = ~halt;

    MIPS MIPS_inst (
        .clk                    (clk)                           ,
        .i_reset                (start)                     , // Aca entra el start de la interfaz que indica cuando el reset se tiene que poner en 1
        .i_we_IF                (we)                     , // Aca entra el o_valid de la interfaz
        .i_instruction_data     (instruction)          , // Aca entra el o_instruction de la interfaz
        .i_halt                 (aux_halt)                     , // Aca entra el o_step de la interfaz
        .i_instruction_addr     (inst_addr_from_interface),
        .o_jump                 (jump          ),
        .o_branch               (branch        ),
        .o_regDst               (regDst        ),
        .o_mem2reg              (mem2Reg       ),
        .o_memRead              (memRead       ),
        .o_memWrite             (memWrite      ),
        .o_immediate_flag       (inmediate_flag),
        .o_sign_flag            (sign_flag     ),
        .o_regWrite             (regWrite      ),
        .o_aluSrc               (aluSrc        ),
        .o_width                (width         ),
        .o_aluOp                (aluOp         ),
        .o_addr2jump            (addr2jump),
        .o_reg_DA               (reg_DA   ),
        .o_reg_DB               (reg_DB   ),
        .o_opcode               (opcode   ),
        .o_func                 (funct       ),
        .o_shamt                (shamt       ),
        .o_rs                   (rs       ),
        .o_rd                   (rd    ),
        .o_rt                   (rt    ),
        .o_immediate            (immediate),
        .o_ALUresult            (ALUresult),
        .o_fwA                  (fwA),         
        .o_fwB                  (fwB),
        .o_data2mem             (data2mem),
        .o_dataAddr             (dataAddr),
        .o_write_dataWB2ID      (write_dataWB2ID),
        .o_reg2writeWB2ID       (reg2writeWB2ID), 
        .o_write_enable         (write_enable),
        .o_memWriteDebug        (memWriteDebug),
        .o_end                  (i_end)
    );

    assign o_tx = tx;

    assign concatenated_data_ID_EX = {
        reg_DA    , // 32 bits
        reg_DB    , // 32 bits
        opcode    , // 6 bits
        rs        , // 5 bits
        rt        , // 5 bits
        rd        , // 5 bits
        shamt     , // 5 bits
        funct     , // 6 bits
        immediate , // 16 bits
        addr2jump   // 32 bits
    }; // 144 bits
    assign concatenated_data_EX_MEM = {
        ALUresult // 32 bits
    }; // 32 bits
    assign concatenated_data_MEM_WB = {
        data2mem  , // 32 bits
        dataAddr  ,  // 8 bits
        memWriteDebug  ,
        7'b0000000
    }; // 48 bits
    assign concatenated_data_WB_ID = {
        write_dataWB2ID   , // 32 bits
        reg2writeWB2ID    , // 5 bits
        write_enable      ,
        2'b00
    }; // 40 bits
    assign concatenated_data_CONTROL = {
        jump              , // 1 bit
        branch            , // 1 bit
        regDst            , // 1 bit
        mem2Reg           , // 1 bit
        memRead           , // 1 bit  
        memWrite          , // 1 bit
        inmediate_flag    , // 1 bit
        sign_flag         , // 1 bit
        regWrite          , // 1 bit
        aluSrc            , // 2 bits
        width             , // 2 bits
        aluOp             , // 2 bits
        fwA               , // 2 bits
        fwB               , // 2 bits
        5'b00000
    }; // 24 bits



    uart #(
        .NB_DATA(NB_DATA_8),
        .NB_STOP(NB_STOP),
        .BAUD_RATE(BAUD_RATE),
        .CLK_FREQ(CLK_FREQ),
        .OVERSAMPLING(OVERSAMPLING)
    ) uart_inst (
        .clk(clk),
        .i_reset(i_rst_n),
        .o_Rx2debug(data_Rx2Interface),
        .i_debug2Tx(data_Interface2Tx),
        .tx_start(tx_start),
        .o_tx(tx),
        .o_rxdone(rxDone),
        .i_rx(i_rx),
        .o_txDone(txDone)
    );






endmodule