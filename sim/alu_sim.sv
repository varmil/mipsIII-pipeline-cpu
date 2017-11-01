module alu_sim;
  parameter ALU_AND     = 3'b000;
  parameter ALU_OR      = 3'b001;
  parameter ALU_ADD     = 3'b010;
  parameter ALU_XXX     = 3'b011;
  parameter ALU_AND_NOT = 3'b100;
  parameter ALU_OR_NOT  = 3'b101;
  parameter ALU_SUB     = 3'b110;
  parameter ALU_SLT     = 3'b111;

  logic CLK, RST;
  logic [31:0] A, B, Y;
  logic [2:0]  F;
  logic Cout, ZeroFlag;

  alu #32 ALU(A, B, F, Y, Cout, ZeroFlag);

  always #5 CLK = ~CLK;

  initial begin
    // OR
    A = 32'h0000_0001;
    B = 32'h0000_0010;
    F = 3'b001;
  end

  initial begin
    CLK  = 0;
    RST  = 0;
    #10  RST = 1;

    #5;

    #10; // AND
    A = 32'h0011_0000;
    B = 32'h0000_0011;
    F = 3'b000;

    #10; // A + B
    A = 32'hffff_ffff;
    B = 32'h0000_0010;
    F = 3'b010;

    #10; // A AND ~B
    A = 32'hffff_ffff;
    B = 32'hf00f_0001;
    F = 3'b100;

    #10; // A OR ~B
    A = 32'h0000_ffff;
    B = 32'hf00f_0001;
    F = 3'b101;

    #10; // A - B
    A = 32'h0000_0010;
    B = 32'h0000_0011;
    F = 3'b110;

    #10; // A - B
    A = 32'h0000_0010;
    B = 32'h0000_0001;
    F = 3'b110;

    #10; // SLT
    A = 32'h0000_0010;
    B = 32'h0000_0011;
    F = 3'b111;

    #10; // SLT
    A = 32'h0000_0110;
    B = 32'h0000_0011;
    F = 3'b111;

    #20 $finish;
  end

  initial begin
    // $monitor("CLK=%d, RST=%d, F=%d", CLK, RST, aluIntf.F);
  end

endmodule
