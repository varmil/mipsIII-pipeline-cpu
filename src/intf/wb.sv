// NOTE: minimum implementation

/*** Write Back Signals ***/
interface intf_wb();
  wire Stall;

  // control signals
  logic RegWrite;
  logic MemtoReg;

  // EX- MEM
  logic [31:0] ReadData2;

  // EX - MEM - WB
  logic [31:0] ALUResult;
  logic [4:0]  RegDstOut;

  // .MEM - WB
  logic [31:0] MemReadData;

  // internal wire
  logic [31:0] MemtoRegOut; // == WB_WriteData

  modport memwb_out(
    input Stall,

    // control signals
    output RegWrite,
    output MemtoReg,
    // data
    output ALUResult,
    output RegDstOut,
    output MemReadData
  );


  modport hazard_controller(
    input RegWrite,
    input RegDstOut
  );

endinterface
