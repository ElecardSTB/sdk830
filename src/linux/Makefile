
include ../../etc/envvars.mk
include $(PRJROOT)/etc/util.mk
include $(PRJROOT)/etc/patch.mk

KERNEL_CONFIG=$(shell pwd)/STLinux-$(FULL_LINUX_VERSION).config
KERNEL_PACK_NAME=stlinux24-STAPI-kernel-sh4-$(FULL_LINUX_VERSION2).noarch.rpm
downloadkernel_file=$(TARBALLS_DIR)/$(KERNEL_PACK_NAME)

_ts_unpackkernel=$(KDIR)/.ts_unpacklinux
_ts_configkernel=$(KDIR)/.ts_configlinux $(TIMESTAMPS_DIR)/.configlinux
_ts_patchkernel=$(KDIR)/.ts_patchlinux $(TIMESTAMPS_DIR)/.patchlinux
_ts_makekernel=$(KDIR)/.ts_makelinux $(TIMESTAMPS_DIR)/.makelinux

.PHONY: build_initramfs build config clean kernel_only unpack

all: build


build_initramfs:
	make -C ../initramfs

config: $(KDIR)/.config

build: $(KDIR)/.config build_initramfs $(KDIR)/arch/sh/boot/uImage
$(KDIR)/arch/sh/boot/uImage: $(KDIR)/.config $(_ts_patchkernel) $(COMPONENT_DIR)/initramfs.cpio $(_ts_makekernel)
	$(call ECHO_MESSAGE,Building kernel)
	make -C $(KDIR) ARCH=sh CROSS_COMPILE=sh4-linux- uImage
	rm -f $(COMPONENT_DIR)/kernel1; ln -s $(KDIR)/arch/sh/boot/uImage $(COMPONENT_DIR)/kernel1
	touch $(_ts_makekernel)
	touch $@

kernel_only: $(KDIR)/.config $(_ts_patchkernel)
	rm -f $(_ts_makekernel)
	make -C $(KDIR) ARCH=sh CROSS_COMPILE=sh4-linux- $(sub)


$(eval $(call createPatchOverlayScriptTarget,$(_ts_patchkernel),$(FULL_LINUX_VERSION),$(KDIR),kernel,))

ifneq ($(STLINUX_SELF_DOWNLOAD),)
$(KDIR)/.config: $(_ts_unpackkernel)
endif
$(KDIR)/.config: $(KERNEL_CONFIG) $(_ts_configkernel)
$(KDIR)/.config:
	$(call ECHO_MESSAGE,Configuring kernel)
	@echo $(KERNEL_CONFIG)
	$(call CONFEDIT_INIT,$(KDIR),$(KERNEL_CONFIG))
	$(call CONFEDIT_SET_STRING,$(KDIR),CONFIG_INITRAMFS_SOURCE,$(COMPONENT_DIR)/initramfs.cpio)
	$(call CONFEDIT_EXECUTE,$(KDIR))
	make -C $(KDIR) ARCH=sh CROSS_COMPILE=sh4-linux- modules_prepare
#first time modules_prepare modify config, so copy it again:
	$(call CONFEDIT_EXECUTE,$(KDIR))
	touch $(_ts_makekernel)
	touch $@

$(_ts_makekernel):
	touch $(_ts_makekernel)

$(_ts_configkernel):
	touch $(_ts_configkernel)

$(_ts_unpackkernel):
	$(call ECHO_MESSAGE,Downloading kernel)
	[ -e $(downloadkernel_file) ] || wget --passive-ftp -nd -P $(TARBALLS_DIR) ftp://ftp.stlinux.com/pub/stlinux/2.4/stapi/RPMS/$(KERNEL_PACK_NAME)
	$(call ECHO_MESSAGE,Unpacking kernel)
	cd $(BUILDROOT)/packages && rpm2cpio $(downloadkernel_file) | cpio -id
	mv $(BUILDROOT)/packages/opt/STM/STLinux-2.4/devkit/sources/kernel/linux-sh4-$(FULL_LINUX_VERSION) $(BUILDROOT)/packages
	rm -rf $(BUILDROOT)/packages/opt
	touch $(_ts_unpackkernel)

unpack: $(_ts_unpackkernel)


clean::
	$(call ECHO_MESSAGE,Cleaning kernel)
	rm -f $(_ts_makekernel)
	make -C $(KDIR) ARCH=sh CROSS_COMPILE=sh4-linux- clean

