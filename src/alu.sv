module alu #(parameter N =8)
            (input logic [N-1:0] A, B,
             input logic [2:0] F,
             output logic [N-1:0] Y,
             output logic Cout,
             output logic ZeroFlag);

  logic [N-1:0] BSelected;
  logic [N-1:0] S;

  assign BSelected = (F[2]) ? ~B : B;
  assign {Cout, S} = A + BSelected;
  assign ZeroFlag = Y == '0;

  always @(*) begin
    case (F[1:0])
      2'b00: Y = A & BSelected;
      2'b01: Y = A | BSelected;
      2'b10: Y = S;
      2'b11: Y = { {31{1'b0}}, S[N-1] };
      default: Y = 'X;
    endcase
  end
endmodule // alu
