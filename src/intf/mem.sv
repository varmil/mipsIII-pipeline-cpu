// NOTE: minimum implementation

/*** MEMORY Signals ***/
interface intf_mem();
  wire Stall;
  wire StallController; // output from D-Memory
  wire Flush;  // from CP0

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

  // EX- MEM
  logic [31:0] ReadData2;

  // EX - MEM - WB
  logic [31:0] ALUResult;
  logic [4:0]  RegDstOut;

  // .MEM - WB
  logic [31:0] MemReadData;


  modport exmem_out(
    input Stall,

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
    input Stall,
    input Flush,

    // control signals
    input RegWrite,
    input MemtoReg,
    // data
    input ALUResult,
    input RegDstOut,
    input MemReadData
  );


  modport hazard_controller(
    input RegWrite,
    input RegDstOut,
    input MemRead,
    input MemWrite
  );

endinterface
