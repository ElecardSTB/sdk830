
include ../../etc/envvars.mk

.PHONY: all buildroot

all: buildroot $(COMPONENT_DIR)/rootfs1

buildroot:
	make -C ../buildroot rootfs

$(COMPONENT_DIR)/rootfs1:
	test -h $@ || ln -s $(BUILDROOT)/packages/buildroot/output_rootfs/images/rootfs.jffs2 $@


#This calls from buildroot
#TARGET_DIR variable should be seted by buildroot
TARGET_DIR?=$(BUILDROOT)/rootfs
KEYS_DIR=$(TARGET_DIR)/config.firmware/keys
ROOTFS_OVERLAY_FILES=$(shell find ./overlay -not -regex ".*.svn.*" -type f)
overlays: $(ROOTFS_OVERLAY_FILES) $(COMPONENT_DIR)/fwinfo/firmwareDesc
	$(call ECHO_MESSAGE,Rootfs overlays)
	prjfilter ./overlay $(TARGET_DIR) -c $(BUILDROOT)/.prjconfig
	cp -f $(COMPONENT_DIR)/fwinfo/firmwareDesc $(TARGET_DIR)
	-cp -fr /opt/philips/sp7.2/stb810-SP7.2/build_256M_NOIP/rootfs/usr/share/zoneinfo $(TARGET_DIR)/usr/share
	cp ./dev/dev-stapi-$(STAPISDK_VERSION).tar $(TARGET_DIR)/etc/dev-stapi.tar
	rm -rf $(KEYS_DIR)
ifneq ($(BUILD_ADD_KEYS_TO_FW),)
	mkdir -p $(KEYS_DIR)
	for i in $(BUILD_ADD_KEYS_TO_FW); do cp -f $(PRJROOT)/src/update/keys/open/$$i.pem $(KEYS_DIR)/; done
endif

clean:
	$(call ECHO_MESSAGE,Rootfs clean)

