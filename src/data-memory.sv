module data_memory #(parameter N = 32) (
  input logic CLK,
  input logic [N - 1:0] address,
  input logic [N - 1:0] writeData,
  input logic writeEnable,
  output logic [N - 1:0] readData
);

  logic [N -1:0] RAM [63:0];

  assign readData = RAM[address];

  always @ (posedge CLK) begin
    if (writeEnable) begin
      RAM[address] <= writeData;
    end
  end

endmodule // data_memory
