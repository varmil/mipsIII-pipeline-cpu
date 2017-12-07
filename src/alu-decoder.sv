// // TODO
//
// module alu_decoder (
//   input logic [5:0] funct,
//   input logic [1:0] aluOp,
//   output logic [2:0] aluControl
// );
//
//   // logic [7:0] controls;
//   //
//   // assign { regWrite, regDst, aluSrc, branch, memWrite, memToReg, aluOp } = controls;
//
//   // always_comb cause syntax error with icuros
//   // always_comb begin
//   always @(*) begin
//     case (aluOp)
//       2'b00: aluControl =  3'b010; // add
//       2'b01: aluControl =  3'b110; // subtract
//
//       // Type-R (aluControl is decided only with funct), aluOp is 1X
//       default: case (funct)
//         6'b100000: ;
//         default: ;
//       endcase
//     endcase
//   end
//
// endmodule
