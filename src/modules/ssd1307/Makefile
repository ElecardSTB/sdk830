# obj-m is a list of what kernel modules to build.  The .o and other
# objects will be automatically built from the corresponding .c file -
# no need to list the source files explicitly.

MODULE_BASENAME:=ssd1307
obj-m := $(MODULE_BASENAME).o

ccflags-y += -Wall

# PWD is the current working directory and the location of our module
# source files.
PWD   := $(shell pwd)

MODULE_NAME := $(MODULE_BASENAME).ko
LDFLAGS:=

install:
	$(MAKE) -C $(KDIR) M=$(PWD) ARCH=sh INSTALL_MOD_DIR=elecard INSTALL_MOD_PATH=$(ROOTFS) CROSS_COMPILE=sh4-linux- modules_install

default:
	$(MAKE) -C $(KDIR) ARCH=sh CROSS_COMPILE=sh4-linux- M=$(PWD) modules

$(MODULE_NAME): default

clean:
	$(RM) $(obj-m)
	$(RM) $(foreach FILE,$(obj-m),$(dir $(FILE)).$(notdir $(FILE)).cmd)
	$(MAKE) -C $(KDIR) M=$(PWD) clean
