module idex_stage(
  input logic CLK, RST,
  intf_id.idex_in  ID,
  intf_ex.idex_out EX
);

  // reg EX_RegDst;
  // assign EX_LinkRegDst = (EX_Link) ? 2'b10 : ((EX_RegDst) ? 2'b01 : 2'b00);

  // NOTE: why is this needed ?
  // reg [16:0] EX_SignExtImm_pre;
  // assign EX_SignExtImm = (EX_SignExtImm_pre[16]) ? {15'h7fff, EX_SignExtImm_pre[16:0]} : {15'h0000, EX_SignExtImm_pre[16:0]};
  assign EX.Rd = EX.ExtImmOut[15:11];
  assign EX.Shamt = EX.ExtImmOut[10:6];

  always @(posedge CLK) begin
    // control signals
    EX.ALUOp          <= (RST) ? 5'b0  : ((EX.Stall) ? EX.ALUOp         : ((ID.Stall | ID.Flush) ? 5'b0 : ID.ALUOp));
    EX.Link           <= (RST) ? 1'b0  : ((EX.Stall) ? EX.Link                                          : ID.Link);
    EX.ALUSrcImm      <= (RST) ? 1'b0  : ((EX.Stall) ? EX.ALUSrcImm                                     : ID.ALUSrcImm);
    EX.Trap           <= (RST) ? 1'b0  : ((EX.Stall) ? EX.Trap          : ((ID.Stall | ID.Flush) ? 1'b0 : ID.Trap));
    EX.TrapCond       <= (RST) ? 1'b0  : ((EX.Stall) ? EX.TrapCond                                      : ID.TrapCond);
    EX.RegDst         <= (RST) ? 1'b0  : ((EX.Stall) ? EX.RegDst                                        : ID.RegDst);
    EX.LLSC           <= (RST) ? 1'b0  : ((EX.Stall) ? EX.LLSC                                          : ID.LLSC);
    EX.MemRead        <= (RST) ? 1'b0  : ((EX.Stall) ? EX.MemRead       : ((ID.Stall | ID.Flush) ? 1'b0 : ID.MemRead));
    EX.MemWrite       <= (RST) ? 1'b0  : ((EX.Stall) ? EX.MemWrite      : ((ID.Stall | ID.Flush) ? 1'b0 : ID.MemWrite));
    EX.MemHalf        <= (RST) ? 1'b0  : ((EX.Stall) ? EX.MemHalf                                       : ID.MemHalf);
    EX.MemByte        <= (RST) ? 1'b0  : ((EX.Stall) ? EX.MemByte                                       : ID.MemByte);
    EX.MemSignExtend  <= (RST) ? 1'b0  : ((EX.Stall) ? EX.MemSignExtend                                 : ID.MemSignExtend);
    EX.RegWrite       <= (RST) ? 1'b0  : ((EX.Stall) ? EX.RegWrite      : ((ID.Stall | ID.Flush) ? 1'b0 : ID.RegWrite));
    EX.MemtoReg       <= (RST) ? 1'b0  : ((EX.Stall) ? EX.MemtoReg                                      : ID.MemtoReg);

    // EX_ReverseEndian  <= (RST) ? 1'b0  : ((EX.Stall) ? EX_ReverseEndian                                 : ID_ReverseEndian);
    // EX_RestartPC      <= (RST) ? 32'b0 : ((EX.Stall) ? EX_RestartPC                                     : ID_RestartPC);
    // EX_IsBDS          <= (RST) ? 1'b0  : ((EX.Stall) ? EX_IsBDS                                         : ID_IsBDS);
    // EX_EX_CanErr      <= (RST) ? 1'b0  : ((EX.Stall) ? EX_EX_CanErr     : ((ID.Stall | ID.Flush) ? 1'b0 : ID_EX_CanErr));
    // EX_M_CanErr       <= (RST) ? 1'b0  : ((EX.Stall) ? EX_M_CanErr      : ((ID.Stall | ID.Flush) ? 1'b0 : ID_M_CanErr));
    EX.ReadData1      <= (RST) ? 32'b0 : ((EX.Stall) ? EX.ReadData1                                     : ID.ReadData1_End);
    EX.ReadData2      <= (RST) ? 32'b0 : ((EX.Stall) ? EX.ReadData2                                     : ID.ReadData2_End);
    EX.ExtImmOut      <= (RST) ? 32'b0 : ((EX.Stall) ? EX.ExtImmOut                                     : ID.ExtImmOut);
    EX.Rs             <= (RST) ? 5'b0  : ((EX.Stall) ? EX.Rs                                            : ID.Rs);
    EX.Rt             <= (RST) ? 5'b0  : ((EX.Stall) ? EX.Rt                                            : ID.Rt);

    // Hazard (Stall and Forwarding)
    EX.WantRsByEX     <= (RST) ? 1'b0  : ((EX.Stall) ? EX.WantRsByEX    : ((ID.Stall | ID.Flush) ? 1'b0 : ID.DP_Hazards[3]));
    EX.NeedRsByEX     <= (RST) ? 1'b0  : ((EX.Stall) ? EX.NeedRsByEX    : ((ID.Stall | ID.Flush) ? 1'b0 : ID.DP_Hazards[2]));
    EX.WantRtByEX     <= (RST) ? 1'b0  : ((EX.Stall) ? EX.WantRtByEX    : ((ID.Stall | ID.Flush) ? 1'b0 : ID.DP_Hazards[1]));
    EX.NeedRtByEX     <= (RST) ? 1'b0  : ((EX.Stall) ? EX.NeedRtByEX    : ((ID.Stall | ID.Flush) ? 1'b0 : ID.DP_Hazards[0]));
    // EX_KernelMode     <= (RST) ? 1'b0  : ((EX.Stall) ? EX_KernelMode                                    : ID_KernelMode);
  end

endmodule
