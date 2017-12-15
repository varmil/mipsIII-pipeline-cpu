module board (
  input logic CLK, RST
);

  logic [31:0] PC;
  logic [31:0] Instr;

  logic [31:0] ReadAddress;
  logic [31:0] WriteData;
  logic [31:0] ReadData;
  logic MemReadEnable, MemWriteEnable;
  logic [3:0] MemByteEnable;

  core core(
    CLK, RST,
    Instr,
    ReadData,
    PC,
    ReadAddress,
    WriteData,
    MemReadEnable,
    MemWriteEnable,
    MemByteEnable
  );
  instruction_memory #(32) instruction_memory(PC, Instr);
  data_memory #(32) data_memory(
    CLK,
    ReadAddress,
    WriteData,
    MemWriteEnable,
    MemReadEnable,
    MemByteEnable,

    ReadData
  );

endmodule // board
