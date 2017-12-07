module register_file #(parameter N = 32) (
  input logic CLK, WriteEnable,
  input logic [$clog2(N) - 1:0] Address1, Address2, WriteAddress,
  input logic [N - 1:0] WriteData,
  output logic [N - 1:0] ReadData1, ReadData2
);
  logic [N - 1:0] Register [N - 1:0];

  assign ReadData1 = Register[Address1];
  assign ReadData2 = Register[Address2];

  always @ (posedge CLK) begin
    if (WriteEnable) Register[WriteAddress] <= WriteData;
  end

endmodule // register_file
