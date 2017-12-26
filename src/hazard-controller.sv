/*
 * Description:
 *   Hazard Detection and Forward Control. This is the glue that allows a
 *   pipelined processor to operate efficiently and correctly in the presence
 *   of data, structural, and control hazards. For each pipeline stage, it
 *   detects whether that stage requires data that is still in the pipeline,
 *   and whether that data may be forwarded or if the pipeline must be stalled.
 *
 *   This module is heavily commented. Read below for more information.
 */
module hazard_controller(
  input  [7:0] DP_Hazards,

  // intf
  intf_id.hazard_controller  ID,
  intf_ex.hazard_controller  EX,
  intf_mem.hazard_controller MEM,
  intf_wb.hazard_controller  WB,



  // I-Memory signal for IF_Stall
  input InstrMemReadEnable,
  input InstrMemAck,
  // ex) DIV stall
  input EX_ALU_Stall,
  // memory stall
  input M_Stall_Controller,  // Determined by data memory controller

  // stall
  output IF_Stall,
  output ID_Stall,
  output EX_Stall,
  output M_Stall,
  output WB_Stall
);

  /* Hazard and Forward Detection
   *
   * Most instructions read from one or more registers. Normally this occurs in
   * the ID stage. However, frequently the register file in the ID stage is stale
   * when one or more forward stages in the pipeline (EX, MEM, or WB) contains
   * an instruction which will eventually update it but has not yet done so.
   *
   * A hazard condition is created when a forward pipeline stage is set to write
   * the same register that a current pipeline stage (e.g. in ID) needs to read.
   * The solution is to stall the current stage (and effectively all stages behind
   * it) or bypass (forward) the data from forward stages. Fortunately forwarding
   * works for most combinations of instructions.
   *
   * Hazard and Forward conditions are handled based on two simple rules:
   * "Wants" and "Needs." If an instruction "wants" data in a certain pipeline
   * stage, and that data is available further along in the pipeline, it will
   * be forwarded. If it "needs" data and the data is not yet available for forwarding,
   * the pipeline stage stalls. If it does not want or need data in a certain
   * stage, forwarding is disabled and a stall will not occur. This is important
   * for instructions which insert custom data, such as jal or movz.
   *
   * Currently, "Want" and "Need" conditions are defined for both Rs data and Rt
   * data (the two read registers in MIPS), and these conditions exist in the
   * ID and EX pipeline stages. This is a total of eight condition bits.
   *
   * A unique exception exists with Store instructions, which don't need the
   * "Rt" data until the MEM stage. Because data doesn't change in WB, and WB
   * is the only stage following MEM, forwarding is *always* possible from
   * WB to Mem. This unit handles this situation, and a condition bit is not
   * needed.
   *
   * When data is needed from the MEM stage by a previous stage (ID or EX), the
   * decision to forward or stall is based on whether MEM is accessing memory
   * (stall) or not (forward). Normally store instructions don't write to registers
   * and thus are never needed for a data dependence, so the signal 'MEM.MemRead'
   * is sufficient to determine. Because of the Store Conditional instruction,
   * however, 'MEM.MemWrite' must also be considered because it writes to a register.
   *
   */

  wire WantRsByID, NeedRsByID, WantRtByID, NeedRtByID, WantRsByEX, NeedRsByEX, WantRtByEX, NeedRtByEX;
  assign WantRsByID = DP_Hazards[7];
  assign NeedRsByID = DP_Hazards[6];
  assign WantRtByID = DP_Hazards[5];
  assign NeedRtByID = DP_Hazards[4];
  assign WantRsByEX = DP_Hazards[3];
  assign NeedRsByEX = DP_Hazards[2];
  assign WantRtByEX = DP_Hazards[1];
  assign NeedRtByEX = DP_Hazards[0];

  // Trick allowed by RegDst = 0 which gives Rt. MEM_Rt is only used on
  // Data Memory write operations (stores), and RegWrite is always 0 in this case.
  wire [4:0] MEM_Rt = MEM.RegDstOut;

  // Forwarding should not happen when the src/dst register is $zero
  wire EX_RtRd_NZ  = (EX.RegDstOut  != 5'b00000);
  wire MEM_RtRd_NZ = (MEM.RegDstOut != 5'b00000);
  wire WB_RtRd_NZ  = (WB.RegDstOut  != 5'b00000);


  // ID Dependencies
  wire Rs_IDEX_Match  = (ID.Rs == EX.RegDstOut)  & EX_RtRd_NZ  & (WantRsByID | NeedRsByID) & EX.RegWrite;
  wire Rt_IDEX_Match  = (ID.Rt == EX.RegDstOut)  & EX_RtRd_NZ  & (WantRtByID | NeedRtByID) & EX.RegWrite;
  wire Rs_IDMEM_Match = (ID.Rs == MEM.RegDstOut) & MEM_RtRd_NZ & (WantRsByID | NeedRsByID) & MEM.RegWrite;
  wire Rt_IDMEM_Match = (ID.Rt == MEM.RegDstOut) & MEM_RtRd_NZ & (WantRtByID | NeedRtByID) & MEM.RegWrite;
  wire Rs_IDWB_Match  = (ID.Rs == WB.RegDstOut)  & WB_RtRd_NZ  & (WantRsByID | NeedRsByID) & WB.RegWrite;
  wire Rt_IDWB_Match  = (ID.Rt == WB.RegDstOut)  & WB_RtRd_NZ  & (WantRtByID | NeedRtByID) & WB.RegWrite;
  // EX Dependencies
  // RegDstOut is destination field
  wire Rs_EXMEM_Match = (EX.Rs == MEM.RegDstOut) & MEM_RtRd_NZ & (WantRsByEX | NeedRsByEX) & MEM.RegWrite;
  wire Rt_EXMEM_Match = (EX.Rt == MEM.RegDstOut) & MEM_RtRd_NZ & (WantRtByEX | NeedRtByEX) & MEM.RegWrite;
  wire Rs_EXWB_Match  = (EX.Rs == WB.RegDstOut)  & WB_RtRd_NZ  & (WantRsByEX | NeedRsByEX) & WB.RegWrite;
  wire Rt_EXWB_Match  = (EX.Rt == WB.RegDstOut)  & WB_RtRd_NZ  & (WantRtByEX | NeedRtByEX) & WB.RegWrite;
  // MEM Dependencies
  wire Rt_MEMWB_Match = (MEM_Rt == WB.RegDstOut) & WB_RtRd_NZ  & WB.RegWrite;


  // ID needs data from EX  : Stall
  wire ID_Stall_1 = (Rs_IDEX_Match  &  NeedRsByID);
  wire ID_Stall_2 = (Rt_IDEX_Match  &  NeedRtByID);
  // ID needs data from MEM : Stall if mem access
  wire ID_Stall_3 = (Rs_IDMEM_Match &  (MEM.MemRead | MEM.MemWrite) & NeedRsByID);
  wire ID_Stall_4 = (Rt_IDMEM_Match &  (MEM.MemRead | MEM.MemWrite) & NeedRtByID);
  // ID wants data from MEM : Forward if not mem access
  wire ID_Fwd_1   = (Rs_IDMEM_Match & ~(MEM.MemRead | MEM.MemWrite));
  wire ID_Fwd_2   = (Rt_IDMEM_Match & ~(MEM.MemRead | MEM.MemWrite));
  // ID wants/needs data from WB  : Forward
  wire ID_Fwd_3   = (Rs_IDWB_Match);
  wire ID_Fwd_4   = (Rt_IDWB_Match);
  // EX needs data from MEM : Stall if mem access
  wire EX_Stall_1 = (Rs_EXMEM_Match &  (MEM.MemRead | MEM.MemWrite) & NeedRsByEX);
  wire EX_Stall_2 = (Rt_EXMEM_Match &  (MEM.MemRead | MEM.MemWrite) & NeedRtByEX);
  // EX wants data from MEM : Forward if not mem access
  wire EX_Fwd_1   = (Rs_EXMEM_Match & ~(MEM.MemRead | MEM.MemWrite));
  wire EX_Fwd_2   = (Rt_EXMEM_Match & ~(MEM.MemRead | MEM.MemWrite));
  // EX wants/needs data from WB  : Forward
  wire EX_Fwd_3   = (Rs_EXWB_Match);
  wire EX_Fwd_4   = (Rt_EXWB_Match);
  // MEM needs data from WB : Forward
  wire MEM_Fwd_1  = (Rt_MEMWB_Match);


  // TODO: Stalls and Control Flow Final Assignments
  assign WB_Stall = M_Stall;
  assign  M_Stall = IF_Stall | M_Stall_Controller;
  assign EX_Stall = (EX_Stall_1 | EX_Stall_2 /*| EX_Exception_Stall*/) | EX_ALU_Stall | M_Stall;
  assign ID_Stall = (ID_Stall_1 | ID_Stall_2 | ID_Stall_3 | ID_Stall_4 /*| ID_Exception_Stall*/) | EX_Stall;
  assign IF_Stall = InstrMemReadEnable | InstrMemAck /*| IF_Exception_Stall*/;


  // TODO export Forwarding sel wire
  // Forwarding Control Final Assignments
  assign ID.RsFwdSel = (ID_Fwd_1) ? 2'b01 : ((ID_Fwd_3) ? 2'b10 : 2'b00);
  assign ID.RtFwdSel = (ID.Mfc0) ? 2'b11 : ((ID_Fwd_2) ? 2'b01 : ((ID_Fwd_4) ? 2'b10 : 2'b00));
  assign EX.RsFwdSel = (EX.Link) ? 2'b11 : ((EX_Fwd_1) ? 2'b01 : ((EX_Fwd_3) ? 2'b10 : 2'b00));
  assign EX.RtFwdSel = (EX.Link) ? 2'b11 : ((EX_Fwd_2) ? 2'b01 : ((EX_Fwd_4) ? 2'b10 : 2'b00));
  assign MEM.WriteDataFwdSel = MEM_Fwd_1;

endmodule
