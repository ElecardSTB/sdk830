# obj-m is a list of what kernel modules to build.  The .o and other
# objects will be automatically built from the corresponding .c file -
# no need to list the source files explicitly.
MODULE_NAME:=keyscanner

obj-m := $(MODULE_NAME).o

# KDIR is the location of the kernel source.  The current standard is
# to link to the associated source tree from the directory containing
# the compiled modules.
#this can be configured already
#KDIR  := 

MODULE_NAME := $(MODULE_NAME).ko

# PWD is the current working directory and the location of our module
# source files.
PWD   := $(shell pwd)

$(MODULE_NAME): default
# default is the default make target.  The rule here says to run make
# with a working directory of the directory containing the kernel
# source and compile only the modules in the PWD (local) directory.
default:
	$(MAKE) -C $(KDIR) M=$(PWD) modules ARCH=sh CROSS_COMPILE=sh4-linux-

install: default
	$(MAKE) -C $(KDIR) M=$(PWD) ARCH=sh INSTALL_MOD_DIR=elecard INSTALL_MOD_PATH=$(ROOTFS) CROSS_COMPILE=sh4-linux- modules_install

clean:
	$(RM) $(obj-m)
	$(RM) $(foreach FILE,$(obj-m),$(dir $(FILE)).$(notdir $(FILE)).cmd)
	$(MAKE) -C $(KDIR) M=$(PWD) clean
