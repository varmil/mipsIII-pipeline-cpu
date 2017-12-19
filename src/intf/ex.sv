/*** EX (Execute) Signals ***/
interface intf_ex();
  logic Stall;

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
  logic [4:0] Rd;
  logic [4:0] Shamt;

  // data signals
  logic [31:0] ReadData1, ReadData2;
  logic [31:0] ExtImmOut;

  modport idex_out(
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

    output Rd,
    output Shamt,

    // Data Signals
    output ReadData1,
    output ReadData2,
    output ExtImmOut
  );

  modport exmem_in(
    input ReadData2
  );
endinterface
