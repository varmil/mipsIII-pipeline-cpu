module adder #(parameter N = 32) (
  input logic  [N - 1:0] a, b,
  output logic [N - 1:0] s
);
  assign s = a + b;
endmodule // adder
