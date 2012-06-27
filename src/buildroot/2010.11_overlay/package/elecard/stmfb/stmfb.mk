#############################################################
#
# stmfb
#
#############################################################

#STMFB_PATH=/opt/STM/STLinux-2.4/devkit/sources/stmfb/stmfb
#STMFB_FIRMWARE_PATH=/opt/STM/STLinux-2.4/devkit/sh4/target/lib/firmware
#ftp://ftp.stlinux.com/pub/stlinux/2.4/updates/RPMS/host/stlinux24-host-stmfb-source-3.1_stm24_0103-1.noarch.rpm
#ftp://ftp.stlinux.com/pub/stlinux/2.4/updates/RPMS/sh4/stlinux24-sh4-stmfb-firmware-1.20-1.noarch.rpm

STMFB_VERSION:=3.1_stm24_0103-1
STMFB_PACKAGE:=stlinux24-host-stmfb-source-$(STMFB_VERSION).noarch.rpm
STMFB_DIR:=$(BUILD_DIR)/stmfb-$(STMFB_VERSION)
STMFB_SITE:=ftp://ftp.stlinux.com/pub/stlinux/2.4/updates/RPMS/host

STMFB_FIRMWARE_VERSION:=1.20-1
STMFB_FIRMWARE_PACKAGE:=stlinux24-sh4-stmfb-firmware-$(STMFB_FIRMWARE_VERSION).noarch.rpm
STMFB_FIRMWARE_DIR:=$(BUILD_DIR)/stmfb-firmware-$(STMFB_FIRMWARE_VERSION)
STMFB_FIRMWARE_SITE:=ftp://ftp.stlinux.com/pub/stlinux/2.4/updates/RPMS/sh4

$(DL_DIR)/$(STMFB_PACKAGE):
	$(call DOWNLOAD,$(STMFB_SITE),$(STMFB_PACKAGE))

$(DL_DIR)/$(STMFB_FIRMWARE_PACKAGE):
	$(call DOWNLOAD,$(STMFB_FIRMWARE_SITE),$(STMFB_FIRMWARE_PACKAGE))

$(STMFB_DIR): $(DL_DIR)/$(STMFB_PACKAGE)
	mkdir -p $(STMFB_DIR)
	cd $(STMFB_DIR) && rpm2cpio $(DL_DIR)/$(STMFB_PACKAGE) | cpio -id
	mv $(STMFB_DIR)/opt/STM/STLinux-2.4/devkit/sources/stmfb/stmfb-*/* $(STMFB_DIR)
	rm -rf $(STMFB_DIR)/opt

$(STMFB_FIRMWARE_DIR): $(DL_DIR)/$(STMFB_FIRMWARE_PACKAGE)
	mkdir -p $(STMFB_FIRMWARE_DIR)
	cd $(STMFB_FIRMWARE_DIR) && rpm2cpio $(DL_DIR)/$(STMFB_FIRMWARE_PACKAGE) | cpio -id
	mv $(STMFB_FIRMWARE_DIR)/opt/STM/STLinux-2.4/devkit/sh4/target/lib/firmware/* $(STMFB_FIRMWARE_DIR)
	rm -rf $(STMFB_FIRMWARE_DIR)/opt

stmfb-download: $(DL_DIR)/$(STMFB_PACKAGE) $(DL_DIR)/$(STMFB_FIRMWARE_PACKAGE)
stmfb-unpack: $(STMFB_DIR) $(STMFB_FIRMWARE_DIR) 

stmfb-build: stmfb-unpack
	make -C $(STMFB_DIR) KERNELDIR=$(KDIR) ARCH=sh CROSS_COMPILE=sh4-linux-

stmfb-install: stmfb-build
	$(INSTALL) -D -m 0644 $(STMFB_FIRMWARE_DIR)/fdvo0_7105.fw     $(TARGET_DIR)/lib/firmware/fdvo0.fw
	$(INSTALL) -D -m 0644 $(STMFB_FIRMWARE_DIR)/component_7105.fw $(TARGET_DIR)/lib/firmware/component.fw
	$(INSTALL) -D -m 0644 $(STMFB_DIR)/linux/kernel/drivers/stm/coredisplay/sti7105_7106/stmcore-display-sti7105.ko \
	                   $(TARGET_DIR)/lib/modules/STLinux-2.4/stmcore-display-sti7105.ko
	$(INSTALL) -D -m 0644 $(STMFB_DIR)/linux/kernel/drivers/video/stmfb.ko \
	                   $(TARGET_DIR)/lib/modules/STLinux-2.4/stmfb.ko

stmfb: stmfb-install

stmfb-clean:
	make -C $(STMFB_DIR) KERNELDIR=$(KDIR) ARCH=sh CROSS_COMPILE=sh4-linux- clean



$(PRJROOT)/src/apps/fb_logo/fb_logo: $(wildcard $(PRJROOT)/src/apps/fb_logo/*.c)
	make -C $(PRJROOT)/src/apps/fb_logo CROSS_COMPILE=sh4-linux-

fb_logo-build: $(PRJROOT)/src/apps/fb_logo/fb_logo

fb_logo-install: fb_logo-build
	$(INSTALL) -D -m 0755 $(PRJROOT)/src/apps/fb_logo/fb_logo $(TARGET_DIR)/opt/elecard/bin/

fb_logo: fb_logo-install

fb_logo-clean:
	make -C $(PRJROOT)/src/apps/fb_logo CROSS_COMPILE=sh4-linux- clean


ifeq ($(BR2_PACKAGE_STMFB),y)
TARGETS+=stmfb
endif

ifeq ($(BR2_PACKAGE_STMFB_LOGO),y)
TARGETS+=fb_logo
endif

#trick, set dependence to kernel config
$(STMFB_TARGET_BUILD): $(KDIR)/.config
