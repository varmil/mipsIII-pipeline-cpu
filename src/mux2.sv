module mux2 #(parameter N = 8)
             (input logic [N - 1:0] a, b,
              input logic selector,
              output logic [N - 1:0] out);

  assign out = (selector) ? b : a;
endmodule // mux2
