module program_counter #(parameter N = 32, INIT = 0) (
  input logic CLK, RST,
  input logic [N - 1:0] in,
  output logic [N - 1:0] out
);
  always @ (posedge CLK) begin
    out <= (RST) ? INIT : in;
  end
endmodule // program_counter
