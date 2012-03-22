
PROGRAM=$(PRJROOT)/bin/checksum


.PHONY: all

all: $(PROGRAM)


$(PROGRAM): main.c
	gcc -o $@ $<

clean:
	rm $(PROGRAM)