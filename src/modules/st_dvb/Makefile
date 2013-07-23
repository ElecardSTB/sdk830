# obj-m is a list of what kernel modules to build.  The .o and other
# objects will be automatically built from the corresponding .c file -
# no need to list the source files explicitly.

MODULE_BASENAME:=st_dvb
obj-m := $(MODULE_BASENAME).o

$(MODULE_BASENAME)-objs := \
			st_dvb_main.o \
			edc-1051.o \
			sonydvbt2.o \
			sp9680.o \
			sp5650.o \

MODULE_NAME := $(MODULE_BASENAME).ko

ELC_DVB_DRIVER := y
include $(PRJROOT)/src/modules/linuxtv_common/linuxtv_kernel.mk
ifeq ($(call get_linuxtv_config_variable,CONFIG_DVB_CXD2820R),)
  ccflags-y += -I$(PRJROOT)/src/modules/cxd2820r
endif

# PWD is the current working directory and the location of our module
# source files.
PWD   := $(shell pwd)

$(MODULE_NAME): default
default:
	$(MAKE) -C $(KDIR) M=$(PWD) ARCH=sh CROSS_COMPILE=sh4-linux- modules

install: default
#	sh4-linux-strip --remove-section=.comment --remove-section=.note --strip-unneeded $(MODULE_NAME)
	$(MAKE) -C $(KDIR) M=$(PWD) ARCH=sh INSTALL_MOD_DIR=elecard INSTALL_MOD_PATH=$(ROOTFS) CROSS_COMPILE=sh4-linux- modules_install

clean:
	$(RM) $(obj-m)
	$(RM) $(foreach FILE,$(obj-m),$(dir $(FILE)).$(notdir $(FILE)).cmd)
	$(MAKE) -C $(KDIR) M=$(PWD) clean
