/*** IF (Instruction Fetch) Signals ***/
interface intf_if();
  logic IF_Stall, IF_Flush;
  logic IF_EXC_AdIF;
  logic IF_Exception_Stall;
  logic IF_Exception_Flush;
  logic IF_IsBDS;
  logic [31:0] IF_PCAdd4, IF_PC_PreExc, IF_PCIn, IF_PCOut, IF_Instruction;

  // ifid_stage
  modport ifid_in(
    input  IF_Flush,
    input  IF_Stall,
    // Control Signals
    input  IF_Instruction,
    // Data Signals
    input  IF_PCAdd4,
    input  IF_PCOut,
    input  IF_IsBDS
  );
endinterface
