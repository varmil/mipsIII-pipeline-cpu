/*** IF (Instruction Fetch) Signals ***/
interface intf_if();
  // logic IF_Stall, IF_Flush;
  // logic IF_EXC_AdIF;
  // logic IF_Exception_Stall;
  // logic IF_Exception_Flush;
  // logic IF_IsBDS;
  logic [31:0] PCAdd4, IF_PC_PreExc, IF_Instruction;

  // core internal wire
  logic [31:0] PCSrcOut, IF_PCOut;

  // ifid_stage
  modport ifid_in(
    input  IF_Flush,
    input  IF_Stall,
    // Control Signals
    input  IF_Instruction,
    // Data Signals
    input  PCAdd4,
    input  IF_PCOut,
    input  IF_IsBDS
  );
endinterface
