// NOTE: minimum implementation

/*** EX (Execute) Signals ***/
interface intf_ex();
  wire Stall;
  wire Flush;  // from CP0

  // control signals
  logic [4:0] ALUOp;
  logic Link;
  logic ALUSrcImm;
  logic Trap;
  logic TrapCond;
  logic RegDst;
  logic LLSC;
  logic MemRead;
  logic MemWrite;
  logic MemHalf;
  logic MemByte;
  logic MemSignExtend;
  logic RegWrite;
  logic MemtoReg;

  // for branch logic
  logic [4:0] Rs;
  logic [4:0] Rt;
  logic [4:0] Rd;
  logic [4:0] Shamt;
  logic [4:0] RegDstOut; // RtRd, is address for WB register-file address

  // Hazard (Stall and Forwarding)
  logic WantRsByEX;
  logic NeedRsByEX;
  logic WantRtByEX;
  logic NeedRtByEX;

  // data signals
  logic [31:0] ReadData1, ReadData2;
  logic [31:0] ExtImmOut;
  logic [31:0] ALUResult;

  // core internal wire
  logic [31:0] ALUSrcOut;
  logic ALUStall;
  logic ExcOv;
  logic [1:0] LinkRegDst;
  logic [1:0] RsFwdSel;
  logic [1:0] RtFwdSel;
  logic [31:0] RsFwdOut;
  logic [31:0] RtFwdLinkOut;

  modport idex_out(
    input Stall,

    // control signals
    output ALUOp,
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

    output LinkRegDst,
    output Rs,
    output Rt,
    output Rd,
    output Shamt,

    // Data Signals
    output ReadData1,
    output ReadData2,
    output ExtImmOut,
    // Hazard (Stall and Forwarding)
    output WantRsByEX,
    output NeedRsByEX,
    output WantRtByEX,
    output NeedRtByEX
  );

  modport exmem_in(
    input Stall,
    input Flush,

    // control signals
    input Trap,
    input TrapCond,
    input LLSC,
    input MemRead,
    input MemWrite,
    input MemHalf,
    input MemByte,
    input MemSignExtend,
    input RegWrite,
    input MemtoReg,
    // data
    input ALUResult,
    input ReadData2,
    input RegDstOut
  );


  modport hazard_controller(
    input RegWrite,
    input RegDstOut,
    input Rs,
    input Rt,
    input Link,

    output RsFwdSel,
    output RtFwdSel
  );

endinterface
