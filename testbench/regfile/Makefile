TARGET=regfile
.PHONY: all

$(TARGET):
	verilator -cc -I../../rtl $(@).v -trace-fst -exe $(@).cpp
	make -C obj_dir -f V$(@).mk

run:
	./obj_dir/V$(TARGET)

clean:
	rm -rf obj_dir
