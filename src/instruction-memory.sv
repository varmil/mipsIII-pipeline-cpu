module instruction_memory #(parameter N = 32) (
  input logic [N -1:0] address,
  output logic [N -1:0] ir
);

  logic [N -1:0] RAM [63:0];

  initial begin
    $readmemh("memfile.dat", RAM);
  end

  assign ir = RAM[address];
endmodule // instruction_memory
