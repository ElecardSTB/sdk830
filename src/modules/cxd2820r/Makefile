# obj-m is a list of what kernel modules to build.  The .o and other
# objects will be automatically built from the corresponding .c file -
# no need to list the source files explicitly.

MODULE_BASENAME:=cxd2820r
obj-m := $(MODULE_BASENAME).o

$(MODULE_BASENAME)-objs := \
			cxd2820r_c.o \
			cxd2820r_core.o \
			cxd2820r_t2.o \
			cxd2820r_t.o

MODULE_NAME := $(MODULE_BASENAME).ko

EXTRA_CFLAGS += -Idrivers/media/dvb/dvb-core/

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
