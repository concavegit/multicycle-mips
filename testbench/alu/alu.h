/*
  Test ALU correctness.
 */
#pragma once

#include <cstdint>
#include <tuple>
#include <vector>

enum ALUOp {ADD, SUB, XOR, SLT, AND, NAND, NOR, OR};

bool checkZero(const ALUOp op, const int32_t a, const int32_t b);
bool checkCarry(const ALUOp op, const int32_t a, const int32_t b);
bool checkResult(const ALUOp op, const int32_t a, const int32_t b);
bool checkOverflow(const ALUOp op, const int32_t a, const int32_t b);
bool checkAll(const ALUOp op, const int32_t a, const int32_t b);
std::vector<std::tuple<ALUOp, int32_t, int32_t>> genTestCases();
bool testALU();
