# mips-subset
**An implementation of a subset of MIPS CPU**



 Description and block diagram of  processor architecture.

![alt text](https://github.com/concavegit/mips-subset/blob/master/CPU%20schematic.jpg
)

This the block diagram of our single cycle CPU. All the red wires are control signals coming from the decoder. 
For an example insturction **addi $t0, $t0, 2**

The relevant control signals would be set in the following way by the decoder


- **RS** = address of $t0


- **ALU_B_SRC_CTRL** = 1(to choose immediate instead of the data in register RT)


- **reg_we**= 1 ( write enable would be 1)


- **reg_write_address** = address of $t0


- **PC_SRC_CTRL** = 00(Increments PC by 4 as it should as there is no branch or jump command)


- **dm_we** = 0 (as the data memory would not be written to)




# Description of our test plan and result
This is a waveform with all decoder and regfile ports exposed. This helped us catch many errors such as BNE needing to jump to PC+4+IMM<<2, rather than PC + IMM<<2. This also helped us see that our mux inputs for BNE were swapped.

![](res/gtkwave.png)

For the testing we had a 3 pronged approach. 

- Number 1 was to test all the components individually using Verilog test benches. This helped us debug the integration later too as we could test specific functions of the components using the test-benches.

- Number 2 was to write unit tests for all the functions our CPU was capable of doing. This helped us debug control signals and the integration. All the unit tests worked fine.

- Number 3 was to write more complex assembly code. We ran programs which calculated the nth Fibonacci term and the sum of N natural numbers, these used multiple immediate and branch functions.
  The testbench prints out the current instruction, pc value, the active regfile address, and the active datamemory address.
  The most important feature, however, was both checking the final contents of $v0 for the correct return value as well as a waveform with filters applied.
  
Some performance/area analysis of your design. This can be for the full processor, or a case study of choices made designing a single unit.It can be based on calculation, simulation, Vivado synthesis results, or a mix of all three.

# Test Benches

- CPU Operations: We created a test for each of the 12 assembly operations we implemented.

- Regfile: We write values to all registers with both write enable possibilities, checking for changes and consistencies with asserts. We also make sure that $zero is always zero in these processes. We also made sure that both read and write ports were decoupled via asserts.

- ALU: We used a testbench which checks 1024 cases on all 8 operations on all 8 configurations of positive or negative inputs and outputs. This is a verilator testbench.

- CPU: We used a summation testbench, knowing that the final value of $v0 should be 120, the sum of natural numbers to 15.

- Decoder: We randomly chose strings to test each operation, checking the values of the decoder outputs and asserting them.

# Challenges
The first order of business was testing the decoder, which was a day of work.
After wiring the decoder into our CPU, we ran some assembly files and realized that our summation assembly did not work.
Therefore, we spent a long time going over the waveforms to catch errors in BNE (the RTL is PC + 4 + IMM << 2, not PC + IMM<<2 for the jump) and various muxes.
Designing a testbench for monitoring elements of memory was difficult.
In the end, we decided to only monitor the final contents of $v0, using the waveforms and $display statements when necessary.

# Performance
Our design from the circuit diagram seems optimal enough at a high level.
We do not repeat components except for muxes at a high level.
The only change we would make would be switching the inputs of the BNE mux inputs and using an NXOR rather than an XOR gate and reducing area/delay cost.
However, using 1 to load the immediate seemed logical making the design, and it would have only been a gate cost of 1.

The ALU is the most complicated component of the CPU, as it does not comprise almost entirely of DFFs and muxes.
By not explicitly re-calculating the two most significant carries to compute overflow and using bit slices rather than the LUT strategy implied by our behavioral ALU, we could have saved a few gate units.

# Work plan reflection

According to the workplan we wanted to started wiring up the CPU completely by the last wednesday and complete by saturday, which is something we were successfully able to do. We then started writing the assembly unit tests and test files along with improving the test benches for debugging. We were able to do that by this wednesday. Since then we have been debugging our integrated CPU. We were able to iron out all of the bugs.
As opposed to the last lab, we allocated enough time (half a week) to debugging and did not go crazy at midnight.
