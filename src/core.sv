// The processor
module core (
  // from board
  input  logic CLK, RST,
  // from I-Memory
  input logic [31:0] Instruction,
  // from D-Memory
  input logic [31:0] ReadDataOriginal,

  // to I-Memory
  output logic [31:0] PC,
  // to D-Memory
  output logic [31:0] ALUResult,    // address from ALU
  output logic [31:0] WriteData,    // data from register file
  output logic        MemReadEnable,
  output logic        MemWriteEnable,
  output logic [3:0]  MemByteEnable    // 4-bit Write, one for each byte in word.
);

  /*** Constant ***/
  `define PCIncrAmt   4
  `define PCInit      0

  /*** parse instruction ***/
  wire [5:0]  OpCode      = Instruction[31:26];
  wire [4:0]  Rs          = Instruction[25:21];
  wire [4:0]  Rt          = Instruction[20:16];
  wire [4:0]  Rd          = Instruction[15:11];
  wire [5:0]  Funct       = Instruction[5:0];
  wire [15:0] Immediate   = Instruction[15:0];
  wire [25:0] JumpAddress = Instruction[25:0];
  wire [4:0]  Shamt       = Instruction[10:6];

  /*** Register File ***/
  wire [31:0] RegReadData1;
  wire [31:0] RegReadData2;

  /*** internal signals ***/
  wire [31:0] ID.PCBranchOut;
  wire [31:0] IF.PCSrcOut;
  wire [4:0]  RegDstOut;
  wire [31:0] MemtoRegOut;
  wire [31:0] ExtImmOut;
  wire [31:0] SL2ForPCBranchOut;
  wire [31:0] ALUSrcOut;
  wire [31:0] ReadDataProcessed;

  /*** MEM (Memory) Signals ***/
  wire M_Stall;
  wire M_Stall_Controller;

  /*** wire init ***/
  wire [31:0] WriteDataPre = RegReadData2;

  /*** IF (Instruction Fetch) Signals ***/
  IF intf_if();

  /*** ID (Instruction Decode) Signals ***/
  ID intf_id();

  /*** EX (Execute) Signals ***/
  wire EX_ALU_Stall, EX_Stall;
  // wire [1:0] EX_RsFwdSel, EX_RtFwdSel;
  // wire EX_Link;
  // wire [1:0] EX_LinkRegDst;
  // wire EX_ALUSrcImm;
  wire [4:0] EX_ALUOp;
  wire EX_EXC_Ov;


  /*** Other Signals ***/
  wire [7:0] ID_DP_Hazards, HAZ_DP_Hazards;


  /***
   block modules
  ***/
  program_counter #(.INIT(`PCInit)) program_counter(CLK, RST, IF.PCSrcOut, PC);
  register_file register_file(
    CLK, ID.RegWrite,
    // read reg num1, 2, write reg num
    ID.Rs, ID.Rt, RegDstOut,
    // write data
    MemtoRegOut,
    // read data
    RegReadData1, RegReadData2
  );
  alu alu(
    // input
    CLK, RST,
    EX_Stall,
    EX_ALUOp,
    Shamt,
    RegReadData1, ALUSrcOut, // A, B
    // output
    ALUResult,
    EX_EXC_Ov,
    EX_ALU_Stall
  );
  controller controller(
    .ID         (ID.controller),
    .IF_Flush   (IF.IF_Flush),
    .DP_Hazards (ID_DP_Hazards)
  );
  /*** Hazard and Forward Control Unit ***/
  hazard_controller hazard_controller(
    // input
    EX_ALU_Stall,
    // output
    EX_Stall
  );
  /*** Condition Compare Unit ***/
  Compare Compare (
    .A    (RegReadData1),
    .B    (RegReadData2),
    .EQ   (ID.CmpEQ),
    .GZ   (ID.CmpGZ),
    .LZ   (ID.CmpLZ),
    .GEZ  (ID.CmpGEZ),
    .LEZ  (ID.CmpLEZ)
  );
  /*** TODO: Data Memory Controller ***/
  memory_controller data_memory_controller (
    .CLK           (CLK),
    .RST           (RST),
    .DataIn        (WriteDataPre),
    .Address       (ALUResult),
    .MReadData     (ReadDataOriginal),
    .MemRead       (ID.MemRead),
    .MemWrite      (ID.MemWrite),
    .DataMem_Ack   (1'b0),
    .Byte          (ID.MemByte),
    .Half          (ID.MemHalf),
    .SignExtend    (ID.MemSignExtend),
    .KernelMode    (1'b1),
    // .ReverseEndian (M_ReverseEndian),
    .LLSC          (ID.LLSC),
    .ERET          (ID.Eret),
    // .Left          (M_Left),
    // .Right         (M_Right),
    .M_Exception_Stall (1'b0),
    .IF_Stall      (1'b0),
    .DataOut       (ReadDataProcessed),
    .MWriteData    (WriteData),
    .ByteEnable    (MemByteEnable),
    .ReadEnable    (MemReadEnable),
    .WriteEnable   (MemWriteEnable),
    .M_Stall       (M_Stall_Controller)
    // .EXC_AdEL      (M_EXC_AdEL),
    // .EXC_AdES      (M_EXC_AdES)
  );


  /***
   stages
  ***/
  /*** Instruction Fetch -> Instruction Decode Stage Register ***/
  ifid_stage ifid_stage (
    .CLK             (CLK),
    .RST             (RST),
    .IF              (IF.ifid_in),
    .ID              (ID.ifid_out)
  );
  /*** Instruction Decode -> Execute Pipeline Stage ***/
  idex_stage idex_stage (
      .CLK               (CLK),
      .RST               (RST),
      .ID                (ID.idex_in),
      // Hazard & Forwarding
      .ID_WantRsByEX     (ID_DP_Hazards[3]),
      .ID_NeedRsByEX     (ID_DP_Hazards[2]),
      .ID_WantRtByEX     (ID_DP_Hazards[1]),
      .ID_NeedRtByEX     (ID_DP_Hazards[0]),

      .EX_Stall          (EX_Stall),
      .EX_ALUOp          (EX_ALUOp)
  );


  /***
   common modules
  ***/
  mux4 #(32) pc_src(IF.PCAdd4, ID.PCJumpAddress, ID.PCBranchOut, RegReadData1, ID.PCSrc, IF.PCSrcOut);
  mux2 #(5)  reg_dst(ID.Rt, ID.Rd, ID.RegDst, RegDstOut);
  mux2 #(32) alu_src(RegReadData2, ExtImmOut, ID.ALUSrc, ALUSrcOut);
  mux2 #(32) mem_to_reg(ALUResult, ReadDataProcessed, ID.MemtoReg, MemtoRegOut);

  adder #(32) pc_plus4(PC, `PCIncrAmt, IF.PCAdd4);
  adder #(32) pc_branch(ID.PCAdd4, SL2ForPCBranchOut, ID.PCBranchOut);

  sign_or_zero_extender ext_imm(ID.Immediate, ID.SignExtend, ExtImmOut);
  sl2 sl2_for_pc_branch(ExtImmOut, SL2ForPCBranchOut);

endmodule
