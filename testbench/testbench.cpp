#include <verilated.h>
#include <Vcpu.h>
#include <stdio.h>
#include <verilated_fst_c.h>

int main(int argc, char** argv)
{
  Verilated::commandArgs(argc, argv);
  Vcpu dut;
}
