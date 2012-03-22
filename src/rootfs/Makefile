
include ../../etc/envvars.mk

.PHONY: all buildroot

all: buildroot $(COMPONENT_DIR)/rootfs1

buildroot:
	make -C ../buildroot rootfs

$(COMPONENT_DIR)/rootfs1:
	ln -s $(BUILDROOT)/packages/buildroot/output_rootfs/images/rootfs.jffs2 $@


#TARGET_DIR variable should be seted by buildroot
TARGET_DIR?=$(BUILDROOT)/rootfs
ROOTFS_OVERLAY_FILES=$(shell find ./overlay -not -regex ".*.svn.*" -type f)
#This calls from buildroot
overlays: $(ROOTFS_OVERLAY_FILES) $(COMPONENT_DIR)/firmwareDesc
	$(call ECHO_MESSAGE,Rootfs overlays)
	prjfilter ./overlay $(TARGET_DIR) -c $(BUILDROOT)/.prjconfig
	cp -f $(COMPONENT_DIR)/firmwareDesc $(TARGET_DIR)
	-cp -fr /opt/philips/sp7.2/stb810-SP7.2/build_256M_NOIP/rootfs/usr/share/zoneinfo $(TARGET_DIR)/usr/share

clean:
	$(call ECHO_MESSAGE,Rootfs clean)

