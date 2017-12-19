/***
 The purpose of a pipeline register is to capture data from one pipeline stage
 and provide it to the next pipeline stage. This creates at least one clock cycle
 of delay, but reduces the combinatorial path length of signals which allows for
 higher clock speeds.
 All pipeline registers update unless the forward stage is stalled. When this occurs
 or when the current stage is being flushed, the forward stage will receive data that
 is effectively a NOP and causes nothing to happen throughout the remaining pipeline
 traversal. In other words:
 A stall masks all control signals to forward stages. A flush permanently clears
 control signals to forward stages (but not certain data for exception purposes).
***/
module idex_stage(
  input logic CLK, RST,

  intf_id.idex_in  ID,
  intf_ex.idex_out EX,




  // stall signals
  input  ID_Flush,
  input  ID_Stall,

  // Control signals
  input  [4:0] ID_ALUOp,

  output reg [4:0] EX_ALUOp
);

  // reg EX_RegDst;
  // assign EX_LinkRegDst = (EX_Link) ? 2'b10 : ((EX_RegDst) ? 2'b01 : 2'b00);

  // NOTE: why is this needed ?
  // reg [16:0] EX_SignExtImm_pre;
  // assign EX_Rd = EX_SignExtImm[15:11];
  // assign EX_Shamt = EX_SignExtImm[10:6];
  // assign EX_SignExtImm = (EX_SignExtImm_pre[16]) ? {15'h7fff, EX_SignExtImm_pre[16:0]} : {15'h0000, EX_SignExtImm_pre[16:0]};

  assign EX.Rd = EX.ExtImmOut[15:11];
  assign EX.Shamt = EX.ExtImmOut[10:6];

  always @(posedge CLK) begin
    EX_ALUOp          <= (RST) ? 5'b0  : ((EX.Stall) ? EX_ALUOp         : ((ID_Stall | ID_Flush) ? 5'b0 : ID_ALUOp));
    // EX_Link           <= (RST) ? 1'b0  : ((EX.Stall) ? EX_Link                                          : ID_Link);
    // EX_RegDst         <= (RST) ? 1'b0  : ((EX.Stall) ? EX_RegDst                                        : ID_RegDst);
    EX.ALUSrcImm      <= (RST) ? 1'b0  : ((EX.Stall) ? EX.ALUSrcImm                                     : ID.ALUSrcImm);
    // EX_Movn           <= (RST) ? 1'b0  : ((EX.Stall) ? EX_Movn                                          : ID_Movn);
    // EX_Movz           <= (RST) ? 1'b0  : ((EX.Stall) ? EX_Movz                                          : ID_Movz);
    // EX_LLSC           <= (RST) ? 1'b0  : ((EX.Stall) ? EX_LLSC                                          : ID_LLSC);
    // EX_MemRead        <= (RST) ? 1'b0  : ((EX.Stall) ? EX_MemRead       : ((ID_Stall | ID_Flush) ? 1'b0 : ID_MemRead));
    // EX_MemWrite       <= (RST) ? 1'b0  : ((EX.Stall) ? EX_MemWrite      : ((ID_Stall | ID_Flush) ? 1'b0 : ID_MemWrite));
    // EX_MemByte        <= (RST) ? 1'b0  : ((EX.Stall) ? EX_MemByte                                       : ID_MemByte);
    // EX_MemHalf        <= (RST) ? 1'b0  : ((EX.Stall) ? EX_MemHalf                                       : ID_MemHalf);
    // EX_MemSignExtend  <= (RST) ? 1'b0  : ((EX.Stall) ? EX_MemSignExtend                                 : ID_MemSignExtend);
    // EX_Left           <= (RST) ? 1'b0  : ((EX.Stall) ? EX_Left                                          : ID_Left);
    // EX_Right          <= (RST) ? 1'b0  : ((EX.Stall) ? EX_Right                                         : ID_Right);
    // EX_RegWrite       <= (RST) ? 1'b0  : ((EX.Stall) ? EX_RegWrite      : ((ID_Stall | ID_Flush) ? 1'b0 : ID_RegWrite));
    // EX_MemtoReg       <= (RST) ? 1'b0  : ((EX.Stall) ? EX_MemtoReg                                      : ID_MemtoReg);
    // EX_ReverseEndian  <= (RST) ? 1'b0  : ((EX.Stall) ? EX_ReverseEndian                                 : ID_ReverseEndian);
    // EX_RestartPC      <= (RST) ? 32'b0 : ((EX.Stall) ? EX_RestartPC                                     : ID_RestartPC);
    // EX_IsBDS          <= (RST) ? 1'b0  : ((EX.Stall) ? EX_IsBDS                                         : ID_IsBDS);
    // EX_Trap           <= (RST) ? 1'b0  : ((EX.Stall) ? EX_Trap          : ((ID_Stall | ID_Flush) ? 1'b0 : ID_Trap));
    // EX_TrapCond       <= (RST) ? 1'b0  : ((EX.Stall) ? EX_TrapCond                                      : ID_TrapCond);
    // EX_EX_CanErr      <= (RST) ? 1'b0  : ((EX.Stall) ? EX_EX_CanErr     : ((ID_Stall | ID_Flush) ? 1'b0 : ID_EX_CanErr));
    // EX_M_CanErr       <= (RST) ? 1'b0  : ((EX.Stall) ? EX_M_CanErr      : ((ID_Stall | ID_Flush) ? 1'b0 : ID_M_CanErr));
    EX.ReadData1      <= (RST) ? 32'b0 : ((EX.Stall) ? EX.ReadData1                                     : ID.ReadData1);
    EX.ReadData2      <= (RST) ? 32'b0 : ((EX.Stall) ? EX.ReadData2                                     : ID.ReadData2);
    EX.ExtImmOut      <= (RST) ? 32'b0 : ((EX.Stall) ? EX.ExtImmOut                                     : ID.ExtImmOut);
    // EX_Rs             <= (RST) ? 5'b0  : ((EX.Stall) ? EX_Rs                                            : ID_Rs);
    // EX_Rt             <= (RST) ? 5'b0  : ((EX.Stall) ? EX_Rt                                            : ID_Rt);
    // EX_WantRsByEX     <= (RST) ? 1'b0  : ((EX.Stall) ? EX_WantRsByEX    : ((ID_Stall | ID_Flush) ? 1'b0 : ID_WantRsByEX));
    // EX_NeedRsByEX     <= (RST) ? 1'b0  : ((EX.Stall) ? EX_NeedRsByEX    : ((ID_Stall | ID_Flush) ? 1'b0 : ID_NeedRsByEX));
    // EX_WantRtByEX     <= (RST) ? 1'b0  : ((EX.Stall) ? EX_WantRtByEX    : ((ID_Stall | ID_Flush) ? 1'b0 : ID_WantRtByEX));
    // EX_NeedRtByEX     <= (RST) ? 1'b0  : ((EX.Stall) ? EX_NeedRtByEX    : ((ID_Stall | ID_Flush) ? 1'b0 : ID_NeedRtByEX));
    // EX_KernelMode     <= (RST) ? 1'b0  : ((EX.Stall) ? EX_KernelMode                                    : ID_KernelMode);
  end

endmodule
