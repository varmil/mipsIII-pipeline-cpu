module ifid_stage(
  input logic CLK, RST,
  intf_if.ifid_in  IF,
  intf_id.ifid_out ID
);

    /***
     The signal 'ID_IsFlushed' is needed because of interrupts. Normally, a flushed instruction
     is a NOP which will never cause an exception and thus its restart PC will never be needed
     or used. However, interrupts are detected in ID and may occur when any instruction, flushed
     or not, is in the ID stage. It is an error to save the restart PC of a flushed instruction
     since it was never supposed to execute (such as the "delay slot" after ERET or the branch
     delay slot after a canceled Branch Likely instruction). A simple way to prevent this is to
     pass a signal to ID indicating that its instruction was flushed. Interrupt detection is then
     masked when this signal is high, and the interrupt will trigger on the next instruction load to ID.
    ***/

    assign IF_Flush = (IF.Flush | IF.ExceptionFlush);

    always @(posedge CLK) begin
        ID.Instruction <= (RST) ? 32'b0 : ((ID.Stall) ? ID.Instruction : ((IF.Stall | IF_Flush) ? 32'b0 : IF.Instruction));
        ID.PCAdd4      <= (RST) ? 32'b0 : ((ID.Stall) ? ID.PCAdd4                                       : IF.PCAdd4);
        // ID.ID_IsBDS       <= (RST) ? 1'b0  : ((ID.Stall) ? ID.ID_IsBDS                                        : IF.IF_IsBDS);
        // ID.ID_RestartPC   <= (RST) ? 32'b0 : ((ID.Stall  | IF.IF_IsBDS) ? ID.ID_RestartPC                     : IF.PCOut);
        // ID.ID_IsFlushed   <= (RST) ? 1'b0  : ((ID.Stall) ? ID.ID_IsFlushed                                    : IF_Flush);
    end

endmodule
