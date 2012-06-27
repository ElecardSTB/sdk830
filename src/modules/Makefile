
include ../../etc/envvars.mk

_ts_makekernelmodules=$(KDIR)/.ts_makelinuxmodules
_ts_makekernel=$(KDIR)/.ts_makelinux

.PHONY: all

all: install_kernelmodules
	$(call ECHO_MESSAGE,Building elecard drivers)
	make -C ./keyscanner install


install_kernelmodules: $(_ts_makekernelmodules)
	$(call ECHO_MESSAGE,Installing kernel modules)
	make -C $(KDIR) ARCH=sh CROSS_COMPILE=sh4-linux- INSTALL_MOD_PATH=$(ROOTFS) modules_install

$(_ts_makekernelmodules): $(_ts_makekernel)
	$(call ECHO_MESSAGE,Building kernel modules)
	make -C $(KDIR) ARCH=sh CROSS_COMPILE=sh4-linux- INSTALL_MOD_PATH=$(ROOTFS) modules
	touch $@

clean:
	$(call ECHO_MESSAGE,Cleaning elecard drivers)
	make -C ./keyscanner clean
#	$(call ECHO_MESSAGE,Cleaning kernel modules)

