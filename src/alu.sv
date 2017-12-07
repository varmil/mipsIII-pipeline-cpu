// module alu #(parameter N = 32) (
//   input logic [N-1:0] A, B,
//   input logic [2:0] F,
//
//   output logic [N-1:0] Y,
//   output logic Cout,
//   output logic ZeroFlag
// );
//
//   logic [N-1:0] BSelected;
//   logic [N-1:0] S;
//
//   assign BSelected = (F[2]) ? ~B : B;
//   assign {Cout, S} = A + BSelected;
//   assign ZeroFlag = Y == '0;
//
//   always @(*) begin
//     case (F[1:0])
//       2'b00: Y = A & BSelected;
//       2'b01: Y = A | BSelected;
//       2'b10: Y = S;
//       2'b11: Y = { {(N-1){1'b0}}, S[N-1] };
//       default: Y = 'X;
//     endcase
//   end
// endmodule // alu

module alu (
  input logic [4:0] Operation,
  input logic signed [4:0] Shamt,
  input logic [31:0] A, B,

  output logic signed [31:0] Result,
  output logic ZeroFlag
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

  assign ZeroFlag = Result == '0;

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
       `AluOp_Slt   : Result <= (As < Bs) ? 32'h0000_0001 : 32'h00000000;
       `AluOp_Sltu  : Result <= (A < B)   ? 32'h0000_0001 : 32'h00000000;
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
