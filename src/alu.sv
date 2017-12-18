module alu (
  input logic CLK, RST,
  input logic EX_Stall,
  input logic [4:0] Operation,
  input logic signed [4:0] Shamt,
  input logic [31:0] A, B,

  output logic signed [31:0] Result,
  output reg  EXC_Ov,
  output wire ALU_Stall        // Stalls due to long ALU operations
);

  `include "parameters.sv"

  /***
   Performance Notes:
   The ALU is the longest delay path in the Execute stage, and one of the longest
   in the entire processor. This path varies based on the logic blocks that are
   chosen to implement various functions, but there is certainly room to improve
   the speed of arithmetic operations. The ALU could also be placed in a separate
   pipeline stage after the Execute forwarding has completed.
  ***/

  /***
   Divider Logic:
   The hardware divider requires 32 cycles to complete. Because it writes its
   results to HILO and not to the pipeline, the pipeline can proceed without
   stalling. When a later instruction tries to access HILO, the pipeline will
   stall if the divide operation has not yet completed.
  ***/

  /***** Internal state registers *****/
  reg  [63:0] HILO;
  reg  HILO_Access;                   // Behavioral; not DFFs
  // reg  [5:0] CLO_Result, CLZ_Result;  // Behavioral; not DFFs
  reg  Div_Fsm;

  /***** internal signals *****/
  // ADD, SUB, MULT(U) for Signed and not Signed operations
  wire               AddSub_Add    = ((Operation == `AluOp_Add) | (Operation == `AluOp_Addu));
  wire signed [31:0] AddSub_Result = (AddSub_Add) ? (A + B) : (A - B);
  wire signed [31:0] As = A;
  wire signed [31:0] Bs = B;
  wire signed [63:0] Mult_Result  = As * Bs;
  wire [63:0]        Multu_Result = A * B;

  // HILO
  wire [31:0] HI = HILO[63:32];
  wire [31:0] LO = HILO[31:0];
  wire        HILO_Commit = ~(EX_Stall); // TODO: ~(EX_Stall | EX_Flush); // 0: EX stage is either stall or flush, 1: other

  // DIV(U)
  wire [31:0] Quotient;
  wire [31:0] Remainder;
  wire Div_Stall; // assert while divider unit is busy with DIV(U) operation
  wire DivOp        = (Operation == `AluOp_Div) || (Operation == `AluOp_Divu);
  wire Div_Commit   = (Div_Fsm == 1'b1) && (Div_Stall == 1'b0);
  wire Div_Start    = (Div_Fsm == 1'b0) && (Operation == `AluOp_Div)  && (HILO_Commit == 1'b1);
  wire Divu_Start   = (Div_Fsm == 1'b0) && (Operation == `AluOp_Divu) && (HILO_Commit == 1'b1);

  // ALU stall (NOTE: HILO_Access is really needed ? for what ?)
  assign ALU_Stall  = (Div_Fsm == 1'b1) && (HILO_Access == 1'b1);


  // FF for Result of ALU
  always @(*) begin
     case (Operation)
       `AluOp_Add   : Result <= AddSub_Result;
       `AluOp_Addu  : Result <= AddSub_Result;
       `AluOp_And   : Result <= A & B;
      //  `AluOp_Clo   : Result <= {26'b0, CLO_Result};
      //  `AluOp_Clz   : Result <= {26'b0, CLZ_Result};
       `AluOp_Mfhi  : Result <= HI;
       `AluOp_Mflo  : Result <= LO;
       `AluOp_Mul   : Result <= Mult_Result[31:0];
       `AluOp_Nor   : Result <= ~(A | B);
       `AluOp_Or    : Result <= A | B;
       `AluOp_Sll   : Result <= B << Shamt;
       `AluOp_Sllc  : Result <= {B[15:0], 16'b0};
       `AluOp_Sllv  : Result <= B << A[4:0];
       `AluOp_Slt   : Result <= (As < Bs) ? 32'h0000_0001 : 32'h0000_0000;
       `AluOp_Sltu  : Result <= (A < B)   ? 32'h0000_0001 : 32'h0000_0000;
       `AluOp_Sra   : Result <= Bs >>> Shamt;
       `AluOp_Srav  : Result <= Bs >>> As[4:0];
       `AluOp_Srl   : Result <= B >> Shamt;
       `AluOp_Srlv  : Result <= B >> A[4:0];
       `AluOp_Sub   : Result <= AddSub_Result;
       `AluOp_Subu  : Result <= AddSub_Result;
       `AluOp_Xor   : Result <= A ^ B;
       default      : Result <= 32'hxxxx_xxxx;
     endcase
  end

  // FF for HILO reg
  always @(posedge CLK) begin
      if (RST) begin
          HILO <= 64'h00000000_00000000;
      end
      else if (Div_Commit) begin
          HILO <= {Remainder, Quotient};
      end
      else if (HILO_Commit) begin
          case (Operation)
              `AluOp_Mult  : HILO <= Mult_Result;
              `AluOp_Multu : HILO <= Multu_Result;
              `AluOp_Madd  : HILO <= HILO + Mult_Result;
              `AluOp_Maddu : HILO <= HILO + Multu_Result;
              `AluOp_Msub  : HILO <= HILO - Mult_Result;
              `AluOp_Msubu : HILO <= HILO - Multu_Result;
              `AluOp_Mthi  : HILO <= {A, LO};
              `AluOp_Mtlo  : HILO <= {HI, B};
              default      : HILO <= HILO;
          endcase
      end
      else begin
          HILO <= HILO;
      end
  end

  // Detect accesses to HILO. RAW and WAW hazards are possible while a
  // divide operation is computing, so reads and writes to HILO must stall
  // while the divider is busy.
  // (This logic could be put into an earlier pipeline stage or into the
  // datapath bits to improve timing.)
  always @(Operation) begin
      case (Operation)
          `AluOp_Div   : HILO_Access <= 1;
          `AluOp_Divu  : HILO_Access <= 1;
          `AluOp_Mfhi  : HILO_Access <= 1;
          `AluOp_Mflo  : HILO_Access <= 1;
          `AluOp_Mult  : HILO_Access <= 1;
          `AluOp_Multu : HILO_Access <= 1;
          `AluOp_Madd  : HILO_Access <= 1;
          `AluOp_Maddu : HILO_Access <= 1;
          `AluOp_Msub  : HILO_Access <= 1;
          `AluOp_Msubu : HILO_Access <= 1;
          `AluOp_Mthi  : HILO_Access <= 1;
          `AluOp_Mtlo  : HILO_Access <= 1;
          default      : HILO_Access <= 0;
      endcase
  end

  // Divider FSM: The divide unit is either available or busy.
  always @(posedge CLK) begin
      if (RST) begin
          Div_Fsm <= 1'd0;
      end
      else begin
          case (Div_Fsm)
              1'd0 : Div_Fsm <= (Div_Start | Divu_Start) ? 1'd1 : 1'd0;
              1'd1 : Div_Fsm <= (~Div_Stall) ? 1'd0 : 1'd1;
          endcase
      end
  end

  // Multicycle divide unit
  divider divider (
      .clock      (CLK),
      .reset      (RST),
      .OP_div     (Div_Start),
      .OP_divu    (Divu_Start),
      .Dividend   (A),
      .Divisor    (B),
      .Quotient   (Quotient),
      .Remainder  (Remainder),
      .Stall      (Div_Stall)
  );

  // Detect overflow for signed operations. Note that MIPS32 has no overflow
  // detection for multiplication/division operations.
  always @(*) begin
      case (Operation)
          `AluOp_Add : EXC_Ov <= ((A[31] ~^ B[31]) & (A[31] ^ AddSub_Result[31]));
          `AluOp_Sub : EXC_Ov <= ((A[31]  ^ B[31]) & (A[31] ^ AddSub_Result[31]));
          default    : EXC_Ov <= 0;
      endcase
  end


endmodule // alu
