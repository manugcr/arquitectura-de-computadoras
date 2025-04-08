module DataMemory
#(
    parameter NB_DATA = 32,
    parameter NB_ADDR = 8

)(
    input   wire                    clk                             ,
    input   wire                    i_reset                         ,
    input   wire                    i_halt                          ,
    input   wire   [4:0]            i_reg2write                     , //! o_write_reg from instruction_execute
    input   wire   [NB_DATA-1:0]    i_result                        , //! o_result from instruction_execute
    //input   wire   [NB_DATA-1:0]    i_aluOP                         , //! opcode NO LO USO
    input   wire   [1:0]            i_width                         , //! width
    input   wire                    i_sign_flag                     , //! sign flag || 1 = signed, 0 = unsigned
    input   wire                    i_mem2reg                       ,
    //input   wire                    i_memRead                       ,
    input   wire                    i_memWrite                      , //! Si 1 -> STORE || escribo en memoria
    input   wire                    i_regWrite                      ,
    //input   wire   [1:0]            i_aluSrc                        ,
    //input   wire                    i_jump                          ,
    input   wire   [NB_DATA-1:0]    i_data4Mem                      , //! src data for store ops



    output wire   [NB_DATA-1:0]    o_reg_read                       , //! data from memory 
    output wire   [NB_DATA-1:0]    o_ALUresult                      , //! alu result
    output wire   [4:0]            o_reg2write                      , //! o_write_reg from execute (rd or rt)

    // ctrl signals
    output wire                    o_mem2reg                        , //! 0-> guardo el valor de leído || 1-> guardo valor de alu
    output wire                    o_regWrite                       , //! writes the value

    output  wire [31:0]            o_data2mem                       , //
    output  wire [7 :0]            o_dataAddr                       ,  //
    output  wire                   o_memWrite

    
);
    reg  [NB_DATA-1:0] data2mem, masked_reg_read;
    wire [NB_DATA-1:0] reg_read;
    
    wire writeEnable;
    //wire []

    //! mask data
    always @(*) begin : mask
        data2mem = 0;
        case (i_width)
            2'b00: begin
                // byte
                data2mem = !i_sign_flag ?    {{24{i_data4Mem[7]}}    , i_data4Mem[7:0]}     : //unsigned
                                             {{24{1'b0}}             , i_data4Mem[7:0]}     ; //signed

                masked_reg_read = !i_sign_flag ?     
                                                    {{24{reg_read[7]}}    , reg_read[7:0]}  : //unsigned
                                                    {{24{1'b0}}           , reg_read[7:0]}  ; //signed
            end
            2'b01: begin
                // half word
                data2mem = !i_sign_flag ?    {{16{i_data4Mem[15]}}   , i_data4Mem[15:0]}    : //unsigned
                                             {{16{1'b0}}             , i_data4Mem[15:0]}    ; //signed

                masked_reg_read = !i_sign_flag ?     
                                            {{24{reg_read[15]}}    , reg_read[15:0]}        : //unsigned
                                            {{24{1'b0}}            , reg_read[15:0]}        ; //signed
            end
            2'b10: begin
                // word
                data2mem = i_data4Mem[31:0]                                                 ; //signed

                masked_reg_read = reg_read                                                  ;
            end
            default: begin
                // ERRORRRRRRRRR
                data2mem = 0;
            end
        endcase
    end

    MEMWB #(
        .NB_DATA(NB_DATA)
    ) memwb_sreg(
        .clk         (clk),
        .i_reset     (i_reset),
        .i_halt      (i_halt),
        .i_reg_read  (masked_reg_read),
        .i_result    (i_result),
        .i_reg2write (i_reg2write),
        .i_mem2reg   (i_mem2reg),
        .i_regWrite  (i_regWrite),
        .o_reg_read  (o_reg_read),
        .o_ALUresult (o_ALUresult),
        .o_reg2write (o_reg2write),
        .o_mem2reg   (o_mem2reg),
        .o_regWrite  (o_regWrite)
    );

    assign writeEnable = i_memWrite                                                         ;
    assign o_data2mem  = data2mem                                                           ;
    assign o_dataAddr  = i_result[7:0]                                                      ;
    assign o_memWrite  = i_memWrite                                                         ;

    //! data memory
    RAM #(
        .NB_DATA(32),   // limita 256 addrs
        .NB_ADDR(8)     // 8 bits
    ) DataMemoryRAM (
        .clk        (clk        ),
        .i_write_enable (writeEnable),
        .i_data     (data2mem   ),
        .i_addr_w   (i_result[7:0]   ),
        .o_data     (reg_read   )
    );

endmodule
