module memwb_stage(
  input logic CLK, RST,
  intf_mem.memwb_in MEM,
  intf_wb.memwb_out WB
);

  always @(posedge CLK) begin
    // control signals
    WB.RegWrite    <= (RST) ? 1'b0  : ((WB.Stall) ? WB.RegWrite   : ((MEM.Stall | MEM.Flush) ? 1'b0 : MEM.RegWrite));
    WB.MemtoReg    <= (RST) ? 1'b0  : ((WB.Stall) ? WB.MemtoReg                                     : MEM.MemtoReg);

    WB.ALUResult   <= (RST) ? 32'b0 : ((WB.Stall) ? WB.ALUResult                               : MEM.ALUResult);
    WB.RegDstOut   <= (RST) ? 5'b0  : ((WB.Stall) ? WB.RegDstOut                               : MEM.RegDstOut);
    WB.MemReadData <= (RST) ? 32'b0 : ((WB.Stall) ? WB.MemReadData                             : MEM.MemReadData);
  end

endmodule
