module sign_or_zero_extender (
  input  logic [15:0] In,
  input  logic        SignExtend,
  output logic [31:0] Out
);
  assign Out = (SignExtend & In[15]) ? {16'hFFFF, In} : {16'h0000, In};
endmodule
