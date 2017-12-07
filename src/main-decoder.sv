// module main_decoder (
//   input logic [5:0] opcode,
//   output logic [1:0] aluOp,
//   output logic memToReg,
//   output logic memWrite,
//   output logic branch,
//   output logic aluSrc,
//   output logic regDst,
//   output logic regWrite
// );
//
//   logic [7:0] controls;
//
//   assign { regWrite, regDst, aluSrc, branch, memWrite, memToReg, aluOp } = controls;
//
//   // always_comb cause syntax error with icuros
//   // always_comb begin
//   always @(*) begin
//     case (opcode)
//       6'b000000: controls =  8'b1100_0010; // R-Type
//       6'b100011: controls =  8'b1010_0100; // LW
//       6'b101011: controls =  8'b0010_1000; // SW
//       6'b000100: controls =  8'b0001_0001; // BEQ
//       default:   controls =  8'bxxxx_xxxx; // illegal op
//     endcase
//   end
//
// endmodule
