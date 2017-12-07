// Shift Left 2bits module for branch / jump operations
module sl2 (
  input  logic [31:0] In,
  output logic [31:0] Out
);
  assign Out = { In[29:0], 2'b00 };
endmodule // sl2
