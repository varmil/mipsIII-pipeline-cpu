// NOTE: if memory width is 16bit, then ir is concated 2 blocks (16+16)
module data_memory #(parameter WIDTH = 32) (
  input logic CLK,
  input logic [31:0] Address,
  input logic [31:0] WriteData,
  input logic WriteEnable,
  output logic [31:0] ReadData
);

  parameter ADDRESS_DIV = WIDTH / 8; // Address is a byte unit
  parameter DEPTH = 64;

  logic [31:0] RAM [DEPTH - 1:0];
  logic [31:0] addressBlock;
  assign addressBlock = Address / ADDRESS_DIV;

  // Initialize all to zero
  integer i;
  initial begin
    for (i = 0; i < DEPTH; i = i + 1) begin
      RAM[i] <= 0;
    end
  end

  assign ReadData = RAM[addressBlock];

  always @ (posedge CLK) begin
    if (WriteEnable) begin
      RAM[addressBlock] <= WriteData;
    end
  end

endmodule // data_memory
