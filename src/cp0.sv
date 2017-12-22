module cp0(


  output IF_Exception_Flush,
  output ID_Exception_Flush,
  output EX_Exception_Flush,
  output M_Exception_Flush
);





  /*** TODO:
   Flushes. A flush clears a pipeline stage's control signals and prevents the stage from committing any changes.
   Data such as 'RestartPC' and the detected exception must remain.
  */
  assign   M_Exception_Flush = 1'b0; // M_Exception_Detect;
  assign  EX_Exception_Flush = 1'b0; // M_Exception_Detect | EX_Exception_Detect;
  assign  ID_Exception_Flush = 1'b0; // M_Exception_Detect | EX_Exception_Detect | ID_Exception_Detect;
  assign  IF_Exception_Flush = 1'b0; // M_Exception_Detect | EX_Exception_Detect | ID_Exception_Detect | IF_Exception_Detect | (ERET & ~ID_Stall) | reset_r;

endmodule
