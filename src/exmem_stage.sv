module exmem_stage(
  input logic CLK, RST,
  intf_ex.exmem_in   EX,
  intf_mem.exmem_out MEM
);

  always @(posedge CLK) begin
    // control signals
    MEM.Trap          <= (RST) ? 1'b0  : ((MEM.Stall) ? MEM.Trap          : ((EX.Stall | EX.Flush) ? 1'b0 : EX.Trap));
    MEM.TrapCond      <= (RST) ? 1'b0  : ((MEM.Stall) ? MEM.TrapCond                                      : EX.TrapCond);
    MEM.LLSC          <= (RST) ? 1'b0  : ((MEM.Stall) ? MEM.LLSC                                          : EX.LLSC);
    MEM.MemRead       <= (RST) ? 1'b0  : ((MEM.Stall) ? MEM.MemRead       : ((EX.Stall | EX.Flush) ? 1'b0 : EX.MemRead));
    MEM.MemWrite      <= (RST) ? 1'b0  : ((MEM.Stall) ? MEM.MemWrite      : ((EX.Stall | EX.Flush) ? 1'b0 : EX.MemWrite));
    MEM.MemHalf       <= (RST) ? 1'b0  : ((MEM.Stall) ? MEM.MemHalf                                       : EX.MemHalf);
    MEM.MemByte       <= (RST) ? 1'b0  : ((MEM.Stall) ? MEM.MemByte                                       : EX.MemByte);
    MEM.MemSignExtend <= (RST) ? 1'b0  : ((MEM.Stall) ? MEM.MemSignExtend                                 : EX.MemSignExtend);
    MEM.RegWrite      <= (RST) ? 1'b0  : ((MEM.Stall) ? MEM.RegWrite      : ((EX.Stall | EX.Flush) ? 1'b0 : EX.RegWrite));
    MEM.MemtoReg      <= (RST) ? 1'b0  : ((MEM.Stall) ? MEM.MemtoReg                                      : EX.MemtoReg);

    // M_ReverseEndian <= (RST) ? 1'b0  : ((MEM.Stall) ? M_ReverseEndian                                 : EX_ReverseEndian);
    // M_KernelMode    <= (RST) ? 1'b0  : ((MEM.Stall) ? M_KernelMode                                    : EX_KernelMode);
    // M_RestartPC     <= (RST) ? 32'b0 : ((MEM.Stall) ? M_RestartPC                                     : EX_RestartPC);
    // M_IsBDS         <= (RST) ? 1'b0  : ((MEM.Stall) ? M_IsBDS                                         : EX_IsBDS);
    // M_M_CanErr      <= (RST) ? 1'b0  : ((MEM.Stall) ? M_M_CanErr      : ((EX.Stall | EX.Flush) ? 1'b0 : EX_M_CanErr));
    MEM.ALUResult     <= (RST) ? 32'b0 : ((MEM.Stall) ? MEM.ALUResult                                   : EX.ALUResult);
    MEM.ReadData2     <= (RST) ? 32'b0 : ((MEM.Stall) ? MEM.ReadData2                                   : EX.ReadData2);
    MEM.RegDstOut     <= (RST) ? 5'b0  : ((MEM.Stall) ? MEM.RegDstOut                                   : EX.RegDstOut);
  end

endmodule
