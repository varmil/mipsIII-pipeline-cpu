/*** ID (Instruction Decode) Signals ***/
interface intf_id();
  /*** MIPS Instruction and Components (ID Stage) ***/
  logic [31:0] ID_Instruction;
  wire  [5:0]  OpCode = ID_Instruction[31:26];
  wire  [4:0]  Rs = ID_Instruction[25:21];
  wire  [4:0]  Rt = ID_Instruction[20:16];
  wire  [4:0]  Rd = ID_Instruction[15:11];
  wire  [5:0]  Funct = ID_Instruction[5:0];
  wire  [15:0] Immediate = ID_Instruction[15:0];
  wire  [25:0] JumpAddress = ID_Instruction[25:0];
  wire  [2:0]  Cp0_Sel = ID_Instruction[2:0];

  logic ID_Stall;
  logic [1:0] ID_RsFwdSel, ID_RtFwdSel;
  logic ID_NextIsDelay;
  logic ID_CanErr, ID_ID_CanErr, ID_EX_CanErr, ID_M_CanErr;
  logic ID_KernelMode;
  logic ID_ReverseEndian;
  logic ID_EXC_Sys, ID_EXC_Bp, ID_EXC_RI;
  logic ID_Exception_Stall;
  logic ID_Exception_Flush;
  logic ID_PCSrc_Exc;
  logic [31:0] ID_ExceptionPC;
  logic [31:0] ID_PCAdd4;
  logic [31:0] ID_ReadData1_RF, ID_ReadData1_End;
  logic [31:0] ID_ReadData2_RF, ID_ReadData2_End;
  logic [31:0] CP0_RegOut;
  wire  [29:0] ID_SignExtImm = (SignExtend & Immediate[15]) ? {14'h3FFF, Immediate} : {14'h0000, Immediate};
  wire  [31:0] ID_ImmLeftShift2 = {ID_SignExtImm[29:0], 2'b00};
  wire  [31:0] ID_JumpAddress = {ID_PCAdd4[31:28], JumpAddress[25:0], 2'b00};
  logic [31:0] ID_BranchAddress;
  logic [31:0] ID_RestartPC;
  logic ID_IsBDS;
  logic ID_IsFlushed;

  // Controller
  logic SignExtend;
  logic Mfc0, Mtc0, Eret;
  logic [4:0] ALUOp;
  // Datapath
  logic [1:0] PCSrc;
  logic Link;
  logic ALUSrcImm;
  logic Trap, TrapCond;
  logic RegDst, LLSC, MemRead, MemWrite, MemHalf, MemByte, MemSignExtend, RegWrite, MemtoReg;

  // Compare
  logic CmpEQ, CmpGZ, CmpLZ, CmpGEZ, CmpLEZ;

  // ifid_stage
  modport ifid_out(
    output ID_Instruction,
    output ID_PCAdd4,
    output ID_RestartPC,
    output ID_IsBDS,
    output ID_IsFlushed
  );

  // idex_stage
  modport idex_in(
    input  ID_Exception_Flush,
    input  ID_Stall,
    // Control Signals
    input  ID_Link,
    input  ID_ALUSrcImm,
    input  ID_RegDst,
    input  ID_LLSC,
    input  ID_ALUOp,
    input  ID_MemRead,
    input  ID_MemWrite,
    input  ID_MemHalf,
    input  ID_MemByte,
    input  ID_MemSignExtend,
    input  ID_RegWrite,
    input  ID_MemtoReg,
    input  ID_ReverseEndian,
    // Hazard & Forwarding
    input  Rs,
    input  Rt,
    // Exception Control/Info
    input  ID_KernelMode,
    input  ID_RestartPC,
    input  ID_IsBDS,
    input  ID_Trap,
    input  ID_TrapCond,
    input  ID_EX_CanErr,
    input  ID_M_CanErr,
    // Data Signals
    input  ID_ReadData1_End,
    input  ID_ReadData2_End,
    input  ID_SignExtImm // ID_Rd, ID_Shamt included here
  );

  // IF_Flush and DP_Hazards are the rest wire
  modport controller(
    // input ID_Stall,
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
