/*** EX (Execute) Signals ***/
interface intf_ex();
  logic Stall;

  // control signals
  logic [4:0] ALUOp;

  // for branch logic
  logic [31:0] ExtImmOut;
  logic [4:0]  Rd;
  logic [4:0]  Shamt;

  // for register-file
  logic [31:0] ReadData1, ReadData2;

  modport idex_out(
    output ExtImmOut,
    output Rd,
    output Shamt,

    output ReadData1,
    output ReadData2
  );

  modport exmem_in(
  );
endinterface
