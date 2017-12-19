/*** IF (Instruction Fetch) Signals ***/
interface intf_if();
  // exception
  logic IF_Stall, IF_Flush;
  // logic IF_EXC_AdIF;
  // logic IF_Exception_Stall;
  // logic IF_Exception_Flush;
  // logic IF_IsBDS;

  // PC wire
  logic [31:0] PCAdd4, /*IF_PC_PreExc,*/ IF_Instruction;
  logic [31:0] PCSrcOut;
  logic [31:0] PCOut;

  // ifid_stage
  modport ifid_in(
    input  IF_Stall,
    input  IF_Flush,
    // Control Signals
    input  IF_Instruction,
    // Data Signals
    input  PCAdd4,
    input  PCOut
    // input  IF_IsBDS
  );
endinterface
