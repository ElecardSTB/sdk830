# obj-m is a list of what kernel modules to build.  The .o and other
# objects will be automatically built from the corresponding .c file -
# no need to list the source files explicitly.

obj-m := keyscanner.o

# KDIR is the location of the kernel source.  The current standard is
# to link to the associated source tree from the directory containing
# the compiled modules.
#this can be configured already
#KDIR  := 

# PWD is the current working directory and the location of our module
# source files.
PWD   := $(shell pwd)

# default is the default make target.  The rule here says to run make
# with a working directory of the directory containing the kernel
# source and compile only the modules in the PWD (local) directory.
default:
	$(MAKE) -C $(KDIR) M=$(PWD) modules ARCH=sh CROSS_COMPILE=sh4-linux-


INSTALL_DIR := $(ROOTFS)/lib/modules/STLinux-$(LINUX_VERSION)
MODULE_NAME := keyscanner.ko

install: default
	mkdir -p $(INSTALL_DIR)
	sh4-linux-strip --strip-debug $(MODULE_NAME)
	cp -f $(MODULE_NAME) $(INSTALL_DIR)

uninstall:
	rm -f $(INSTALL_DIR)/$(MODULE_NAME)

$(MODULE_NAME): default


clean:
	$(RM) $(obj-m)
	$(RM) $(foreach FILE,$(obj-m),$(dir $(FILE)).$(notdir $(FILE)).cmd)
	$(MAKE) -C $(KDIR) M=$(PWD) clean
