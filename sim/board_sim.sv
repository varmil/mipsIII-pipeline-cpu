module board_sim;
  logic CLK, RST;

  board board(CLK, RST);

  always #5 CLK = ~CLK;

  initial begin
  end

  initial begin
    CLK  = 0;
    RST  = 1;
    #10  RST = 0;

    #5;

    #2000 $finish;
  end

  initial begin
    // $monitor("CLK=%d, RST=%d, F=%d", CLK, RST, aluIntf.F);
  end

endmodule
