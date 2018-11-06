TARGET=cpu
.PHONY: all

$(TARGET):
	verilator -cc -I../rtl $(@).v -trace -exe testbench.cpp
	make -C obj_dir -f V$(@).mk
