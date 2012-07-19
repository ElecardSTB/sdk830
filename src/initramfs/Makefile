
include ../../etc/envvars.mk

.PHONY: all overlays clean

all: check_overlays buildroot $(COMPONENT_DIR)/initramfs.cpio

INITRAMFS_IMAGES_DIR=$(PACKAGES_DIR)/buildroot/output_initramfs/images

$(COMPONENT_DIR)/initramfs.cpio:
	test -h $@ || ln -s $(INITRAMFS_IMAGES_DIR)/rootfs.cpio $@

buildroot:
	make -C ../buildroot initramfs

INITRAMFS_OVERLAY_FILES=$(shell find ./overlay -not -regex ".*.svn.*" -type f)
check_overlays: $(INITRAMFS_IMAGES_DIR)/rootfs.cpio
$(INITRAMFS_IMAGES_DIR)/rootfs.cpio: $(INITRAMFS_OVERLAY_FILES) $(KDIR)/.config
	make -C ../buildroot initramfs_rm_make_ts


#TARGET_DIR variable should be seted by buildroot
TARGET_DIR?=$(BUILDROOT)/initramfs
#this calls from buildroot
overlays:
	$(call ECHO_MESSAGE,Initramfs overlays)
	prjfilter ./overlay $(TARGET_DIR) -c $(BUILDROOT)/.prjconfig
	@echo


clean:
	$(call ECHO_MESSAGE,Initramfs clean)
	rm -f $(COMPONENT_DIR)/initramfs.cpio

