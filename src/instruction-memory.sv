// NOTE: if memory width is 16bit, then ir is concated 2 blocks (16+16)
module instruction_memory #(parameter WIDTH = 32) (
  input logic [31:0] address,
  output logic [31:0] ir
);

  parameter ADDRESS_DIV = WIDTH / 8; // address is a byte unit

  logic [WIDTH-1:0] RAM [63:0];
  logic [31:0] addressBlock;
  assign addressBlock = address / ADDRESS_DIV;

  initial begin
    // $readmemh("src/memfile.dat", RAM);
    $readmemh("testcase/memory/memory.data", RAM);
  end

  assign ir = RAM[addressBlock];
endmodule // instruction_memory
