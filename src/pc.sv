module program_counter #(parameter N = 32) (
  input logic CLK,
  input logic [N - 1:0] in,
  output logic [N - 1:0] out
);
  always @ (posedge CLK) begin
    out <= in;
  end
endmodule // program_counter
