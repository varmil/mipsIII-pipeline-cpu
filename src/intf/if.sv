// NOTE: minimum implementation

/*** IF (Instruction Fetch) Signals ***/
interface intf_if();
  logic Stall;
  logic Flush;

  // IF - ID
  logic [31:0] Instruction;
  logic [31:0] PCAdd4;

  // internal wire
  logic [31:0] PCSrcOut;
  logic [31:0] PCOut;

  // ifid_stage
  modport ifid_in(
    input  Stall,
    input  Flush,

    // Control Signals
    input  Instruction,
    // Data Signals
    input  PCAdd4
  );
endinterface
