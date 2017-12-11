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
  output logic [31:0] ALUOut,    // address from ALU
  output logic [31:0] WriteData, // data from register file
  output logic MemRead,
  output logic MemWrite
);

  /*** Constant ***/
  `define PCIncrAmt   4

  /*** parse instruction ***/
  logic [5:0]  OpCode    = Instr[31:26];
  logic [4:0]  Rs        = Instr[25:21];
  logic [4:0]  Rt        = Instr[20:16];
  logic [4:0]  Rd        = Instr[15:11];
  logic [5:0]  Funct     = Instr[5:0];
  logic [15:0] Immediate = Instr[15:0];

  /*** Datapath ***/
  logic [1:0] PCSrc   ;
  logic Link          ;
  logic ALUSrc        ;
  logic Movc          ;
  logic Trap          ;
  logic TrapCond      ;
  logic RegDst        ;
  logic LLSC          ;
  // logic MemRead       ;
  // logic MemWrite      ;
  logic MemHalf       ;
  logic MemByte       ;
  logic MemSignExtend ;
  logic RegWrite      ;
  logic MemtoReg      ;

  /*** ALU Operations ***/
  logic [4:0]  ALUOp;
  logic [4:0]  Shamt;
  logic [31:0] ALUResult;

  /*** Register File ***/
  logic [31:0] RegReadData1;
  logic [31:0] RegReadData2;

  /*** internal signals ***/
  logic [31:0] PCPlus4Out;
  logic [31:0] PCBranchOut;
  logic [31:0] PCSrcOut;
  logic [4:0]  RegDstOut;
  logic [31:0] MemtoRegOut;
  logic [31:0] ExtImmOut;
  logic [31:0] SL2ForPCBranchOut;
  logic [31:0] ALUSrcOut;




  /*** assignment for memory ***/
  assign ALUOut = ALUResult;
  assign WriteData = RegReadData2;




  /*** blocks ***/
  program_counter program_counter(CLK, PCSrcOut, PC);
  register_file register_file(
    CLK, RegWrite,
    // read reg num1, 2, write reg num
    Rs, Rt, RegDstOut,
    // write data
    MemtoRegOut,
    // read data
    RegReadData1, RegReadData2
  );
  alu alu(
    ALUOp, Shamt,
    // input
    RegReadData1, ALUSrcOut,
    // output
    ALUResult
  );
  controller controller(
    // instruction input
    OpCode, Funct, Rs, Rt,
    // Datapath output
    PCSrc         ,
    Link          ,
    ALUSrc        ,
    Movc          ,
    Trap          ,
    TrapCond      ,
    RegDst        ,
    LLSC          ,
    MemRead       ,
    MemWrite      ,
    MemHalf       ,
    MemByte       ,
    MemSignExtend ,
    RegWrite      ,
    MemtoReg      ,
    // ALU Operations output
    ALUOp
  );




  /*** common modules ***/
  mux2 #(32) pc_src(PCPlus4Out, PCBranchOut, PCSrc[0], PCSrcOut);
  mux2 #(5)  reg_dst(Rt, Rd, RegDst, RegDstOut);
  mux2 #(32) alu_src(RegReadData2, ExtImmOut, ALUSrc, ALUSrcOut);
  mux2 #(32) mem_to_reg(ALUResult, ReadData, MemtoReg, MemtoRegOut);

  adder #(32) pc_plus4(PC, PCIncrAmt, PCPlus4Out);
  adder #(32) pc_branch(PCPlus4Out, SL2ForPCBranchOut, PCBranchOut);

  sign_extender ext_imm(Immediate, ExtImmOut);
  sl2 sl2_for_pc_branch(ExtImmOut, SL2ForPCBranchOut);

endmodule
