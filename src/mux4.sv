module mux4 #(parameter N = 32) (
  input logic [N - 1:0] a, b, c, d,
  input logic [1:0] selector,
  output logic [N - 1:0] out
);

  always @(*) begin
    case (selector)
      2'b00 : out <= a;
      2'b01 : out <= b;
      2'b10 : out <= c;
      2'b11 : out <= d;
    endcase
  end

endmodule // mux4
