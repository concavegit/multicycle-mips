/**
 * Module FSM
 * Inputs: clock (clk), equality boolean (eq), command (cmd).
 * Outputs: Control signals for the multicycle CPU.
 * Function: Output the control signals for the multicycle CPU.
 */
`define MEM_PC 0
`define MEM_ALU_RES 1
`define DST_RD 0
`define DST_RT 1
`define PC_SRC_ALU_RES 0
`define PC_SRC_ALU 1
`define PC_SRC_J 2
`define PC_SRC_A 3
`define ALU_SRC_A_PC 0
`define ALU_SRC_A_A 1
`define ALU_SRC_B_SXIS 0
`define ALU_SRC_B_SXI 1
`define ALU_SRC_B_B 2
`define ALU_SRC_B_4 3
`define REG_IN_MDR 0
`define REG_IN_ALU_RES 1

`define IF 0
`define ID_B 1
`define ID_J 2
`define ID_X 3
`define EX_BEQ 4
`define EX_BNE 5
`define EX_JR 6
`define EX_SUB 7
`define EX_ADD 8
`define EX_SLT 9
`define EX_XORI 10
`define EX_LWSWADDI 11
`define MEM_LW 12
`define MEM_SW 13
`define WB_JAL 14
`define WB_SUBADDSLT 15
`define WB_ADDIXORI 16
`define WB_LW 17

`define ALU_ADD 0
`define ALU_SUB 1
`define ALU_XOR 2
`define ALU_SLT 3
`define ALU_AND 4
`define ALU_NAND 5
`define ALU_NOR 6
`define ALU_OR 7

`define LW 0
`define SW 1
`define J 2
`define JR 3
`define JAL 4
`define BEQ 5
`define BNE 6
`define XORI 7
`define ADDI 8
`define ADD 9
`define SUB 10
`define SLT 11

