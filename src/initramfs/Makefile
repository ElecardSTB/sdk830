
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
$(INITRAMFS_IMAGES_DIR)/rootfs.cpio: $(INITRAMFS_OVERLAY_FILES) $(KDIR)/.config $(COMPONENT_DIR)/.pubKeysList
	make -C ../buildroot initramfs_rm_make_ts

#Dummy target if $PRJROOT/bin/genFirmwarePackConf.sh not create this
$(COMPONENT_DIR)/.pubKeysList:

clean:
	$(call ECHO_MESSAGE,Initramfs clean)
	rm -f $(COMPONENT_DIR)/initramfs.cpio

#Dummy target. This is depricated call from buildroot.
#Real overlay target located in $PRJROOT/src/buildroot/2010.11_overlay/package/elecard/overlays.mk
overlays:
