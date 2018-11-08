.PHONY: all
TARGETS=alu regfile

default:
	for target in $(TARGETS); do \
		make -C $$target; \
	done

run:
	for target in $(TARGETS); do \
		make -C $$target run; \
	done

clean:
	for target in $(TARGETS); do \
		make -C $$target clean; \
	done
