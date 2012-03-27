
include ../../etc/envvars.mk
include $(PRJROOT)/etc/util.mk
include $(PRJROOT)/etc/patch.mk

KERNEL_CONFIG=$(shell pwd)/STLinux-$(FULL_LINUX_VERSION).config

_ts_configkernel=$(KDIR)/.ts_configlinux $(TIMESTAMPS_DIR)/.configlinux
_ts_patchkernel=$(KDIR)/.ts_patchlinux $(TIMESTAMPS_DIR)/.patchlinux
_ts_makekernel=$(KDIR)/.ts_makelinux $(TIMESTAMPS_DIR)/.makelinux

.PHONY: make_initramfs make_kernel config_kernel clean kernel_only

all: make_kernel


make_initramfs:
	make -C ../initramfs

config_kernel: $(KDIR)/.config

make_kernel: $(KDIR)/.config make_initramfs $(KDIR)/arch/sh/boot/uImage $(COMPONENT_DIR)/kernel1
$(KDIR)/arch/sh/boot/uImage: $(KDIR)/.config $(_ts_patchkernel) $(COMPONENT_DIR)/initramfs.cpio $(_ts_makekernel)
	$(call ECHO_MESSAGE,Building kernel)
	make -C $(KDIR) ARCH=sh CROSS_COMPILE=sh4-linux- uImage
	touch $(_ts_makekernel)
	touch $@


$(COMPONENT_DIR)/kernel1:
	test -h $@ || ln -s $(KDIR)/arch/sh/boot/uImage $@

kernel_only: $(KDIR)/.config $(_ts_patchkernel)
	rm -f $(_ts_makekernel)
	make -C $(KDIR) ARCH=sh CROSS_COMPILE=sh4-linux- $(sub)


$(eval $(call createPatchOverlayScriptTarget,$(_ts_patchkernel),$(FULL_LINUX_VERSION),$(KDIR),kernel,))


$(KDIR)/.config: $(KERNEL_CONFIG) $(_ts_configkernel)
	$(call ECHO_MESSAGE,Configuring kernel)
	@echo $(KERNEL_CONFIG)
	$(call CONFEDIT_INIT,$(KDIR),$(KERNEL_CONFIG))
	$(call CONFEDIT_SET_STRING,$(KDIR),CONFIG_INITRAMFS_SOURCE,$(COMPONENT_DIR)/initramfs.cpio)
	$(call CONFEDIT_EXECUTE,$(KDIR))
	touch $(_ts_makekernel)
	touch $@

$(_ts_makekernel):
	touch $(_ts_makekernel)

$(_ts_configkernel):
	touch $(_ts_configkernel)


clean::
	$(call ECHO_MESSAGE,Cleaning kernel)
	rm -f $(_ts_makekernel)
	make -C $(KDIR) ARCH=sh CROSS_COMPILE=sh4-linux- clean
