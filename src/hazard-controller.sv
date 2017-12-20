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
   * and thus are never needed for a data dependence, so the signal 'MEM_MemRead'
   * is sufficient to determine. Because of the Store Conditional instruction,
   * however, 'MEM_MemWrite' must also be considered because it writes to a register.
   *
   */

  // TODO: Stalls and Control Flow Final Assignments
  assign WB_Stall = M_Stall;
  assign  M_Stall = IF_Stall | M_Stall_Controller;
  assign EX_Stall = /*(EX_Stall_1 | EX_Stall_2 | EX_Exception_Stall) |*/ EX_ALU_Stall | M_Stall;
  assign ID_Stall = /*(ID_Stall_1 | ID_Stall_2 | ID_Stall_3 | ID_Stall_4 | ID_Exception_Stall) |*/ EX_Stall;
  assign IF_Stall = InstrMemReadEnable | InstrMemAck /*| IF_Exception_Stall*/;

endmodule
