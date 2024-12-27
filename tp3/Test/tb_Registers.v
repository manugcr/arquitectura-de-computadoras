
module tb_Registers;
    reg [4:0] ReadRegister1, ReadRegister2, WriteRegister;
    reg [31:0] WriteData;
    reg RegWrite, Clock;
    wire [31:0] ReadData1, ReadData2, V0, V1;

    Registers uut (
        .ReadRegister1(ReadRegister1),
        .ReadRegister2(ReadRegister2),
        .WriteRegister(WriteRegister),
        .WriteData(WriteData),
        .RegWrite(RegWrite),
        .Clock(Clock),
        .ReadData1(ReadData1),
        .ReadData2(ReadData2),
        .V0(V0),
        .V1(V1)
    );

    // Generación del reloj
    initial Clock = 0;
    always #5 Clock = ~Clock;

    // Estímulos
    initial begin
        // Inicialización
        RegWrite = 0;
        WriteRegister = 0;
        WriteData = 0;
        ReadRegister1 = 0;
        ReadRegister2 = 0;

        // Escritura en registros
        #10;
        RegWrite = 1; WriteRegister = 5'b00001; WriteData = 32'hA5A5A5A5; // Escribe en $1
        #10;
        RegWrite = 1; WriteRegister = 5'b00010; WriteData = 32'h5A5A5A5A; // Escribe en $2
        #10;
        RegWrite = 1; WriteRegister = 5'b00011; WriteData = 32'hDEADBEEF; // Escribe en $3
        #10;
        RegWrite = 0; // Detiene la escritura

        // Lectura de registros
        ReadRegister1 = 5'b00001; // Lee $1
        ReadRegister2 = 5'b00010; // Lee $2
        #10;

        // Finalización
        $finish;
    end

endmodule
