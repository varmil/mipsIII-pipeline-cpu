module register_file #(parameter N = 32) (
  input logic CLK, writeEnable,
  input logic [$clog2(N) - 1:0] address1, address2, writeAddress,
  input logic [N - 1:0] writeData,
  output logic [N - 1:0] readData1, readData2
);
  logic [N - 1:0] register [N - 1:0];

  assign readData1 = register[address1];
  assign readData2 = register[address2];

  always @ (posedge CLK) begin
    if (writeEnable) register[writeAddress] <= writeData;
  end

endmodule // register_file
