module controller (
  intf_id.controller ID,
  output IF_Flush,
  output reg [7:0] DP_Hazards
);

  `include "parameters.sv"

  reg [15:0] Datapath;
  assign ID.PCSrc[0]      = Datapath[14];
  assign ID.Link          = Datapath[13];
  assign ID.ALUSrcImm     = Datapath[12];
  wire   Movc             = Datapath[11];
  assign ID.Trap          = Datapath[10];
  assign ID.TrapCond      = Datapath[9];
  assign ID.RegDst        = Datapath[8];
  assign ID.LLSC          = Datapath[7];
  assign ID.MemRead       = Datapath[6];
  assign ID.MemWrite      = Datapath[5];
  assign ID.MemHalf       = Datapath[4];
  assign ID.MemByte       = Datapath[3];
  assign ID.MemSignExtend = Datapath[2];
  assign ID.RegWrite      = Datapath[1];
  assign ID.MemtoReg      = Datapath[0];

  /*** Datapath ***
       Bit  Name          Description
       ------------------------------
       15:  PCSrc         (Instruction Type)
       14:                   11: Instruction is Jump to Register
                             10: Instruction is Branch
                             01: Instruction is Jump to Immediate
                             00: Instruction does not branch nor jump
       13:  Link          (Link on Branch/Jump)
       ------------------------------
       12:  ALUSrc        (ALU Source) [0=ALU input B is 2nd register file output; 1=Immediate value]
       11:  Movc          (Conditional Move)
       10:  Trap          (Trap Instruction)
       9 :  TrapCond      (Trap Condition) [0=ALU result is 0; 1=ALU result is not 0]
       8 :  RegDst        (Register File Target) [0=Rt field; 1=Rd field]
       ------------------------------
       7 :  LLSC          (Load Linked or Store Conditional)
       6 :  MemRead       (Data Memory Read)
       5 :  MemWrite      (Data Memory Write)
       4 :  MemHalf       (Half Word Memory Access)
       3 :  MemByte       (Byte size Memory Access)
       2 :  MemSignExtend (Sign Extend Read Memory) [0=Zero Extend; 1=Sign Extend]
       ------------------------------
       1 :  RegWrite      (Register File Write)
       0 :  MemtoReg      (Memory to Register) [0=Register File write data is ALU output; 1=Is Data Memory]
       ------------------------------
  */
  // Set the main datapath control signals based on the Op Code
  always @(*) begin
      // if (ID_Stall)
      //     Datapath <= `DP_None;
      // else begin
          case (ID.OpCode)
              // R-Type
              `Op_Type_R  :
                  begin
                      case (ID.Funct)
                          `Funct_Add     : Datapath <= `DP_Add;
                          `Funct_Addu    : Datapath <= `DP_Addu;
                          `Funct_And     : Datapath <= `DP_And;
                          `Funct_Break   : Datapath <= `DP_Break;
                          `Funct_Div     : Datapath <= `DP_Div;
                          `Funct_Divu    : Datapath <= `DP_Divu;
                          `Funct_Jalr    : Datapath <= `DP_Jalr;
                          `Funct_Jr      : Datapath <= `DP_Jr;
                          `Funct_Mfhi    : Datapath <= `DP_Mfhi;
                          `Funct_Mflo    : Datapath <= `DP_Mflo;
                          `Funct_Movn    : Datapath <= `DP_Movn;
                          `Funct_Movz    : Datapath <= `DP_Movz;
                          `Funct_Mthi    : Datapath <= `DP_Mthi;
                          `Funct_Mtlo    : Datapath <= `DP_Mtlo;
                          `Funct_Mult    : Datapath <= `DP_Mult;
                          `Funct_Multu   : Datapath <= `DP_Multu;
                          `Funct_Nor     : Datapath <= `DP_Nor;
                          `Funct_Or      : Datapath <= `DP_Or;
                          `Funct_Sll     : Datapath <= `DP_Sll;
                          `Funct_Sllv    : Datapath <= `DP_Sllv;
                          `Funct_Slt     : Datapath <= `DP_Slt;
                          `Funct_Sltu    : Datapath <= `DP_Sltu;
                          `Funct_Sra     : Datapath <= `DP_Sra;
                          `Funct_Srav    : Datapath <= `DP_Srav;
                          `Funct_Srl     : Datapath <= `DP_Srl;
                          `Funct_Srlv    : Datapath <= `DP_Srlv;
                          `Funct_Sub     : Datapath <= `DP_Sub;
                          `Funct_Subu    : Datapath <= `DP_Subu;
                          `Funct_Syscall : Datapath <= `DP_Syscall;
                          `Funct_Teq     : Datapath <= `DP_Teq;
                          `Funct_Tge     : Datapath <= `DP_Tge;
                          `Funct_Tgeu    : Datapath <= `DP_Tgeu;
                          `Funct_Tlt     : Datapath <= `DP_Tlt;
                          `Funct_Tltu    : Datapath <= `DP_Tltu;
                          `Funct_Tne     : Datapath <= `DP_Tne;
                          `Funct_Xor     : Datapath <= `DP_Xor;
                          default        : Datapath <= `DP_None;
                      endcase
                  end
              // R2-Type
              `Op_Type_R2 :
                  begin
                      case (ID.Funct)
                          `Funct_Clo   : Datapath <= `DP_Clo;
                          `Funct_Clz   : Datapath <= `DP_Clz;
                          `Funct_Madd  : Datapath <= `DP_Madd;
                          `Funct_Maddu : Datapath <= `DP_Maddu;
                          `Funct_Msub  : Datapath <= `DP_Msub;
                          `Funct_Msubu : Datapath <= `DP_Msubu;
                          `Funct_Mul   : Datapath <= `DP_Mul;
                          default      : Datapath <= `DP_None;
                      endcase
                  end
              // I-Type
              `Op_Addi    : Datapath <= `DP_Addi;
              `Op_Addiu   : Datapath <= `DP_Addiu;
              `Op_Andi    : Datapath <= `DP_Andi;
              `Op_Ori     : Datapath <= `DP_Ori;
              // `Op_Pref    : Datapath <= `DP_Pref;
              `Op_Slti    : Datapath <= `DP_Slti;
              `Op_Sltiu   : Datapath <= `DP_Sltiu;
              `Op_Xori    : Datapath <= `DP_Xori;
              // Jumps (using immediates)
              `Op_J       : Datapath <= `DP_J;
              `Op_Jal     : Datapath <= `DP_Jal;
              // Branches and Traps
              `Op_Type_BI :
                  begin
                      case (ID.Rt)
                          `OpRt_Bgez   : Datapath <= `DP_Bgez;
                          `OpRt_Bgezal : Datapath <= `DP_Bgezal;
                          `OpRt_Bltz   : Datapath <= `DP_Bltz;
                          `OpRt_Bltzal : Datapath <= `DP_Bltzal;
                          `OpRt_Teqi   : Datapath <= `DP_Teqi;
                          `OpRt_Tgei   : Datapath <= `DP_Tgei;
                          `OpRt_Tgeiu  : Datapath <= `DP_Tgeiu;
                          `OpRt_Tlti   : Datapath <= `DP_Tlti;
                          `OpRt_Tltiu  : Datapath <= `DP_Tltiu;
                          `OpRt_Tnei   : Datapath <= `DP_Tnei;
                          default      : Datapath <= `DP_None;
                      endcase
                  end
              `Op_Beq     : Datapath <= `DP_Beq;
              `Op_Bgtz    : Datapath <= `DP_Bgtz;
              `Op_Blez    : Datapath <= `DP_Blez;
              `Op_Bne     : Datapath <= `DP_Bne;
              // Coprocessor 0
              `Op_Type_CP0 :
                  begin
                      case (ID.Rs)
                          `OpRs_MF   : Datapath <= `DP_Mfc0;
                          `OpRs_MT   : Datapath <= `DP_Mtc0;
                          `OpRs_ERET : Datapath <= (ID.Funct == `Funct_ERET) ? `DP_Eret : `DP_None;
                          default    : Datapath <= `DP_None;
                      endcase
                  end
              // Memory
              `Op_Lb   : Datapath <= `DP_Lb;
              `Op_Lbu  : Datapath <= `DP_Lbu;
              `Op_Lh   : Datapath <= `DP_Lh;
              `Op_Lhu  : Datapath <= `DP_Lhu;
              `Op_Ll   : Datapath <= `DP_Ll;
              `Op_Lui  : Datapath <= `DP_Lui;
              `Op_Lw   : Datapath <= `DP_Lw;
              `Op_Lwl  : Datapath <= `DP_Lwl;
              `Op_Lwr  : Datapath <= `DP_Lwr;
              `Op_Sb   : Datapath <= `DP_Sb;
              `Op_Sc   : Datapath <= `DP_Sc;
              `Op_Sh   : Datapath <= `DP_Sh;
              `Op_Sw   : Datapath <= `DP_Sw;
              `Op_Swl  : Datapath <= `DP_Swl;
              `Op_Swr  : Datapath <= `DP_Swr;
              default  : Datapath <= `DP_None;
          endcase
      // end
  end


  // Set the Hazard Control Signals and Exception Indicators based on the Op Code
  always @(*) begin
      case (ID.OpCode)
          // R-Type
          `Op_Type_R  :
              begin
                  case (ID.Funct)
                      `Funct_Add     : begin DP_Hazards <= `HAZ_Add;     /*DP_Exceptions <= `EXC_Add;     */end
                      `Funct_Addu    : begin DP_Hazards <= `HAZ_Addu;    /*DP_Exceptions <= `EXC_Addu;    */end
                      `Funct_And     : begin DP_Hazards <= `HAZ_And;     /*DP_Exceptions <= `EXC_And;     */end
                      `Funct_Break   : begin DP_Hazards <= `HAZ_Break;   /*DP_Exceptions <= `EXC_Break;   */end
                      `Funct_Div     : begin DP_Hazards <= `HAZ_Div;     /*DP_Exceptions <= `EXC_Div;     */end
                      `Funct_Divu    : begin DP_Hazards <= `HAZ_Divu;    /*DP_Exceptions <= `EXC_Divu;    */end
                      `Funct_Jalr    : begin DP_Hazards <= `HAZ_Jalr;    /*DP_Exceptions <= `EXC_Jalr;    */end
                      `Funct_Jr      : begin DP_Hazards <= `HAZ_Jr;      /*DP_Exceptions <= `EXC_Jr;      */end
                      `Funct_Mfhi    : begin DP_Hazards <= `HAZ_Mfhi;    /*DP_Exceptions <= `EXC_Mfhi;    */end
                      `Funct_Mflo    : begin DP_Hazards <= `HAZ_Mflo;    /*DP_Exceptions <= `EXC_Mflo;    */end
                      `Funct_Movn    : begin DP_Hazards <= `HAZ_Movn;    /*DP_Exceptions <= `EXC_Movn;    */end
                      `Funct_Movz    : begin DP_Hazards <= `HAZ_Movz;    /*DP_Exceptions <= `EXC_Movz;    */end
                      `Funct_Mthi    : begin DP_Hazards <= `HAZ_Mthi;    /*DP_Exceptions <= `EXC_Mthi;    */end
                      `Funct_Mtlo    : begin DP_Hazards <= `HAZ_Mtlo;    /*DP_Exceptions <= `EXC_Mtlo;    */end
                      `Funct_Mult    : begin DP_Hazards <= `HAZ_Mult;    /*DP_Exceptions <= `EXC_Mult;    */end
                      `Funct_Multu   : begin DP_Hazards <= `HAZ_Multu;   /*DP_Exceptions <= `EXC_Multu;   */end
                      `Funct_Nor     : begin DP_Hazards <= `HAZ_Nor;     /*DP_Exceptions <= `EXC_Nor;     */end
                      `Funct_Or      : begin DP_Hazards <= `HAZ_Or;      /*DP_Exceptions <= `EXC_Or;      */end
                      `Funct_Sll     : begin DP_Hazards <= `HAZ_Sll;     /*DP_Exceptions <= `EXC_Sll;     */end
                      `Funct_Sllv    : begin DP_Hazards <= `HAZ_Sllv;    /*DP_Exceptions <= `EXC_Sllv;    */end
                      `Funct_Slt     : begin DP_Hazards <= `HAZ_Slt;     /*DP_Exceptions <= `EXC_Slt;     */end
                      `Funct_Sltu    : begin DP_Hazards <= `HAZ_Sltu;    /*DP_Exceptions <= `EXC_Sltu;    */end
                      `Funct_Sra     : begin DP_Hazards <= `HAZ_Sra;     /*DP_Exceptions <= `EXC_Sra;     */end
                      `Funct_Srav    : begin DP_Hazards <= `HAZ_Srav;    /*DP_Exceptions <= `EXC_Srav;    */end
                      `Funct_Srl     : begin DP_Hazards <= `HAZ_Srl;     /*DP_Exceptions <= `EXC_Srl;     */end
                      `Funct_Srlv    : begin DP_Hazards <= `HAZ_Srlv;    /*DP_Exceptions <= `EXC_Srlv;    */end
                      `Funct_Sub     : begin DP_Hazards <= `HAZ_Sub;     /*DP_Exceptions <= `EXC_Sub;     */end
                      `Funct_Subu    : begin DP_Hazards <= `HAZ_Subu;    /*DP_Exceptions <= `EXC_Subu;    */end
                      `Funct_Syscall : begin DP_Hazards <= `HAZ_Syscall; /*DP_Exceptions <= `EXC_Syscall; */end
                      `Funct_Teq     : begin DP_Hazards <= `HAZ_Teq;     /*DP_Exceptions <= `EXC_Teq;     */end
                      `Funct_Tge     : begin DP_Hazards <= `HAZ_Tge;     /*DP_Exceptions <= `EXC_Tge;     */end
                      `Funct_Tgeu    : begin DP_Hazards <= `HAZ_Tgeu;    /*DP_Exceptions <= `EXC_Tgeu;    */end
                      `Funct_Tlt     : begin DP_Hazards <= `HAZ_Tlt;     /*DP_Exceptions <= `EXC_Tlt;     */end
                      `Funct_Tltu    : begin DP_Hazards <= `HAZ_Tltu;    /*DP_Exceptions <= `EXC_Tltu;    */end
                      `Funct_Tne     : begin DP_Hazards <= `HAZ_Tne;     /*DP_Exceptions <= `EXC_Tne;     */end
                      `Funct_Xor     : begin DP_Hazards <= `HAZ_Xor;     /*DP_Exceptions <= `EXC_Xor;     */end
                      default        : begin DP_Hazards <= 8'hxx;        /*DP_Exceptions <= 3'bxxx;       */end
                  endcase
              end
          // R2-Type
          `Op_Type_R2 :
              begin
                  case (ID.Funct)
                      `Funct_Clo   : begin DP_Hazards <= `HAZ_Clo;   /*DP_Exceptions <= `EXC_Clo;   */end
                      `Funct_Clz   : begin DP_Hazards <= `HAZ_Clz;   /*DP_Exceptions <= `EXC_Clz;   */end
                      `Funct_Madd  : begin DP_Hazards <= `HAZ_Madd;  /*DP_Exceptions <= `EXC_Madd;  */end
                      `Funct_Maddu : begin DP_Hazards <= `HAZ_Maddu; /*DP_Exceptions <= `EXC_Maddu; */end
                      `Funct_Msub  : begin DP_Hazards <= `HAZ_Msub;  /*DP_Exceptions <= `EXC_Msub;  */end
                      `Funct_Msubu : begin DP_Hazards <= `HAZ_Msubu; /*DP_Exceptions <= `EXC_Msubu; */end
                      `Funct_Mul   : begin DP_Hazards <= `HAZ_Mul;   /*DP_Exceptions <= `EXC_Mul;   */end
                      default      : begin DP_Hazards <= 8'hxx;      /*DP_Exceptions <= 3'bxxx;     */end
                  endcase
              end
          // I-Type
          `Op_Addi    : begin DP_Hazards <= `HAZ_Addi;  /*DP_Exceptions <= `EXC_Addi;  */end
          `Op_Addiu   : begin DP_Hazards <= `HAZ_Addiu; /*DP_Exceptions <= `EXC_Addiu; */end
          `Op_Andi    : begin DP_Hazards <= `HAZ_Andi;  /*DP_Exceptions <= `EXC_Andi;  */end
          `Op_Ori     : begin DP_Hazards <= `HAZ_Ori;   /*DP_Exceptions <= `EXC_Ori;   */end
          // `Op_Pref    : begin DP_Hazards <= `HAZ_Pref;  /*DP_Exceptions <= `EXC_Pref;  */end
          `Op_Slti    : begin DP_Hazards <= `HAZ_Slti;  /*DP_Exceptions <= `EXC_Slti;  */end
          `Op_Sltiu   : begin DP_Hazards <= `HAZ_Sltiu; /*DP_Exceptions <= `EXC_Sltiu; */end
          `Op_Xori    : begin DP_Hazards <= `HAZ_Xori;  /*DP_Exceptions <= `EXC_Xori;  */end
          // Jumps
          `Op_J       : begin DP_Hazards <= `HAZ_J;     /*DP_Exceptions <= `EXC_J;     */end
          `Op_Jal     : begin DP_Hazards <= `HAZ_Jal;   /*DP_Exceptions <= `EXC_Jal;   */end
          // Branches and Traps
          `Op_Type_BI :
              begin
                  case (ID.Rt)
                      `OpRt_Bgez   : begin DP_Hazards <= `HAZ_Bgez;   /*DP_Exceptions <= `EXC_Bgez;   */end
                      `OpRt_Bgezal : begin DP_Hazards <= `HAZ_Bgezal; /*DP_Exceptions <= `EXC_Bgezal; */end
                      `OpRt_Bltz   : begin DP_Hazards <= `HAZ_Bltz;   /*DP_Exceptions <= `EXC_Bltz;   */end
                      `OpRt_Bltzal : begin DP_Hazards <= `HAZ_Bltzal; /*DP_Exceptions <= `EXC_Bltzal; */end
                      `OpRt_Teqi   : begin DP_Hazards <= `HAZ_Teqi;   /*DP_Exceptions <= `EXC_Teqi;   */end
                      `OpRt_Tgei   : begin DP_Hazards <= `HAZ_Tgei;   /*DP_Exceptions <= `EXC_Tgei;   */end
                      `OpRt_Tgeiu  : begin DP_Hazards <= `HAZ_Tgeiu;  /*DP_Exceptions <= `EXC_Tgeiu;  */end
                      `OpRt_Tlti   : begin DP_Hazards <= `HAZ_Tlti;   /*DP_Exceptions <= `EXC_Tlti;   */end
                      `OpRt_Tltiu  : begin DP_Hazards <= `HAZ_Tltiu;  /*DP_Exceptions <= `EXC_Tltiu;  */end
                      `OpRt_Tnei   : begin DP_Hazards <= `HAZ_Tnei;   /*DP_Exceptions <= `EXC_Tnei;   */end
                      default      : begin DP_Hazards <= 8'hxx;       /*DP_Exceptions <= 3'bxxx;      */end
                  endcase
              end
          `Op_Beq     : begin DP_Hazards <= `HAZ_Beq;  /*DP_Exceptions <= `EXC_Beq;  */end
          `Op_Bgtz    : begin DP_Hazards <= `HAZ_Bgtz; /*DP_Exceptions <= `EXC_Bgtz; */end
          `Op_Blez    : begin DP_Hazards <= `HAZ_Blez; /*DP_Exceptions <= `EXC_Blez; */end
          `Op_Bne     : begin DP_Hazards <= `HAZ_Bne;  /*DP_Exceptions <= `EXC_Bne;  */end
          // Coprocessor 0
          `Op_Type_CP0 :
              begin
                  case (ID.Rs)
                      `OpRs_MF   : begin DP_Hazards <= `HAZ_Mfc0; /*DP_Exceptions <= `EXC_Mfc0; */end
                      `OpRs_MT   : begin DP_Hazards <= `HAZ_Mtc0; /*DP_Exceptions <= `EXC_Mtc0; */end
                      `OpRs_ERET : begin DP_Hazards <= (ID.Funct == `Funct_ERET) ? `HAZ_Eret : 8'hxx; /*DP_Exceptions <= `EXC_Eret; */end
                      default    : begin DP_Hazards <= 8'hxx;     /*DP_Exceptions <= 3'bxxx;    */end
                  endcase
              end
          // Memory
          `Op_Lb   : begin DP_Hazards <= `HAZ_Lb;  /*DP_Exceptions <= `EXC_Lb;  */end
          `Op_Lbu  : begin DP_Hazards <= `HAZ_Lbu; /*DP_Exceptions <= `EXC_Lbu; */end
          `Op_Lh   : begin DP_Hazards <= `HAZ_Lh;  /*DP_Exceptions <= `EXC_Lh;  */end
          `Op_Lhu  : begin DP_Hazards <= `HAZ_Lhu; /*DP_Exceptions <= `EXC_Lhu; */end
          `Op_Ll   : begin DP_Hazards <= `HAZ_Ll;  /*DP_Exceptions <= `EXC_Ll;  */end
          `Op_Lui  : begin DP_Hazards <= `HAZ_Lui; /*DP_Exceptions <= `EXC_Lui; */end
          `Op_Lw   : begin DP_Hazards <= `HAZ_Lw;  /*DP_Exceptions <= `EXC_Lw;  */end
          `Op_Lwl  : begin DP_Hazards <= `HAZ_Lwl; /*DP_Exceptions <= `EXC_Lwl; */end
          `Op_Lwr  : begin DP_Hazards <= `HAZ_Lwr; /*DP_Exceptions <= `EXC_Lwr; */end
          `Op_Sb   : begin DP_Hazards <= `HAZ_Sb;  /*DP_Exceptions <= `EXC_Sb;  */end
          `Op_Sc   : begin DP_Hazards <= `HAZ_Sc;  /*DP_Exceptions <= `EXC_Sc;  */end
          `Op_Sh   : begin DP_Hazards <= `HAZ_Sh;  /*DP_Exceptions <= `EXC_Sh;  */end
          `Op_Sw   : begin DP_Hazards <= `HAZ_Sw;  /*DP_Exceptions <= `EXC_Sw;  */end
          `Op_Swl  : begin DP_Hazards <= `HAZ_Swl; /*DP_Exceptions <= `EXC_Swl; */end
          `Op_Swr  : begin DP_Hazards <= `HAZ_Swr; /*DP_Exceptions <= `EXC_Swr; */end
          default  : begin DP_Hazards <= 8'hxx;    /*DP_Exceptions <= 3'bxxx;   */end
      endcase
  end


  // ALU Assignment
  always @(*) begin
      // if (ID_Stall)
      //     ID.ALUOp <= `AluOp_Addu;  // Any Op that doesn't write HILO or cause exceptions
      // else begin
          case (ID.OpCode)
              `Op_Type_R  :
                  begin
                      case (ID.Funct)
                          `Funct_Add     : ID.ALUOp <= `AluOp_Add;
                          `Funct_Addu    : ID.ALUOp <= `AluOp_Addu;
                          `Funct_And     : ID.ALUOp <= `AluOp_And;
                          `Funct_Div     : ID.ALUOp <= `AluOp_Div;
                          `Funct_Divu    : ID.ALUOp <= `AluOp_Divu;
                          `Funct_Jalr    : ID.ALUOp <= `AluOp_Addu;
                          `Funct_Mfhi    : ID.ALUOp <= `AluOp_Mfhi;
                          `Funct_Mflo    : ID.ALUOp <= `AluOp_Mflo;
                          `Funct_Movn    : ID.ALUOp <= `AluOp_Addu;
                          `Funct_Movz    : ID.ALUOp <= `AluOp_Addu;
                          `Funct_Mthi    : ID.ALUOp <= `AluOp_Mthi;
                          `Funct_Mtlo    : ID.ALUOp <= `AluOp_Mtlo;
                          `Funct_Mult    : ID.ALUOp <= `AluOp_Mult;
                          `Funct_Multu   : ID.ALUOp <= `AluOp_Multu;
                          `Funct_Nor     : ID.ALUOp <= `AluOp_Nor;
                          `Funct_Or      : ID.ALUOp <= `AluOp_Or;
                          `Funct_Sll     : ID.ALUOp <= `AluOp_Sll;
                          `Funct_Sllv    : ID.ALUOp <= `AluOp_Sllv;
                          `Funct_Slt     : ID.ALUOp <= `AluOp_Slt;
                          `Funct_Sltu    : ID.ALUOp <= `AluOp_Sltu;
                          `Funct_Sra     : ID.ALUOp <= `AluOp_Sra;
                          `Funct_Srav    : ID.ALUOp <= `AluOp_Srav;
                          `Funct_Srl     : ID.ALUOp <= `AluOp_Srl;
                          `Funct_Srlv    : ID.ALUOp <= `AluOp_Srlv;
                          `Funct_Sub     : ID.ALUOp <= `AluOp_Sub;
                          `Funct_Subu    : ID.ALUOp <= `AluOp_Subu;
                          `Funct_Syscall : ID.ALUOp <= `AluOp_Addu;
                          `Funct_Teq     : ID.ALUOp <= `AluOp_Subu;
                          `Funct_Tge     : ID.ALUOp <= `AluOp_Slt;
                          `Funct_Tgeu    : ID.ALUOp <= `AluOp_Sltu;
                          `Funct_Tlt     : ID.ALUOp <= `AluOp_Slt;
                          `Funct_Tltu    : ID.ALUOp <= `AluOp_Sltu;
                          `Funct_Tne     : ID.ALUOp <= `AluOp_Subu;
                          `Funct_Xor     : ID.ALUOp <= `AluOp_Xor;
                          default        : ID.ALUOp <= `AluOp_Addu;
                      endcase
                  end
              `Op_Type_R2 :
                  begin
                      case (ID.Funct)
                          `Funct_Clo   : ID.ALUOp <= `AluOp_Clo;
                          `Funct_Clz   : ID.ALUOp <= `AluOp_Clz;
                          `Funct_Madd  : ID.ALUOp <= `AluOp_Madd;
                          `Funct_Maddu : ID.ALUOp <= `AluOp_Maddu;
                          `Funct_Msub  : ID.ALUOp <= `AluOp_Msub;
                          `Funct_Msubu : ID.ALUOp <= `AluOp_Msubu;
                          `Funct_Mul   : ID.ALUOp <= `AluOp_Mul;
                          default      : ID.ALUOp <= `AluOp_Addu;
                      endcase
                  end
              `Op_Type_BI  :
                  begin
                      case (ID.Rt)
                          `OpRt_Teqi   : ID.ALUOp <= `AluOp_Subu;
                          `OpRt_Tgei   : ID.ALUOp <= `AluOp_Slt;
                          `OpRt_Tgeiu  : ID.ALUOp <= `AluOp_Sltu;
                          `OpRt_Tlti   : ID.ALUOp <= `AluOp_Slt;
                          `OpRt_Tltiu  : ID.ALUOp <= `AluOp_Sltu;
                          `OpRt_Tnei   : ID.ALUOp <= `AluOp_Subu;
                          default      : ID.ALUOp <= `AluOp_Addu;  // Branches don't matter.
                      endcase
                  end
              `Op_Type_CP0 : ID.ALUOp <= `AluOp_Addu;
              `Op_Addi     : ID.ALUOp <= `AluOp_Add;
              `Op_Addiu    : ID.ALUOp <= `AluOp_Addu;
              `Op_Andi     : ID.ALUOp <= `AluOp_And;
              `Op_Jal      : ID.ALUOp <= `AluOp_Addu;
              `Op_Lb       : ID.ALUOp <= `AluOp_Addu;
              `Op_Lbu      : ID.ALUOp <= `AluOp_Addu;
              `Op_Lh       : ID.ALUOp <= `AluOp_Addu;
              `Op_Lhu      : ID.ALUOp <= `AluOp_Addu;
              `Op_Ll       : ID.ALUOp <= `AluOp_Addu;
              `Op_Lui      : ID.ALUOp <= `AluOp_Sllc;
              `Op_Lw       : ID.ALUOp <= `AluOp_Addu;
              `Op_Lwl      : ID.ALUOp <= `AluOp_Addu;
              `Op_Lwr      : ID.ALUOp <= `AluOp_Addu;
              `Op_Ori      : ID.ALUOp <= `AluOp_Or;
              `Op_Sb       : ID.ALUOp <= `AluOp_Addu;
              `Op_Sc       : ID.ALUOp <= `AluOp_Addu;  // XXX Needs HW implement
              `Op_Sh       : ID.ALUOp <= `AluOp_Addu;
              `Op_Slti     : ID.ALUOp <= `AluOp_Slt;
              `Op_Sltiu    : ID.ALUOp <= `AluOp_Sltu;
              `Op_Sw       : ID.ALUOp <= `AluOp_Addu;
              `Op_Swl      : ID.ALUOp <= `AluOp_Addu;
              `Op_Swr      : ID.ALUOp <= `AluOp_Addu;
              `Op_Xori     : ID.ALUOp <= `AluOp_Xor;
              default      : ID.ALUOp <= `AluOp_Addu;
          endcase
      // end
  end

  /***
   These remaining options cover portions of the datapath that are not
   controlled directly by the datapath bits. Note that some refer to bits of
   the opcode or other fields, which breaks the otherwise fully-abstracted view
   of instruction encodings. Make sure when adding custom instructions that
   no false positives/negatives are generated here.
   ***/

  // Branch Detection: Options are mutually exclusive.
  assign Branch_EQ  =  ID.OpCode[2] & ~ID.OpCode[1] & ~ID.OpCode[0] &  ID.CmpEQ;
  assign Branch_GTZ =  ID.OpCode[2] &  ID.OpCode[1] &  ID.OpCode[0] &  ID.CmpGZ;
  assign Branch_LEZ =  ID.OpCode[2] &  ID.OpCode[1] & ~ID.OpCode[0] &  ID.CmpLEZ;
  assign Branch_NEQ =  ID.OpCode[2] & ~ID.OpCode[1] &  ID.OpCode[0] & ~ID.CmpEQ;
  assign Branch_GEZ = ~ID.OpCode[2] &  ID.Rt[0]     &  ID.CmpGEZ;
  assign Branch_LTZ = ~ID.OpCode[2] & ~ID.Rt[0]     &  ID.CmpLZ;
  assign Branch = Branch_EQ | Branch_GTZ | Branch_LEZ | Branch_NEQ | Branch_GEZ | Branch_LTZ;
  assign ID.PCSrc[1] = (Datapath[15] & ~Datapath[14]) ? Branch : Datapath[15];




  // Sign- or Zero-Extension Control. The only ops that require zero-extension are
  // Andi, Ori, and Xori. The following also zero-extends 'lui', however it does not alter the effect of lui.
  assign ID.SignExtend = (ID.OpCode[5:2] != 4'b0011);

  // Coprocessor 0 (Mfc0, Mtc0) control signals.
  assign ID.Mfc0 = ((ID.OpCode == `Op_Type_CP0) && (ID.Rs == `OpRs_MF));
  assign ID.Mtc0 = ((ID.OpCode == `Op_Type_CP0) && (ID.Rs == `OpRs_MT));
  assign ID.Eret = ((ID.OpCode == `Op_Type_CP0) && (ID.Rs == `OpRs_ERET) && (ID.Funct == `Funct_ERET));


  /* In MIPS32, all Branch and Jump operations execute the Branch Delay Slot,
   * or next instruction, regardless if the branch is taken or not. The exception
   * is the "Branch Likely" instruction group. These are deprecated, however, and not
   * implemented here. "IF_Flush" is defined to allow for the cancelation of a
   * Branch Delay Slot should these be implemented later.
   */
  assign IF_Flush = 0;

endmodule
