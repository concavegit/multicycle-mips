#include "regfile.h"
#include <algorithm>
#include <verilated_fst_c.h>

// vluint64_t main_time = 0;
// double sc_time_stamp() { return main_time; }

bool writeRegs(Vregfile& dut, const uint32_t dIn)
{
  std::vector<bool> results;
  dut.we = true;
  dut.clk = false;
  dut.dIn = dIn;
  dut.eval();

  for (auto i = 0; i < 32; i++)
    {
      dut.writeAddr = i;

      dut.clk = true;
      dut.eval();
      dut.clk = false;
      dut.eval();
    }

  const auto regVals = dut.regfile__DOT__registers;

  for (auto i = 0; i < 32; i++)
    {
      const auto expected = i == 0 ? 0 : dIn;
      results.push_back(regVals[i] == expected);
      if (regVals[i] != expected)
        printf("Write test: Regfile address %d contains %d, should be %d\n", i, regVals[i], expected);
    }

  return std::all_of(results.begin(), results.end(), [](auto x) { return x; });
}

bool readRegs(Vregfile& dut)
{
  std::vector<bool> results;
  const auto initialState = dut.regfile__DOT__registers;
  dut.dIn = 99;
  dut.we = true;
  dut.clk = false;

  for (auto i = 0; i < 32; i++)
    {
      dut.we = true;
      dut.dIn = 99;
      dut.readAddr0 = i;
      dut.readAddr1 = 31 - i;

      dut.clk = true;
      dut.eval();
      dut.clk = false;
      dut.eval();

      results.push_back(initialState[i] == dut.dOut0 && initialState[31-i] == dut.dOut1);
      printf("%d, %d\n", initialState[i], dut.dOut0);

      if (initialState[i] != dut.dOut0)
        printf("Read test: Regfile address %d contains %d, should be %d\n", i, dut.readAddr0, initialState[i]);

      if (initialState[31 - i] != dut.dOut1)
        printf("Read test: Regfile address %d contains %d, should be %d\n", 31 - i, dut.readAddr1, initialState[31 - i]);
    }

  return std::all_of(results.begin(), results.end(), [](auto x) { return x; });
}

bool testReg(Vregfile& dut)
{
  // VerilatedFstC tfp;
  auto a = writeRegs(dut, 100);
  // auto b = readRegs(dut);
  return true;
}

int main(int argc, char** argv)
{
  Verilated::commandArgs(argc, argv);
  Vregfile dut;
  // dut.readAddr0 = 15;
  // dut.readAddr1 = 15;
  // dut.writeAddr = 15;
  // dut.we = true;
  // dut.dIn = 32;
  // dut.clk = false;
  // dut.eval();
  // dut.clk = true;
  // dut.eval();
  // printf("%d\n", dut.dOut0);
  writeRegs(dut, 2);
  readRegs(dut);
}
