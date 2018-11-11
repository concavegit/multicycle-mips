`include "decode.v"
`include "alu.v"
`include "regfile.v"
`include "memory.v"
`include "mux4way.v"
`include "mux.v"

module cpu
  #(parameter instruction="mem/data.dat")
   (input clk);

   wire [31:0] sxi;
   wire [4:0]  rd, rt, rs;
   wire [27:0] jAddr28;
   wire [3:0]  cmd;
   reg [31:0]  ir;

   decode decode0
     (
      .instr(ir),
      .rd(rd),
      .rt(rt),
      .rs(rs),
      .sxi(sxi),
      .jAddr(jAddr28),
      .cmd(cmd)
      );

   wire        eq, pcWe, memWe, irWe, aWe, bWe, regWe, regIn, aluSrcA, memIn, dst;
   wire [2:0]  aluOp;
   wire [1:0]  pcSrc, aluSrcB;

   fsm fsm0
     (
      .clk(clk),
      .eq(eq),
      .cmd(cmd),
      .aluOp(aluOp),
      .pcSrc(pcSrc),
      .aluSrcB(aluSrcB),
      .pcWe(pcWe),
      .memWe(memWe),
      .irWe(irWe),
      .aWe(aWe),
      .bWe(bWe),
      .regWe(regWe),
      .regIn(regIn),
      .aluSrcA(aluSrcA),
      .memIn(memIn),
      .dst(dst)
      );

   reg [31:0]  pc, a, b;
   wire [31:0] aluA, aluB, result;
   wire        zero, overflow;

   and eqAnd(eq, zero, !overflow);

   mux aluAMux
     (
      .out(aluA),
      .sel(aluSrcA),
      .in0(pc),
      .in1(a)
      );

   mux4way aluBMux
     (
      .out(aluB),
      .sel(aluSrcB),
      .in0(sxi<<2),
      .in1(sxi),
      .in2(b),
      .in3(4)
      );

   alu alu0
     (
      .result(result),
      .zero(zero),
      .overflow(overflow),
      .operandA(aluA),
      .operandB(aluB),
      .command(aluOp)
      );

   wire [31:0] dOut, memAddr;
   reg [31:0]  ffResult;
   always @(posedge clk) ffResult <= result;

   mux memAddrMux
     (
      .out(memAddr),
      .sel(memIn),
      .in0(pc),
      .in1(ffResult)
      );

   memory mem0
     (
      .dOut(dOut),
      .clk(clk),
      .addr(memAddr),
      .we(memWe),
      .dIn(b)
      );

   wire [31:0] dOut0, dOut1, regDIn;
   wire [4:0]  writeAddr;

   mux #(.width(5)) writeAddrMux
     (
      .out(writeAddr),
      .sel(dst),
      .in0(rd),
      .in1(rt)
      );

   mux regDInMux
     (
      .out(regDIn),
      .sel(regIn),
      .in0(dOut),
      .in1(ffResult)
      );

   regfile regfile0
     (
      .dOut0(dOut0),
      .dOut1(dOut1),
      .dIn(regDIn),
      .readAddr0(rs),
      .readAddr1(rt),
      .writeAddr(writeAddr),
      .we(regWe),
      .clk(clk)
      );

   wire [31:0] pcIn;

   assign pcIn = pcSrc[1] ? pcSrc[0] ? a : {pc[31:28], jAddr28} : pcSrc[0] ? result : ffResult;

   always @(posedge clk) begin
      if (aWe) a <= dOut0;
      if (bWe) b <= dOut1;
      if (irWe) ir <= dOut;
      if (pcWe) pc <= pcIn;
   end

endmodule
