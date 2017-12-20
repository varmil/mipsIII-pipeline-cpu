// NOTE: RegDst names EX_RtRd. Impl -- see https://github.com/grantae/mips32r1_core/blob/master/mips32r1/Processor.v#L525-L532

// The processor
module core (
  // from board
  input  logic CLK, RST,
  // from I-Memory
  input logic [31:0] Instruction,
  // from D-Memory
  input logic [31:0] ReadDataOriginal,

  // to I-Memory
  output logic [31:0] PCForMem,
  // to D-Memory
  output logic [31:0] DataMemAddress,    // address from ALU
  output logic [31:0] WriteData,         // data from register file
  output logic        MemReadEnable,
  output logic        MemWriteEnable,
  output logic [3:0]  MemByteEnable    // 4-bit Write, one for each byte in word.
);

  /*** Constant ***/
  `define PCIncrAmt   4
  `define PCInit      0

  /*** IF (Instruction Fetch) Signals ***/
  intf_if IF();
  assign IF.Instruction = (IF.Stall) ? 32'h0000_0000 : Instruction;
  assign PCForMem = IF.PCOut;

  /*** ID (Instruction Decode) Signals ***/
  intf_id ID();

  /*** EX (Execute) Signals ***/
  intf_ex EX();

  /*** Memory Signals ***/
  intf_mem MEM();
  assign DataMemAddress = MEM.ALUResult;

  /*** Write Back Signals ***/
  intf_wb WB();

  /*** Other Signals ***/
  wire [7:0] ID_DP_Hazards, HAZ_DP_Hazards;


  /***
   block modules
  ***/
  program_counter #(.INIT(`PCInit)) program_counter(
    CLK, RST,
    IF.PCSrcOut,
    IF.PCOut
  );
  register_file register_file(
    CLK, WB.RegWrite,
    // read reg num1, 2, write reg num
    ID.Rs, ID.Rt, WB.RegDstOut,
    // write data
    WB.MemtoRegOut,
    // read data
    ID.ReadData1, ID.ReadData2
  );
  alu alu(
    // input
    CLK, RST,
    EX.Stall,
    EX.ALUOp,
    EX.Shamt,
    EX.ReadData1, EX.ALUSrcOut, // A, B
    // output
    EX.ALUResult,
    EX.ExcOv,
    EX.ALUStall
  );
  controller controller(
    .ID         (ID.controller)
    // .IF_Flush   (IF.IF_Flush),
    // .DP_Hazards (ID_DP_Hazards)
  );
  /*** Hazard and Forward Control Unit ***/
  hazard_controller hazard_controller(
    // input
    EX.ALUStall,
    // output
    EX.Stall
  );
  /*** Condition Compare Unit ***/
  Compare Compare (
    .A    (ID.ReadData1),
    .B    (ID.ReadData2),
    .EQ   (ID.CmpEQ),
    .GZ   (ID.CmpGZ),
    .LZ   (ID.CmpLZ),
    .GEZ  (ID.CmpGEZ),
    .LEZ  (ID.CmpLEZ)
  );
  /*** TODO: Data Memory Controller ***/
  memory_controller data_memory_controller (
    .CLK           (CLK),
    .RST           (RST),
    .DataIn        (MEM.ReadData2),
    .Address       (MEM.ALUResult),
    .MReadData     (ReadDataOriginal),
    .MemRead       (MEM.MemRead),
    .MemWrite      (MEM.MemWrite),
    .DataMem_Ack   (1'b0),
    .Byte          (MEM.MemByte),
    .Half          (MEM.MemHalf),
    .SignExtend    (MEM.MemSignExtend),
    .KernelMode    (1'b1),
    // .ReverseEndian (M_ReverseEndian),
    .LLSC          (MEM.LLSC),
    .ERET          (ID.Eret),
    .M_Exception_Stall (1'b0),
    .IF_Stall      (1'b0),
    .DataOut       (MEM.MemReadData),
    .MWriteData    (WriteData),
    .ByteEnable    (MemByteEnable),
    .ReadEnable    (MemReadEnable),
    .WriteEnable   (MemWriteEnable),
    .M_Stall       (MEM.StallController)
    // .EXC_AdEL      (M_EXC_AdEL),
    // .EXC_AdES      (M_EXC_AdES)
  );


  /***
   stages
  ***/
  /*** Instruction Fetch -> Instruction Decode Stage Register ***/
  ifid_stage ifid_stage (
    .CLK             (CLK),
    .RST             (RST),
    .IF              (IF.ifid_in),
    .ID              (ID.ifid_out)
  );
  /*** Instruction Decode -> Execute Pipeline Stage ***/
  idex_stage idex_stage (
    .CLK               (CLK),
    .RST               (RST),
    .ID                (ID.idex_in),
    .EX                (EX.idex_out)
    // Hazard & Forwarding
    // .ID_WantRsByEX     (ID_DP_Hazards[3]),
    // .ID_NeedRsByEX     (ID_DP_Hazards[2]),
    // .ID_WantRtByEX     (ID_DP_Hazards[1]),
    // .ID_NeedRtByEX     (ID_DP_Hazards[0])
  );
  /*** Execute -> Memory Pipeline Stage ***/
  exmem_stage exmem_stage (
    .CLK               (CLK),
    .RST               (RST),
    .EX                (EX.exmem_in),
    .MEM               (MEM.exmem_out)
  );
  /*** Memory -> Write Back Pipeline Stage ***/
  memwb_stage memwb_stage (
    .CLK               (CLK),
    .RST               (RST),
    .MEM               (MEM.memwb_in),
    .WB                (WB.memwb_out)
  );


  /***
   common modules
  ***/
  mux4 #(32) pc_src(IF.PCAdd4, ID.PCJumpAddress, ID.PCBranchOut, ID.ReadData1, ID.PCSrc, IF.PCSrcOut);
  mux2 #(5)  reg_dst(EX.Rt, EX.Rd, EX.RegDst, EX.RegDstOut);
  mux2 #(32) alu_src(EX.ReadData2, EX.ExtImmOut, EX.ALUSrcImm, EX.ALUSrcOut);
  mux2 #(32) mem_to_reg(WB.ALUResult, WB.MemReadData, WB.MemtoReg, WB.MemtoRegOut);

  adder #(32) pc_plus4(IF.PCOut, `PCIncrAmt, IF.PCAdd4);
  adder #(32) pc_branch(ID.PCAdd4, ID.SL2OutForPCBranch, ID.PCBranchOut);

  sign_or_zero_extender ext_imm(ID.Immediate, ID.SignExtend, ID.ExtImmOut);
  sl2 sl2_for_pc_branch(ID.ExtImmOut, ID.SL2OutForPCBranch);

endmodule
