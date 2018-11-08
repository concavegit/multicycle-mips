#pragma once

#include <Vregfile.h>

vluint64_t main_time;
double sc_time_stamp();
bool writeRegs(Vregfile& dut, uint32_t dIn);
bool readRegs(Vregfile& dut);
bool testReg(Vregfile& dut);

