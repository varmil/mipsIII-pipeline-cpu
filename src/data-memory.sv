// NOTE: if memory width is 16bit, then ir is concated 2 blocks (16+16)

module data_memory #(parameter WIDTH = 32) (
  input logic CLK,
  input logic [31:0] Address,
  input logic [31:0] WriteData,
  input logic WriteEnable,
  input logic ReadEnable,
  input logic [3:0] ByteEnable,

  output logic [31:0] ReadData
);

  parameter ADDRESS_DIV = WIDTH / 8; // Address is a byte unit
  parameter DEPTH = 64;

  logic [31:0] RAM [DEPTH - 1:0];
  logic [31:0] addressBlock;
  assign addressBlock = Address / ADDRESS_DIV; // ex) addr=8 means block=2 (= 2bits right shift)

  // ByteEnable mask
  wire [7:0] MemByte3 = (ByteEnable[3]) ? WriteData[31:24] : RAM[addressBlock][31:24];
	wire [7:0] MemByte2 = (ByteEnable[2]) ? WriteData[23:16] : RAM[addressBlock][23:16];
	wire [7:0] MemByte1 = (ByteEnable[1]) ? WriteData[15:8] : RAM[addressBlock][15:8];
	wire [7:0] MemByte0 = (ByteEnable[0]) ? WriteData[7:0] : RAM[addressBlock][7:0];

  // Initialize all to zero
  integer i;
  initial begin
    for (i = 0; i < DEPTH; i = i + 1) begin
      RAM[i] <= 0;
    end
  end

  // WRITE (always write 1 word)
  always @ (posedge CLK) begin
    if (WriteEnable) begin
      RAM[addressBlock] <= { MemByte3, MemByte2, MemByte1, MemByte0 };
    end
  end

  // READ (byte/half mask is done with Memory Controller)
  assign ReadData = (ReadEnable) ? RAM[addressBlock] : 'Z;

endmodule // data_memory
