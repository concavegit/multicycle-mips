/**
 * Module Decode
 * Inputs: instruction (instr)
 * Outputs: rd, rs, sign extend immediate (sxi), jump address (jAddr),
 * command (cmd).
 * Function: Output the addresses and command for use in the CPU and FSM.
 */
`include "fsm.v"

module decode
  (
   input [31:0]     instr,
   output [4:0]     rd,
                    rt,
                    rs,
   output [31:0]    sxi,
   output [27:0]    jAddr,
   output reg [3:0] cmd
   );

   wire [5:0]       opcode, funct;

   localparam
     LW = 6'h23,
     SW = 6'h2b,
     J = 6'h2,
     JAL = 6'h3,
     BEQ = 6'h4,
     BNE = 6'h5,
     XORI = 6'he,
     ADDI = 6'h8,

     R_JR = 6'h8,
     R_ADD = 6'h20,
     R_SUB = 6'h22,
     R_SLT = 6'h2a;

   assign
     rd = instr[15:11],
     rt = instr[20:16],
     rs = instr[25:21],
     sxi = {{16{instr[15]}}, instr[15:0]},
     jAddr = {instr[25:0], 2'b0};

   always @(opcode, funct) begin
      case (opcode)
        LW : cmd = `LW;
        SW : cmd = `SW;
        J : cmd = `J;
        JAL : cmd = `JAL;
        BEQ : cmd = `BEQ;
        BNE : cmd = `BNE;
        XORI : cmd = `XORI;
        ADDI : cmd = `ADDI;
        default :
          case (funct)
            R_JR : cmd = `JR;
            R_ADD : cmd = `ADD;
            R_SUB : cmd = `SUB;
            R_SLT : cmd = `SLT;
          endcase
      endcase
   end
endmodule
