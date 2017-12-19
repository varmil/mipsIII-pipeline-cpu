// NOTE: minimum implementation

/*** MEMORY Signals ***/
interface intf_mem();
  logic Stall;
  logic StallController; // output from D-Memory

  // control signals
  logic Trap;
  logic TrapCond;
  logic LLSC;
  logic MemRead;
  logic MemWrite;
  logic MemHalf;
  logic MemByte;
  logic MemSignExtend;
  logic RegWrite;
  logic MemtoReg;

  // EX - MEM
  logic [31:0] ALUResult;
  logic [31:0] ReadData2;
  logic [4:0]  RegDstOut;

  // MEM -WB
  logic [31:0] MemReadData;

  modport exmem_out(
    // control signals
    output Trap,
    output TrapCond,
    output LLSC,
    output MemRead,
    output MemWrite,
    output MemHalf,
    output MemByte,
    output MemSignExtend,
    output RegWrite,
    output MemtoReg,

    output ALUResult,
    output ReadData2,
    output RegDstOut
  );

  modport memwb_in(
    input ALUResult,
    input RegDstOut,
    input MemReadData
  );
endinterface
