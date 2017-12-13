// The processor
module core (
  // from board
  input  logic CLK, RST,
  // from I-Memory
  input logic [31:0] Instr,
  // from D-Memory
  input logic [31:0] ReadData,

  // to I-Memory
  output logic [31:0] PC,
  // to D-Memory
  output logic [31:0] ALUOut,    // address from ALU
  output logic [31:0] WriteData, // data from register file
  output logic MemRead,
  output logic MemWrite
);

  /*** Constant ***/
  `define PCIncrAmt   4
  `define PCInit      0

  /*** parse instruction ***/
  wire [31:0] Instruction;
  wire [5:0]  OpCode      = Instruction[31:26];
  wire [4:0]  Rs          = Instruction[25:21];
  wire [4:0]  Rt          = Instruction[20:16];
  wire [4:0]  Rd          = Instruction[15:11];
  wire [5:0]  Funct       = Instruction[5:0];
  wire [15:0] Immediate   = Instruction[15:0];
  wire [25:0] JumpAddress = Instruction[25:0];
  wire [4:0]  Shamt       = Instruction[10:6];

  /*** Controller ***/
  wire SignExtend    ;
  wire Movn          ;
  wire Movz          ;
  wire Mfc0          ;
  wire Mtc0          ;
  wire Eret          ;

  /*** Datapath ***/
  wire [1:0] PCSrc   ;
  wire Link          ;
  wire ALUSrc        ;
  wire Movc          ;
  wire Trap          ;
  wire TrapCond      ;
  wire RegDst        ;
  wire LLSC          ;
  // wire MemRead       ;
  // wire MemWrite      ;
  wire MemHalf       ;
  wire MemByte       ;
  wire MemSignExtend ;
  wire RegWrite      ;
  wire MemtoReg      ;

  /*** ALU Operations ***/
  wire [4:0]  ALUOp;
  wire [31:0] ALUResult;

  /*** Register File ***/
  wire [31:0] RegReadData1;
  wire [31:0] RegReadData2;

  /*** for branch operations ***/
  wire CmpEQ, CmpGZ, CmpLZ, CmpGEZ, CmpLEZ;

  /*** internal signals ***/
  wire [31:0] PCPlus4Out;
  wire [31:0] PCBranchOut;
  wire [31:0] PCSrcOut;
  wire [4:0]  RegDstOut;
  wire [31:0] MemtoRegOut;
  wire [31:0] ExtImmOut;
  wire [31:0] SL2ForPCBranchOut;
  wire [31:0] ALUSrcOut;

  /*** concat wire ***/
  wire [31:0] PCJumpAddress = { PCPlus4Out[31:28], JumpAddress[25:0], 2'b00 };

  /*** assignment ***/
  assign Instruction = Instr;
  assign ALUOut = ALUResult;
  assign WriteData = RegReadData2;


  /*** block modules ***/
  program_counter #(.INIT(`PCInit)) program_counter(CLK, RST, PCSrcOut, PC);
  register_file register_file(
    CLK, RegWrite,
    // read reg num1, 2, write reg num
    Rs, Rt, RegDstOut,
    // write data
    MemtoRegOut,
    // read data
    RegReadData1, RegReadData2
  );
  alu alu(
    ALUOp, Shamt,
    // input
    RegReadData1, ALUSrcOut,
    // output
    ALUResult
  );
  controller controller(
    // instruction input
    OpCode, Funct, Rs, Rt,
    // branch condition input
    CmpEQ, CmpGZ, CmpLZ, CmpGEZ, CmpLEZ,

    // some logic operation output
    SignExtend,
    Movn,
    Movz,
    Mfc0,
    Mtc0,
    Eret,
    // Datapath output
    PCSrc         ,
    Link          ,
    ALUSrc        ,
    Movc          ,
    Trap          ,
    TrapCond      ,
    RegDst        ,
    LLSC          ,
    MemRead       ,
    MemWrite      ,
    MemHalf       ,
    MemByte       ,
    MemSignExtend ,
    RegWrite      ,
    MemtoReg      ,
    // ALU Operations output
    ALUOp
  );
  /*** Condition Compare Unit ***/
  Compare Compare (
    .A    (RegReadData1),
    .B    (RegReadData2),
    .EQ   (CmpEQ),
    .GZ   (CmpGZ),
    .LZ   (CmpLZ),
    .GEZ  (CmpGEZ),
    .LEZ  (CmpLEZ)
  );
  /*** TODO: Data Memory Controller ***/
  memory_controller data_memory_controller (
    .CLK           (CLK),
    .RST           (RST),
    // .DataIn        (M_WriteData_Pre),
    // .Address       (M_ALUResult),
    // .MReadData     (DataMem_In),
    .MemRead       (MemRead),
    .MemWrite      (MemWrite),
    // .DataMem_Ack   (DataMem_Ack),
    .Byte          (MemByte),
    .Half          (MemHalf),
    .SignExtend    (MemSignExtend),
    // .KernelMode    (M_KernelMode),
    // .ReverseEndian (M_ReverseEndian),
    // .LLSC          (M_LLSC),
    // .ERET          (ID_Eret),
    // .Left          (M_Left),
    // .Right         (M_Right),
    // .M_Exception_Stall (M_Exception_Stall),
    // .IF_Stall      (IF_Stall),
    // .DataOut       (M_MemReadData),
    // .MWriteData    (DataMem_Out),
    // .WriteEnable   (DataMem_Write),
    // .ReadEnable    (DataMem_Read),
    // .M_Stall       (M_Stall_Controller),
    // .EXC_AdEL      (M_EXC_AdEL),
    // .EXC_AdES      (M_EXC_AdES)
  );


  /*** common modules ***/
  mux4 #(32) pc_src(PCPlus4Out, PCJumpAddress, PCBranchOut, RegReadData1, PCSrc, PCSrcOut);
  mux2 #(5)  reg_dst(Rt, Rd, RegDst, RegDstOut);
  mux2 #(32) alu_src(RegReadData2, ExtImmOut, ALUSrc, ALUSrcOut);
  mux2 #(32) mem_to_reg(ALUResult, ReadData, MemtoReg, MemtoRegOut);

  adder #(32) pc_plus4(PC, `PCIncrAmt, PCPlus4Out);
  adder #(32) pc_branch(PCPlus4Out, SL2ForPCBranchOut, PCBranchOut);

  sign_or_zero_extender ext_imm(Immediate, SignExtend, ExtImmOut);
  sl2 sl2_for_pc_branch(ExtImmOut, SL2ForPCBranchOut);

endmodule
