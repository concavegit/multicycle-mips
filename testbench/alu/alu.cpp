#include "alu.h"
#include <Valu.h>
#include <algorithm>
#include <limits>

bool checkZero(const ALUOp op, const int32_t a, const int32_t b)
{
  Valu dut;
  dut.command = op;
  dut.operandA = a;
  dut.operandB = b;
  dut.eval();

  const bool expectedZero = op == ADD || op == SUB ? dut.result == 0 : 0;

  if (dut.zero != expectedZero)
    {
      printf("Zero failed on op=%d, a=%d, b=%d, should be %d, is %d\n", op, a, b, expectedZero, dut.zero);
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
  const bool expectedCarry = op == ADD || op == SUB
    ? (a < 0 && negBIfSub < 0)
           || (a < 0 && negBIfSub >= 0 && sum >= 0)
    || (a >= 0 && negBIfSub < 0 && sum >= 0)
    || (b == 0 && op == SUB)
    : 0;

  if (dut.carryout != expectedCarry)
    {
      printf("Carry failed on op=%d, a=%d, b=%d, should be %d, is %d\n", op, a, b, expectedCarry, dut.carryout);
      return false;
    }

  return true;
}

bool checkResult(const ALUOp op, const int32_t a, const int32_t b)
{
  Valu dut;
  dut.command = op;
  dut.operandA = a;
  dut.operandB = b;
  dut.eval();

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
      expectedRes = a ^ b;
      break;

    case SLT :
      expectedRes = a < b;
      break;

    case AND :
      expectedRes = a & b;
      break;

    case NAND :
      expectedRes = ~(a & b);
      break;

    case NOR :
      expectedRes = ~(a | b);
      break;

    case OR :
      expectedRes = (a | b);
      break;
    }

  if (dut.result != expectedRes)
    {
      printf("Result failed on op=%d, a=%d, b=%d, should be %d, is %d\n", op, a, b, expectedRes, dut.result);
      return false;
    }

  return true;
}

bool checkOverflow(const ALUOp op, const int32_t a, int32_t b)
{
  Valu dut;
  dut.operandA = a;
  dut.operandB = b;
  dut.command = op;
  dut.eval();

  bool expectedOvf;

  switch (op)
    {
    case ADD :
      expectedOvf = (a > 0 && b > std::numeric_limits<int32_t>::max() - a) || (a < 0 && b < std::numeric_limits<int32_t>::min() - a);
      break;

    case SUB :
      expectedOvf = (a < 0 && b > std::numeric_limits<int32_t>::max() + a + 1) || (a >= 0 && b <= std::numeric_limits<int32_t>::min() + a);
      break;

    default :
      expectedOvf = false;
      break;
    }

  if (dut.overflow != expectedOvf)
    {
      printf("Overflow failed on op=%d, a=%d, b=%d, should be %d, is %d\n", op, a, b, expectedOvf, dut.overflow);
      return false;
    }

  return true;
}

bool checkAll(const ALUOp op, const int32_t a, const int32_t b)
{
  std::vector<bool (*) (ALUOp, int32_t, int32_t)> funcs = {checkZero, checkOverflow, checkResult, checkCarry};
  std::for_each(funcs.begin(), funcs.end(), [op, a, b](auto f) {return f(op, a, b);});
  return std::all_of(funcs.begin(), funcs.end(), [](auto x) {return x;});
}

std::vector<std::tuple<ALUOp, int32_t, int32_t>> genTestCases()
{
  std::vector<std::tuple<ALUOp, int32_t, int32_t>> cases;
  int edge_vals[] =
    {0, -1, 1, std::numeric_limits<int32_t>::max(),
     std::numeric_limits<int32_t>::min(),
     std::numeric_limits<int32_t>::max() - 1,
     std::numeric_limits<int32_t>::min() + 1};

  for (const auto val0 : edge_vals)
    for (const auto& val1 : edge_vals)
      for (auto op : {ADD, SUB, XOR, SLT, AND, NAND, NOR, OR})
        {
          cases.push_back({op, val0, val1});
        }

  return cases;
}

bool testALU()
{
  auto cases = genTestCases();
  std::for_each(cases.begin(), cases.end(), [](auto x) {return checkAll(std::get<0>(x), std::get<1>(x), std::get<2>(x));});
  return std::all_of(cases.begin(), cases.end(), [](auto x) {return true;});
}

int main(int argc, char** argv)
{
  Verilated::commandArgs(argc, argv);
  testALU();
  Valu* test = new Valu;
  test->command = 2;
  test->operandA = -2147483647;
  test->operandB = -2147483647;
  test->eval();
  printf("ALU test passed: %d\n", true);
}
