module board (
  input logic CLK, RST
);

  // I-Memory
  logic [31:0] PC;
  logic InstrMemReadEnable;
  logic InstrMemAck;
  logic [31:0] Instr;

  // D-Memory
  logic [31:0] DataMemReadAddress;
  logic [31:0] DataMemWriteData;
  logic DataMemReadEnable, DataMemWriteEnable;
  logic [3:0] DataMemByteEnable;
  logic DataMemAck;
  logic [31:0] DataMemReadData;

  core core(
    CLK, RST,

    // from I-Memory
    InstrMemAck,
    Instr,
    // from D-Memory
    DataMemAck,
    DataMemReadData,

    // to I-Memory
    PC,
    InstrMemReadEnable,
    // to D-Memory
    DataMemReadAddress,
    DataMemWriteData,
    DataMemReadEnable,
    DataMemWriteEnable,
    DataMemByteEnable
  );

  instruction_memory #(32) i_memory(
    CLK, RST,
    PC,
    InstrMemReadEnable,

    InstrMemAck,
    Instr
  );

  data_memory #(32) d_memory(
    CLK, RST,
    DataMemReadAddress,
    DataMemWriteData,
    DataMemWriteEnable,
    DataMemReadEnable,
    DataMemByteEnable,

    DataMemAck,
    DataMemReadData
  );

endmodule // board
