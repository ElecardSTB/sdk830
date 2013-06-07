
include ../../etc/envvars.mk
include linuxtv_common/linuxtv_common.mk

_ts_makekernelmodules=$(KDIR)/.ts_makelinuxmodules
_ts_makekernel=$(KDIR)/.ts_makelinux
OTHER_CXD2820R_DRIVER := $(call get_linuxtv_config_variable,CONFIG_DVB_CXD2820R)

.PHONY: all

all: build

build: install_kernelmodules
	$(call ECHO_MESSAGE,Building elecard drivers)
#	make -C ./keyscanner install
	make -C ./st_dvb install
	make -C ./ssd1307 install
ifeq ($(OTHER_CXD2820R_DRIVER),)
	make -C ./cxd2820r install
endif


install_kernelmodules: $(_ts_makekernelmodules)
	$(call ECHO_MESSAGE,Installing kernel modules)
	make -C $(KDIR) ARCH=sh CROSS_COMPILE=sh4-linux- INSTALL_MOD_PATH=$(ROOTFS) modules_install

$(_ts_makekernelmodules): $(_ts_makekernel)
	$(call ECHO_MESSAGE,Building kernel modules)
	make -C $(KDIR) ARCH=sh CROSS_COMPILE=sh4-linux- INSTALL_MOD_PATH=$(ROOTFS) modules
	touch $@

clean:
	$(call ECHO_MESSAGE,Cleaning elecard drivers)
#	make -C ./keyscanner clean
	make -C ./st_dvb clean
	make -C ./ssd1307 clean
ifeq ($(OTHER_CXD2820R_DRIVER),)
	make -C ./cxd2820r clean
endif
#	$(call ECHO_MESSAGE,Cleaning kernel modules)

$(_ts_makekernel):
