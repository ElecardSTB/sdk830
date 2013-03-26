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

MODULE_NAME := $(MODULE_BASENAME).ko

ifeq ($(USE_LINUXTV),y)
LINUXTV_PATH=$(BUILDROOT)/packages/buildroot/output_rootfs/build/media_build
ccflags-y += -I$(LINUXTV_PATH)/linux/drivers/media/dvb-core
ccflags-y += -DUSE_LINUXTV

ccflags-y += -include $(LINUXTV_PATH)/v4l/compat.h

# Needed for kernel 2.6.29 or up
LINUXINCLUDE    := -I$(LINUXTV_PATH)/linux/include -I$(LINUXTV_PATH)/linux/include/uapi/linux $(LINUXINCLUDE) -I$(LINUXTV_PATH)/v4l
else
#ccflags-y += -I$(KDIR)
ccflags-y += -Idrivers/media/dvb/dvb-core/
ccflags-y += -Idrivers/media/dvb/frontends/
ccflags-y += -I$(PRJROOT)/src/modules/cxd2820r
endif

#This not acessed for SDK830 users (need full build).
#ccflags-y += -I$(PRJROOT)/src/elecard/modules/mxl201


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
