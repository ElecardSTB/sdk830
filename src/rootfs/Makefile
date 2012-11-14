
include ../../etc/envvars.mk

.PHONY: all buildroot

all: buildroot $(COMPONENT_DIR)/rootfs1

buildroot:
	make -C ../buildroot rootfs

$(COMPONENT_DIR)/rootfs1:
	test -h $@ || ln -s $(PACKAGES_DIR)/buildroot/output_rootfs/images/rootfs.jffs2 $@

clean:
	$(call ECHO_MESSAGE,Rootfs clean)

#Dummy target. This calls from buildroot.
#Real overlay target located in $PRJROOT/src/buildroot/2010.11_overlay/package/elecard/overlays.mk
overlays:
