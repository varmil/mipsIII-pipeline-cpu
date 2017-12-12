module alu (
  input logic [4:0] Operation,
  input logic signed [4:0] Shamt,
  input logic [31:0] A, B,

  output logic signed [31:0] Result
);

  `include "parameters.sv"

  // internal signals
  wire signed [31:0] AddSub_Result;
  wire signed [31:0] As, Bs;

  // for Signed operations
  assign AddSub_Add = ((Operation == `AluOp_Add) | (Operation == `AluOp_Addu));
  assign AddSub_Result = (AddSub_Add) ? (A + B) : (A - B);
  assign As = A;
  assign Bs = B;

  always @(*) begin
     case (Operation)
       `AluOp_Add   : Result <= AddSub_Result;
       `AluOp_Addu  : Result <= AddSub_Result;
       `AluOp_And   : Result <= A & B;
      //  `AluOp_Clo   : Result <= {26'b0, CLO_Result};
      //  `AluOp_Clz   : Result <= {26'b0, CLZ_Result};
      //  `AluOp_Mfhi  : Result <= HI;
      //  `AluOp_Mflo  : Result <= LO;
      //  `AluOp_Mul   : Result <= Mult_Result[31:0];
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

endmodule // alu
