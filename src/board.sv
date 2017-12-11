// NOTE: MemRead is not used at now

module board (
  input logic CLK, RST
);

  logic [31:0] PC;
  logic [31:0] Instr;

  logic [31:0] ReadAddress;
  logic [31:0] WriteData;
  logic [31:0] ReadData;
  logic MemRead, MemWrite;

  always @ (negedge RST) begin
    if (RST) begin
      // Reset Vector
      PC <= 0;
    end
  end

  core core(
    CLK, RST,
    Instr,
    ReadData,
    PC,
    ReadAddress,
    WriteData,
    MemRead,
    MemWrite
  );
  instruction_memory #(32) instruction_memory(PC, Instr);
  data_memory #(32) data_memory(
    CLK,
    ReadAddress,
    WriteData,
    MemWrite,
    ReadData
  );

endmodule // board
