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

   reg [4:0]        prevState;
   reg [4:0]        state;

   initial state = 0;
   always @(prevState, cmd) begin
      case (prevState)
        `IF :
          if (cmd == `BNE || cmd == `BEQ) state = `ID_B;
          else if (cmd == `J || cmd == `JAL) state = `ID_J;
          else state = `ID_X;
        `ID_B : state = (cmd == `BEQ) ? `EX_BEQ : `EX_BNE;
        `ID_J : state = (cmd == `J) ? `IF : `EX_BNE;
        `ID_X :
          case (cmd)
            `JR : state = `EX_JR;
            `SUB : state = `EX_SUB;
            `ADD : state = `EX_ADD;
            `SLT : state = `EX_SLT;
            default : state = `EX_LWSWADDI;
          endcase

        `EX_BEQ : state = `IF;
        `EX_BNE : state = `IF;
        `EX_JR : state = `IF;
        `EX_SUB : state = `WB_SUBADDSLT;
        `EX_ADD : state = `WB_SUBADDSLT;
        `EX_SLT : state = `WB_SUBADDSLT;
        `EX_XORI : state = `WB_ADDIXORI;
        `EX_LWSWADDI :
          if (cmd == `ADDI) state = `WB_ADDIXORI;
          else if (cmd == `SW) state = `MEM_SW;
          else state = `MEM_LW;
        `MEM_LW : state = `WB_LW;
        `MEM_SW : state = `IF;
        default : state = `IF;
      endcase
   end

   
   always @(posedge clk) begin
      case (state)
        `IF : begin
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
        end

        `ID_X : begin
           aWe <= 1;
           bWe <= 1;
           irWe <= 0;
           memWe <= 0;
           pcWe <= 0;
           regWe <= 0;
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
        end

        `EX_JR : begin
           pcSrc <= `PC_SRC_A;
           aWe <= 0;
           bWe <= 0;
           irWe <= 0;
           memWe <= 0;
           pcWe <= 1;
           regWe <= 0;
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
        end

        `MEM_LW : begin
           memIn <= `MEM_ALU_RES;

           aWe <= 0;
           bWe <= 0;
           irWe <= 0;
           memWe <= 0;
           pcWe <= 0;
           regWe <= 0;
        end

        `MEM_SW : begin
           memIn <= `MEM_ALU_RES;

           aWe <= 0;
           bWe <= 0;
           irWe <= 0;
           memWe <= 1;
           pcWe <= 0;
           regWe <= 0;
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
        end
      endcase
      prevState <= state;
   end
endmodule
