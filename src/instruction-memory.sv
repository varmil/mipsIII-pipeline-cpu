// NOTE: if memory width is 16bit, then Instr is concated 2 blocks (16+16)
module instruction_memory #(parameter WIDTH = 32) (
  input logic CLK, RST,
  input logic [31:0] address,
  input logic ReadEnable,

  output logic Ack,
  output logic [31:0] Instr
);

  parameter ADDRESS_DIV = WIDTH / 8; // address is a byte unit

  logic [WIDTH-1:0] RAM [63:0];
  logic [31:0] addressBlock;
  assign addressBlock = address / ADDRESS_DIV;

  initial begin
    // $readmemh("src/memfile.dat", RAM);
    $readmemh("testcase/jal/jal.data", RAM);
  end

  // ACK (NOTE: Ack after 1 cycle because R/W operation is completed immediately)
  always @ (posedge CLK) begin
    if (RST) begin
      Ack <= 1'b0;
    end
    else begin
      if (ReadEnable) begin
        Instr <= RAM[addressBlock];
        Ack <= 1'b1;
      end

      if (Ack) Ack <= 1'b0;
    end
  end

  // assign Instr = (ReadEnable) ? RAM[addressBlock] : 'Z;
endmodule
