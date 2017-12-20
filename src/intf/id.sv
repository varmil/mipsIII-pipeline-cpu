// NOTE: minimum implementation

/*** ID (Instruction Decode) Signals ***/
interface intf_id();
  logic Stall;
  logic Flush; //  == ID_Exception_Flush

  // .ID - EX (control signals)
  logic SignExtend;
  logic Mfc0, Mtc0, Eret;
  logic [4:0] ALUOp;
  logic [1:0] PCSrc;
  logic Link;
  logic ALUSrcImm;
  logic Trap, TrapCond;
  logic RegDst;
  logic LLSC;
  logic MemRead, MemWrite, MemHalf, MemByte, MemSignExtend;
  logic RegWrite;
  logic MemtoReg;

  /*** MIPS Instruction and Components (ID Stage) ***/
  logic [31:0] Instruction;
  wire  [5:0]  OpCode = Instruction[31:26];
  wire  [4:0]  Rs = Instruction[25:21];
  wire  [4:0]  Rt = Instruction[20:16];
  wire  [4:0]  Rd = Instruction[15:11];
  wire  [5:0]  Funct = Instruction[5:0];
  wire  [15:0] Immediate = Instruction[15:0];
  wire  [25:0] JumpAddress = Instruction[25:0];
  wire  [2:0]  Cp0_Sel = Instruction[2:0];

  // logic ID_Exception_Stall;
  // logic [1:0] ID_RsFwdSel, ID_RtFwdSel;
  // logic ID_NextIsDelay;
  // logic ID_CanErr, ID_ID_CanErr, ID_EX_CanErr, ID_M_CanErr;
  // logic ID_KernelMode;
  // logic ID_ReverseEndian;
  // logic ID_EXC_Sys, ID_EXC_Bp, ID_EXC_RI;
  // logic ID_PCSrc_Exc;
  // logic [31:0] ID_ExceptionPC;
  // logic [31:0] CP0_RegOut;
  // logic [31:0] ID_RestartPC;
  // logic ID_IsBDS;
  // logic ID_IsFlushed;

  // Compare
  logic CmpEQ, CmpGZ, CmpLZ, CmpGEZ, CmpLEZ;

  // TODO: Implement for Hazard, now simply using ReadData
  // logic [31:0] ID_ReadData1_RF, ID_ReadData1_End;
  // logic [31:0] ID_ReadData2_RF, ID_ReadData2_End;
  logic [31:0] ReadData1, ReadData2;

  // core internal wire
  logic [31:0] PCAdd4;
  logic [31:0] SL2OutForPCBranch;
  logic [31:0] PCBranchOut;
  wire  [31:0] PCJumpAddress = {PCAdd4[31:28], JumpAddress[25:0], 2'b00};

  // wire init
  logic [31:0] ExtImmOut; // ID_Rd, ID_Shamt included here
  // wire  [29:0] ID_SignExtImm = (SignExtend & Immediate[15]) ? {16'hFFFF, Immediate} : {16'h0000, Immediate};
  // wire  [31:0] ID_ImmLeftShift2 = {ID_SignExtImm[29:0], 2'b00};



  // ifid_stage
  modport ifid_out(
    input  Stall,

    output Instruction,
    output PCAdd4
  );

  // idex_stage
  modport idex_in(
    input  Stall,
    input  Flush,

    // Control Signals
    input  ALUOp,
    input  Link,
    input  ALUSrcImm,
    input  Trap,
    input  TrapCond,
    input  RegDst,
    input  LLSC,
    input  MemRead,
    input  MemWrite,
    input  MemHalf,
    input  MemByte,
    input  MemSignExtend,
    input  RegWrite,
    input  MemtoReg,
    // input  ID_ReverseEndian,

    // Hazard & Forwarding
    input  Rs,
    input  Rt,
    // Exception Control/Info
    // input  ID_KernelMode,
    // input  ID_RestartPC,
    // input  ID_IsBDS,

    // Data Signals
    input  ReadData1,
    input  ReadData2,
    input  ExtImmOut
  );

  // IF_Flush and DP_Hazards are the rest wire
  modport controller(
    // input Stall,
    // instruction input
    input OpCode,
    input Funct,
    input Rs,  // used to differentiate mfc0 and mtc0
    input Rt,  // used to differentiate bgez,bgezal,bltz,bltzal,teqi,tgei,tgeiu,tlti,tltiu,tnei
    // branch condition input
    input CmpEQ,
    input CmpGZ,
    input CmpGEZ,
    input CmpLZ,
    input CmpLEZ,

    // some logic operation output
    output SignExtend,
    output Mfc0,
    output Mtc0,
    output Eret,
    // datapath
    output PCSrc,
    output Link,
    output ALUSrcImm,
    output Trap,
    output TrapCond,
    output RegDst,
    output LLSC,
    output MemRead,
    output MemWrite,
    output MemHalf,
    output MemByte,
    output MemSignExtend,
    output RegWrite,
    output MemtoReg,
    // other
    //  output ID_EXC_Sys,
    //  output ID_EXC_Bp,
    //  output ID_EXC_RI,
    //  output ID_ID_CanErr,
    //  output ID_EX_CanErr,
    //  output ID_M_CanErr,
    //  output ID_NextIsDelay,
    output ALUOp
  );

endinterface
