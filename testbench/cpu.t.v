`include "../rtl/cpu.v"
module cputest();
   reg clk;
   reg [16:0] counter;
   initial begin
      clk = 0;
      counter = 0;
   end

   cpu #(.mem("mem/sum1.dat")) dut(clk);
   always #1 clk = ~clk;

   always #2 begin
      $display("Instruction #: %d", counter);
      $display("Instruction: %h", dut.decoder0.instr);
      $display("pc: %d", dut.pc);
      $display("Active Regfile Address: %d", dut.decoder0.regWAddr);
      $display("Active DataMemory Address: %d", dut.mem0.addr);
      $display("");
      // $display("%h, %h, %h", dut.instr, dut.pc, dut.dmOut);
      // $display("%h", dut.regfile0.mem[0]);
      counter = counter + 1;
   end

   initial begin
      $dumpfile("cpu.vcd");
      $dumpvars();
      $display("%h, %h", dut.instr, dut.pc, dut.dmOut);
      #4096 $display("Contents of v0: %d", dut.regfile0.registers[2]);
      $finish;
   end
endmodule
