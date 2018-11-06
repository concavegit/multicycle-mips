#include "alu.h"
#include <Valu.h>

bool checkZero(const ALUOp op, const int32_t a, const int32_t b)
{
  Valu dut;
  dut.command = op;
  dut.operandA = a;
  dut.operandB = b;
  dut.eval();

  bool expectedZero = op == ADD || op == SUB ? dut.result == 0 : 0;

  if (dut.zero != expectedZero)
    {
      printf("Zero failed on op=%d, a=%d, b=%d, should be %d, is %d", op, a, b, expectedZero, dut.zero);
      return false;
    }

  return true;
}

bool checkCarry(const ALUOp op, const int32_t a, const int32_t b)
{
  Valu dut;
  dut.command = op;
  dut.operandA = a;
  dut.operandB = b;
  dut.eval();

  int32_t negBIfSub = op == SUB ? -b : b;
  int32_t sum = a + negBIfSub;
  bool expectedCarry = op == ADD || op == SUB
    ? (a < 0 && negBIfSub < 0)
           || (a < 0 && negBIfSub >= 0 && sum >= 0)
    || (a >= 0 && negBIfSub < 0 && sum >= 0)
    || (b == 0 && op == SUB)
    : 0;

  if (dut.carryout != expectedCarry)
    {
      printf("Carry failed on op=%d, a=%d, b=%d, should be %d, is %d", op, a, b, expectedCarry, dut.carryout);
      return false;
    }

  return true;
}

bool checkResult(const ALUOp op, const int32_t a, const int32_t b)
{
  int32_t expectedRes;
  switch(op)
    {
    case ADD :
      expectedRes = a + b;
      break;

    case SUB :
      expectedRes = a - b;
      break;

    case XOR :
      expectedRes = a | b;
      break;

    case SLT :
      expectedRes = a < b;
      break;

    case AND :
      expectedRes = a & b;
      break;
    }
}
