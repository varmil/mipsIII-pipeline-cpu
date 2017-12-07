// The processor
module core (
  // from board
  input  logic CLK, RST,
  // from I-Memory
  input logic [31:0] Instr,
  // from D-Memory
  input logic [31:0] ReadData,

  // to I-Memory
  output logic [31:0] PC,
  // to D-Memory
  output logic [31:0] ALUOut,    // address
  output logic [31:0] WriteData, // data
  output logic MemWrite
);

  // TODO: internal signals
  logic [31:0] PCPlus4Out;

  // TODO: blocks
  alu alu();
  controller controller();
  program_counter program_counter();
  register_file register_file();

  // TODO: common modules
  mux2 #(32) pc_src();
  mux2 #(5)  reg_dst();
  mux2 #(32) alu_src();
  mux2 #(32) mem_to_reg();

  adder #(32) pc_plus4(PC, 4, PCPlus4Out);
  adder #(32) pc_branch();

  sl2 sl2_for_pc_branch();

endmodule
