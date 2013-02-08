
include ../../etc/envvars.mk

_ts_makekernelmodules=$(KDIR)/.ts_makelinuxmodules
_ts_makekernel=$(KDIR)/.ts_makelinux

.PHONY: all

all: install_kernelmodules
	$(call ECHO_MESSAGE,Building elecard drivers)
	make -C ./keyscanner install
	make -C ./st_dvb install
ifneq ($(USE_LINUXTV),y)
	make -C ./cxd2820r install
endif


install_kernelmodules: $(_ts_makekernelmodules)
	$(call ECHO_MESSAGE,Installing kernel modules)
	make -C $(KDIR) ARCH=sh CROSS_COMPILE=sh4-linux- INSTALL_MOD_PATH=$(ROOTFS) modules_install

$(_ts_makekernelmodules): $(_ts_makekernel)
	$(call ECHO_MESSAGE,Building kernel modules)
	make -C $(KDIR) ARCH=sh CROSS_COMPILE=sh4-linux- INSTALL_MOD_PATH=$(ROOTFS) modules
	touch $@

$(_ts_makekernel):

clean:
	$(call ECHO_MESSAGE,Cleaning elecard drivers)
	make -C ./keyscanner clean
	make -C ./st_dvb clean
ifneq ($(USE_LINUXTV),y)
	make -C ./cxd2820r clean
endif
#	$(call ECHO_MESSAGE,Cleaning kernel modules)

