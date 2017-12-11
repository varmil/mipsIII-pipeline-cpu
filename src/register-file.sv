module register_file #(parameter N = 32) (
  input logic CLK, WriteEnable,
  input logic [$clog2(N) - 1:0] Address1, Address2, WriteAddress,
  input logic [N - 1:0] WriteData,
  output logic [N - 1:0] ReadData1, ReadData2
);
  logic [N - 1:0] Register [N - 1:0];

  // Initialize all to zero (31 GPR), but $zero
  integer i;
  initial begin
    for (i = 1; i < N; i = i + 1) begin
      Register[i] <= 0;
    end
  end

  // Register 0 is hardwired to 0s
  assign ReadData1 = (Address1 == 0) ? 32'h0000_0000 : Register[Address1];
  assign ReadData2 = (Address2 == 0) ? 32'h0000_0000 : Register[Address2];

  always @ (posedge CLK) begin
    if (WriteEnable) Register[WriteAddress] <= WriteData;
  end

endmodule // register_file