module fsm
  (
   input            clk,
                    eq,
   input [3:0]      cmd,
   output reg [2:0] aluOp,
   output reg [1:0] pcSrc,
                    aluSrcB,
   output reg       pcWe,
   memWe,
   irWe,
   aWe,
   bWe,
   regWe,
   regIn,
   aluSrcA,
   memIn,
   dst
   );

   reg [4:0]        state;
   reg [3:0]        ffCmd;
   initial state = `IF;
   always @(posedge clk) begin
      case (state)
        `IF : begin
           ffCmd <= cmd;
           pcSrc <= `PC_SRC_ALU;
           aluSrcA <= `ALU_SRC_A_PC;
           aluSrcB <= `ALU_SRC_B_4;
           aluOp <= `ALU_ADD;
           memIn <= `MEM_PC;

           aWe <= 0;
           bWe <= 0;
           irWe <= 1;
           memWe <= 0;
           pcWe <= 1;
           regWe <= 0;

           if (ffCmd == `BNE || ffCmd == `BEQ) state <= `ID_B;
           else if (ffCmd == `J || ffCmd == `JAL) state <= `ID_J;
           else state <= `ID_X;

        end

        `ID_B : begin
           aluSrcA <= `ALU_SRC_A_PC;
           aluSrcB <= `ALU_SRC_B_SXIS;
           aluOp <= `ALU_ADD;

           aWe <= 1;
           bWe <= 1;
           irWe <= 0;
           memWe <= 0;
           pcWe <= 0;
           regWe <= 0;

           state <= (state == `BEQ) ? `EX_BEQ : `EX_BNE;
        end

        `ID_J : begin
           pcSrc <= `PC_SRC_J;
           aluSrcA <= `ALU_SRC_A_PC;
           aluSrcB <= `ALU_SRC_B_4;
           aluOp <= `ALU_ADD;

           aWe <= 0;
           bWe <= 0;
           irWe <= 0;
           memWe <= 0;
           pcWe <= 1;
           regWe <= 0;

           state <= (state == `J) ? `IF : `WB_JAL;
        end

        `ID_X : begin
           aWe <= 1;
           bWe <= 1;
           irWe <= 0;
           memWe <= 0;
           pcWe <= 0;
           regWe <= 0;

           case (ffCmd)
             `JR : state <= `EX_JR;
             `SUB : state <= `EX_SUB;
             `ADD : state <= `EX_ADD;
             `SLT : state <= `EX_SLT;
             `XORI : state <= `XORI;
             default : state <= `EX_LWSWADDI;
           endcase
        end

        `EX_BEQ : begin
           aluSrcA <= `ALU_SRC_A_A;
           aluSrcB <= `ALU_SRC_B_B;
           aluOp <= `ALU_SUB;
           pcSrc <= `PC_SRC_ALU_RES;

           aWe <= 0;
           bWe <= 0;
           irWe <= 0;
           memWe <= 0;
           pcWe <= eq;
           regWe <= 0;

           state <= `IF;
        end

        `EX_BNE : begin
           aluSrcA <= `ALU_SRC_A_A;
           aluSrcB <= `ALU_SRC_B_B;
           aluOp <= `ALU_SUB;
           pcSrc <= `PC_SRC_ALU_RES;

           aWe <= 0;
           bWe <= 0;
           irWe <= 0;
           memWe <= 0;
           pcWe <= !eq;
           regWe <= 0;

           state <= `IF;
        end

        `EX_JR : begin
           pcSrc <= `PC_SRC_A;
           aWe <= 0;
           bWe <= 0;
           irWe <= 0;
           memWe <= 0;
           pcWe <= 1;
           regWe <= 0;

           state <= `IF;
        end

        `EX_SUB : begin
           aluSrcA <= `ALU_SRC_A_A;
           aluSrcB <= `ALU_SRC_B_B;
           aluOp <= `ALU_SUB;

           aWe <= 0;
           bWe <= 0;
           irWe <= 0;
           memWe <= 0;
           pcWe <= 0;
           regWe <= 0;

           state <= `WB_SUBADDSLT;
        end

        `EX_ADD : begin
           aluSrcA <= `ALU_SRC_A_A;
           aluSrcB <= `ALU_SRC_B_B;
           aluOp <= `ALU_ADD;

           aWe <= 0;
           bWe <= 0;
           irWe <= 0;
           memWe <= 0;
           pcWe <= 0;
           regWe <= 0;

           state <= `WB_SUBADDSLT;
        end

        `EX_SLT : begin
           aluSrcA <= `ALU_SRC_A_A;
           aluSrcB <= `ALU_SRC_B_B;
           aluOp <= `ALU_SLT;

           aWe <= 0;
           bWe <= 0;
           irWe <= 0;
           memWe <= 0;
           pcWe <= 0;
           regWe <= 0;

           state <= `WB_SUBADDSLT;
        end

        `EX_XORI : begin
           aluSrcA <= `ALU_SRC_A_A;
           aluSrcB <= `ALU_SRC_B_SXI;
           aluOp <= `ALU_XOR;

           aWe <= 0;
           bWe <= 0;
           irWe <= 0;
           memWe <= 0;
           pcWe <= 0;
           regWe <= 0;

           state <= `WB_ADDIXORI;
        end

        `EX_LWSWADDI : begin
           aluSrcA <= `ALU_SRC_A_A;
           aluSrcB <= `ALU_SRC_B_SXI;
           aluOp <= `ALU_ADD;

           aWe <= 0;
           bWe <= 0;
           irWe <= 0;
           memWe <= 0;
           pcWe <= 0;
           regWe <= 0;

           case (ffCmd)
             `ADDI : state <= `WB_ADDIXORI;
             `SW : state <= `MEM_SW;
             default : state <= `MEM_LW;
           endcase
        end

        `MEM_LW : begin
           memIn <= `MEM_ALU_RES;

           aWe <= 0;
           bWe <= 0;
           irWe <= 0;
           memWe <= 0;
           pcWe <= 0;
           regWe <= 0;

           state <= `WB_LW;
        end

        `MEM_SW : begin
           memIn <= `MEM_ALU_RES;

           aWe <= 0;
           bWe <= 0;
           irWe <= 0;
           memWe <= 1;
           pcWe <= 0;
           regWe <= 0;

           state <= `IF;
        end

        `WB_JAL : begin
           dst <= `DST_RD;
           regIn <= `REG_IN_ALU_RES;

           aWe <= 0;
           bWe <= 0;
           irWe <= 0;
           memWe <= 0;
           pcWe <= 0;
           regWe <= 1;

           state <= `IF;
        end

        `WB_SUBADDSLT : begin
           dst <= `DST_RD;
           regIn <= `REG_IN_ALU_RES;

           aWe <= 0;
           bWe <= 0;
           irWe <= 0;
           memWe <= 0;
           pcWe <= 0;
           regWe <= 1;

           state <= `IF;
        end

        `WB_ADDIXORI : begin
           dst <= `DST_RT;
           regIn <= `REG_IN_ALU_RES;

           aWe <= 0;
           bWe <= 0;
           irWe <= 0;
           memWe <= 0;
           pcWe <= 0;
           regWe <= 1;

           state <= `IF;
        end

        `WB_LW : begin
           dst <= `DST_RT;
           regIn <= `REG_IN_MDR;

           aWe <= 0;
           bWe <= 0;
           irWe <= 0;
           memWe <= 0;
           pcWe <= 0;
           regWe <= 1;

           state <= `IF;
        end
      endcase
   end
endmodule
