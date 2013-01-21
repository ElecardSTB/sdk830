
include ../../etc/envvars.mk
include $(PRJROOT)/etc/util.mk
include $(PRJROOT)/etc/patch.mk

KERNEL_SITE=ftp://ftp.stlinux.com/pub/stlinux/2.4/stapi/RPMS
KERNEL_CONFIG=$(shell pwd)/STLinux-$(FULL_LINUX_VERSION).config
KERNEL_PACK_NAME=stlinux24-STAPI-kernel-sh4-$(FULL_LINUX_VERSION2).noarch.rpm
downloadkernel_file=$(TARBALLS_DIR)/$(KERNEL_PACK_NAME)

_ts_unpackkernel=$(KDIR)/.ts_unpacklinux
_ts_configkernel=$(KDIR)/.ts_configlinux $(TIMESTAMPS_DIR)/.configlinux
_ts_patchkernel=$(KDIR)/.ts_patchlinux $(TIMESTAMPS_DIR)/.patchlinux
_ts_makekernel=$(KDIR)/.ts_makelinux $(TIMESTAMPS_DIR)/.makelinux

.PHONY: all patch configure build_initramfs build_kernel clean kernel_only unpack

all: patch configure build_initramfs build_kernel

unpack: $(_ts_unpackkernel)
configure: $(KDIR)/.config
patch: $(_ts_patchkernel)
build_kernel: $(KDIR)/arch/sh/boot/uImage
build_initramfs:
	make -C ../initramfs

$(KDIR)/arch/sh/boot/uImage: $(KDIR)/.config $(_ts_patchkernel) $(COMPONENT_DIR)/initramfs.cpio $(_ts_makekernel)
	$(call ECHO_MESSAGE,Building kernel)
	touch $(_ts_makekernel)
	make -C $(KDIR) ARCH=sh CROSS_COMPILE=sh4-linux- uImage
	rm -f $(COMPONENT_DIR)/kernel1; ln -s $(KDIR)/arch/sh/boot/uImage $(COMPONENT_DIR)/kernel1

kernel_only: patch configure
	rm -f $(_ts_makekernel)
	make -C $(KDIR) ARCH=sh CROSS_COMPILE=sh4-linux- $(sub)


$(eval $(call createPatchOverlayScriptTarget,$(_ts_patchkernel),$(FULL_LINUX_VERSION),$(KDIR),kernel,$(_ts_unpackkernel)))
$(KDIR)/.config: $(KERNEL_CONFIG) $(_ts_configkernel)
	$(call ECHO_MESSAGE,Configuring kernel)
	@echo $(KERNEL_CONFIG)
	$(call CONFEDIT_INIT,$(KDIR),$(KERNEL_CONFIG))
	$(call CONFEDIT_SET_STRING,$(KDIR),CONFIG_INITRAMFS_SOURCE,$(COMPONENT_DIR)/initramfs.cpio)
	$(call CONFEDIT_EXECUTE,$(KDIR))
	make -C $(KDIR) ARCH=sh CROSS_COMPILE=sh4-linux- modules_prepare
#first time modules_prepare modify config, so copy it again:
	$(call CONFEDIT_EXECUTE,$(KDIR))
	rm -rf $(BUILDROOT)/rootfs/lib/modules/
	rm -rf $(BUILDROOT)/rootfs_nfs/lib/modules/
	touch $@

$(_ts_makekernel):
	touch $(_ts_makekernel)

$(_ts_configkernel):
	touch $(_ts_configkernel)

$(_ts_unpackkernel):
	$(call ECHO_MESSAGE,Downloading kernel)
	[ -e $(downloadkernel_file) ] || wget --passive-ftp -nd -P $(TARBALLS_DIR) $(KERNEL_SITE)/$(KERNEL_PACK_NAME)
	$(call ECHO_MESSAGE,Unpacking kernel)
	cd $(PACKAGES_DIR) && rpm2cpio $(downloadkernel_file) | cpio -id
	mv $(PACKAGES_DIR)/opt/STM/STLinux-2.4/devkit/sources/kernel/linux-sh4-$(FULL_LINUX_VERSION) $(PACKAGES_DIR)
	rm -rf $(PACKAGES_DIR)/opt
	touch $(_ts_unpackkernel)

clean::
	$(call ECHO_MESSAGE,Cleaning kernel)
	rm -f $(_ts_makekernel)
	make -C $(KDIR) ARCH=sh CROSS_COMPILE=sh4-linux- clean

