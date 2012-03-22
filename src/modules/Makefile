
include ../../etc/envvars.mk

.PHONY: all

all:
	$(call ECHO_MESSAGE,Building elecard drivers)
	make -C ./keyscanner install

clean:
	$(call ECHO_MESSAGE,Cleaning elecard drivers)
	make -C ./keyscanner clean

