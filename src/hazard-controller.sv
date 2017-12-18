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
    input  EX_ALU_Stall,
    output EX_Stall
);

    assign EX_Stall = EX_ALU_Stall;

endmodule
