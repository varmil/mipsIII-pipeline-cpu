module adder #(parameter N = 8)
              (input logic  [N - 1:0] a, b,
               output logic [N - 1:0] s,
               output logic           cout);

  assign { cout, s } = a + b;
endmodule // adder
