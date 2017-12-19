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

  /*** Controller ***/
  wire SignExtend    ;
  wire Mfc0          ;
  wire Mtc0          ;
  wire Eret          ;

  /*** Datapath ***/
  wire [1:0] PCSrc   ;
  wire Link          ;
  wire ALUSrc        ;
  wire Trap          ;
  wire TrapCond      ;
  wire RegDst        ;
  wire LLSC          ;
  wire MemRead       ;
  wire MemWrite      ;
  wire MemHalf       ;
  wire MemByte       ;
  wire MemSignExtend ;
  wire RegWrite      ;
  wire MemtoReg      ;

  /*** Register File ***/
  wire [31:0] RegReadData1;
  wire [31:0] RegReadData2;

  /*** for branch operations ***/
  wire CmpEQ, CmpGZ, CmpLZ, CmpGEZ, CmpLEZ;

  /*** internal signals ***/
  wire [31:0] PCPlus4Out;
  wire [31:0] PCBranchOut;
  wire [31:0] PCSrcOut;
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
  wire [31:0] PCJumpAddress = { PCPlus4Out[31:28], JumpAddress[25:0], 2'b00 };
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
  program_counter #(.INIT(`PCInit)) program_counter(CLK, RST, PCSrcOut, PC);
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
    .EQ   (CmpEQ),
    .GZ   (CmpGZ),
    .LZ   (CmpLZ),
    .GEZ  (CmpGEZ),
    .LEZ  (CmpLEZ)
  );
  /*** TODO: Data Memory Controller ***/
  memory_controller data_memory_controller (
    .CLK           (CLK),
    .RST           (RST),
    .DataIn        (WriteDataPre),
    .Address       (ALUResult),
    .MReadData     (ReadDataOriginal),
    .MemRead       (MemRead),
    .MemWrite      (MemWrite),
    .DataMem_Ack   (1'b0),
    .Byte          (MemByte),
    .Half          (MemHalf),
    .SignExtend    (MemSignExtend),
    .KernelMode    (1'b1),
    // .ReverseEndian (M_ReverseEndian),
    .LLSC          (LLSC),
    .ERET          (Eret),
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
      // .EX_Link           (EX_Link),
      // .EX_LinkRegDst     (EX_LinkRegDst),
      // .EX_ALUSrcImm      (EX_ALUSrcImm),
      .EX_ALUOp          (EX_ALUOp)
      // .EX_Movn           (EX_Movn),
      // .EX_Movz           (EX_Movz),
      // .EX_LLSC           (EX_LLSC),
      // .EX_MemRead        (EX_MemRead),
      // .EX_MemWrite       (EX_MemWrite),
      // .EX_MemByte        (EX_MemByte),
      // .EX_MemHalf        (EX_MemHalf),
      // .EX_MemSignExtend  (EX_MemSignExtend),
      // .EX_Left           (EX_Left),
      // .EX_Right          (EX_Right),
      // .EX_RegWrite       (EX_RegWrite),
      // .EX_MemtoReg       (EX_MemtoReg),
      // .EX_ReverseEndian  (EX_ReverseEndian),
      // .EX_Rs             (EX_Rs),
      // .EX_Rt             (EX_Rt),
      // .EX_WantRsByEX     (EX_WantRsByEX),
      // .EX_NeedRsByEX     (EX_NeedRsByEX),
      // .EX_WantRtByEX     (EX_WantRtByEX),
      // .EX_NeedRtByEX     (EX_NeedRtByEX),
      // .EX_KernelMode     (EX_KernelMode),
      // .EX_RestartPC      (EX_RestartPC),
      // .EX_IsBDS          (EX_IsBDS),
      // .EX_Trap           (EX_Trap),
      // .EX_TrapCond       (EX_TrapCond),
      // .EX_EX_CanErr      (EX_EX_CanErr),
      // .EX_M_CanErr       (EX_M_CanErr),
      // .EX_ReadData1      (EX_ReadData1_PR),
      // .EX_ReadData2      (EX_ReadData2_PR),
      // .EX_SignExtImm     (EX_SignExtImm),
      // .EX_Rd             (EX_Rd),
      // .EX_Shamt          (EX_Shamt)
  );


  /***
   common modules
  ***/
  mux4 #(32) pc_src(PCPlus4Out, PCJumpAddress, PCBranchOut, RegReadData1, PCSrc, PCSrcOut);
  mux2 #(5)  reg_dst(Rt, Rd, RegDst, RegDstOut);
  mux2 #(32) alu_src(RegReadData2, ExtImmOut, ALUSrc, ALUSrcOut);
  mux2 #(32) mem_to_reg(ALUResult, ReadDataProcessed, MemtoReg, MemtoRegOut);

  adder #(32) pc_plus4(PC, `PCIncrAmt, PCPlus4Out);
  adder #(32) pc_branch(PCPlus4Out, SL2ForPCBranchOut, PCBranchOut);

  sign_or_zero_extender ext_imm(Immediate, SignExtend, ExtImmOut);
  sl2 sl2_for_pc_branch(ExtImmOut, SL2ForPCBranchOut);

endmodule
