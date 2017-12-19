/*** ID (Instruction Decode) Signals ***/
interface intf_id();
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

  logic ID_Stall;
  logic [1:0] ID_PCSrc;
  logic [1:0] ID_RsFwdSel, ID_RtFwdSel;
  logic ID_Link, ID_Movn, ID_Movz;
  logic ID_SignExtend;
  logic ID_LLSC;
  logic ID_RegDst, ID_ALUSrcImm, ID_MemWrite, ID_MemRead, ID_MemByte, ID_MemHalf, ID_MemSignExtend, ID_RegWrite, ID_MemtoReg;
  logic [4:0] ID_ALUOp;
  logic ID_Mfc0, ID_Mtc0, ID_Eret;
  logic ID_NextIsDelay;
  logic ID_CanErr, ID_ID_CanErr, ID_EX_CanErr, ID_M_CanErr;
  logic ID_KernelMode;
  logic ID_ReverseEndian;
  logic ID_Trap, ID_TrapCond;
  logic ID_EXC_Sys, ID_EXC_Bp, ID_EXC_RI;
  logic ID_Exception_Stall;
  logic ID_Exception_Flush;
  logic ID_PCSrc_Exc;
  logic [31:0] ID_ExceptionPC;
  logic ID_CP1, ID_CP2, ID_CP3;
  logic [31:0] ID_PCAdd4;
  logic [31:0] ID_ReadData1_RF, ID_ReadData1_End;
  logic [31:0] ID_ReadData2_RF, ID_ReadData2_End;
  logic [31:0] CP0_RegOut;
  logic ID_CmpEQ, ID_CmpGZ, ID_CmpLZ, ID_CmpGEZ, ID_CmpLEZ;
  wire  [29:0] ID_SignExtImm = (ID_SignExtend & Immediate[15]) ? {14'h3FFF, Immediate} : {14'h0000, Immediate};
  wire  [31:0] ID_ImmLeftShift2 = {ID_SignExtImm[29:0], 2'b00};
  wire  [31:0] ID_JumpAddress = {ID_PCAdd4[31:28], JumpAddress[25:0], 2'b00};
  logic [31:0] ID_BranchAddress;
  logic [31:0] ID_RestartPC;
  logic ID_IsBDS;
  logic ID_Left, ID_Right;
  logic ID_IsFlushed;

  // ifid_stage
  modport ifid_out(
    output Instruction,
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
    input  ID_RegDst,
    input  ID_ALUSrcImm,
    input  ID_ALUOp,
    input  ID_Movn,
    input  ID_Movz,
    input  ID_LLSC,
    input  ID_MemRead,
    input  ID_MemWrite,
    input  ID_MemByte,
    input  ID_MemHalf,
    input  ID_MemSignExtend,
    input  ID_Left,
    input  ID_Right,
    input  ID_RegWrite,
    input  ID_MemtoReg,
    input  ID_ReverseEndian,
    // Hazard & Forwarding
    input  ID_Rs,
    input  ID_Rt,
    input  ID_WantRsByEX,
    input  ID_NeedRsByEX,
    input  ID_WantRtByEX,
    input  ID_NeedRtByEX,
    // Exception Control/Info
    input  ID_KernelMode,
    input  ID_RestartPC,
    input  ID_IsBDS,
    input  ID_Trap,
    input  ID_TrapCond,
    input  ID_EX_CanErr,
    input  ID_M_CanErr,
    // Data Signals
    input  ID_ReadData1,
    input  ID_ReadData2,
    input  ID_SignExtImm // ID_Rd, ID_Shamt included here
  );

  // IF_Flush and DP_Hazards are the rest wire
  modport controller(
     input ID_Stall,

     // instruction input
     input OpCode,
     input Funct,
     input Rs,
     input Rt,
     // branch condition input
     input ID_CmpEQ,
     input ID_CmpGZ,
     input ID_CmpGEZ,
     input ID_CmpLZ,
     input ID_CmpLEZ,

     // some logic operation output
     output ID_SignExtend,
     output ID_Movn,
     output ID_Movz,
     output ID_Mfc0,
     output ID_Mtc0,
     output ID_Eret,

// TODO: sort for datapath15 - 0
     output ID_PCSrc,
     output ID_Link,
    //  output ID_CP1,
    //  output ID_CP2,
    //  output ID_CP3,
     output ID_Trap,
     output ID_TrapCond,
     output ID_EXC_Sys,
     output ID_EXC_Bp,
     output ID_EXC_RI,
     output ID_ID_CanErr,
     output ID_EX_CanErr,
     output ID_M_CanErr,
     output ID_NextIsDelay,
     output ID_RegDst,
     output ID_ALUSrcImm,
     output ID_ALUOp,
     output ID_LLSC,
     output ID_MemWrite,
     output ID_MemRead,
     output ID_MemByte,
     output ID_MemHalf,
     output ID_MemSignExtend,
     output ID_Left,
     output ID_Right,
     output ID_RegWrite,
     output ID_MemtoReg
  );
endinterface
