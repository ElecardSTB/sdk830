#############################################################
#
# stmfb
#
#############################################################

#STMFB_PATH=/opt/STM/STLinux-2.4/devkit/sources/stmfb/stmfb
#STMFB_FIRMWARE_PATH=/opt/STM/STLinux-2.4/devkit/sh4/target/lib/firmware
#ftp://ftp.stlinux.com/pub/stlinux/2.4/updates/RPMS/host/stlinux24-host-stmfb-source-3.1_stm24_0103-1.noarch.rpm
#ftp://ftp.stlinux.com/pub/stlinux/2.4/updates/RPMS/sh4/stlinux24-sh4-stmfb-firmware-1.20-1.noarch.rpm
########################### STMFB ###########################
STMFB_VERSION:=3.1_stm24_0104-1
STMFB_SOURCE:=stlinux24-host-stmfb-source-$(STMFB_VERSION).noarch.rpm
STMFB_SITE:=ftp://ftp.stlinux.com/pub/stlinux/2.4/updates/RPMS/host
STMFB_DEPENDENCIES:=stmfb-firmware

define STMFB_BUILD_CMDS
	$(MAKE) -C $(STMFB_DIR) KERNELDIR=$(KDIR) ARCH=sh CROSS_COMPILE=sh4-linux-
endef

define STMFB_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0644 $(STMFB_DIR)/linux/kernel/drivers/stm/coredisplay/sti7105_7106/stmcore-display-sti7105.ko \
			$(TARGET_DIR)/lib/modules/STLinux-2.4/stmcore-display-sti7105.ko
	$(INSTALL) -D -m 0644 $(STMFB_DIR)/linux/kernel/drivers/video/stmfb.ko \
			$(TARGET_DIR)/lib/modules/STLinux-2.4/stmfb.ko
endef

define STMFB_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/lib/modules/STLinux-2.4/stmcore-display-sti7105.ko \
			$(TARGET_DIR)/lib/modules/STLinux-2.4/stmfb.ko
endef

define STMFB_CLEAN_CMDS
	$(MAKE) -C $(STMFB_DIR) KERNELDIR=$(KDIR) ARCH=sh CROSS_COMPILE=sh4-linux- clean
endef

$(eval $(call GENTARGETS, package/elecard, stmfb))
$(STMFB_TARGET_EXTRACT):
	@$(call MESSAGE,"Extracting")
	$(Q)mkdir -p $(STMFB_DIR)
	$(Q)cd $(STMFB_DIR) && rpm2cpio $(DL_DIR)/$(STMFB_SOURCE) | cpio -id
	$(Q)mv $(STMFB_DIR)/opt/STM/STLinux-2.4/devkit/sources/stmfb/stmfb-*/* $(STMFB_DIR)
	$(Q)rm -rf $(STMFB_DIR)/opt
	$(Q)touch $@
#trick, set dependence to kernel config
$(STMFB_TARGET_BUILD): $(KDIR)/.config
$(STMFB_TARGET_INSTALL_TARGET): $(KDIR)/.config

####################### STMFB FIRMWARE ######################
STMFB_FIRMWARE_VERSION:=1.20-1
STMFB_FIRMWARE_SOURCE:=stlinux24-sh4-stmfb-firmware-$(STMFB_FIRMWARE_VERSION).noarch.rpm
STMFB_FIRMWARE_SITE:=ftp://ftp.stlinux.com/pub/stlinux/2.4/updates/RPMS/sh4

define STMFB_FIRMWARE_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0644 $(STMFB_FIRMWARE_DIR)/fdvo0_7105.fw     $(TARGET_DIR)/lib/firmware/fdvo0.fw
	$(INSTALL) -D -m 0644 $(STMFB_FIRMWARE_DIR)/component_7105.fw $(TARGET_DIR)/lib/firmware/component.fw
endef

define STMFB_FIRMWARE_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/lib/firmware/fdvo0.fw $(TARGET_DIR)/lib/firmware/component.fw
endef

$(eval $(call GENTARGETS, package/elecard, stmfb-firmware))
$(STMFB_FIRMWARE_TARGET_EXTRACT):
	@$(call MESSAGE,"Extracting")
	$(Q)mkdir -p $(STMFB_FIRMWARE_DIR)
	$(Q)cd $(STMFB_FIRMWARE_DIR) && rpm2cpio $(DL_DIR)/$(STMFB_FIRMWARE_SOURCE) | cpio -id
	$(Q)mv $(STMFB_FIRMWARE_DIR)/opt/STM/STLinux-2.4/devkit/sh4/target/lib/firmware/* $(STMFB_FIRMWARE_DIR)
	$(Q)rm -rf $(STMFB_FIRMWARE_DIR)/opt
	$(Q)touch $@


########################## FB LOGO #########################
fb_logo-build:
	make CROSS_COMPILE=sh4-linux- -C $(PRJROOT)/src/apps/fb_logo

fb_logo-install: fb_logo-build
	$(INSTALL) -D -m 0755 $(PRJROOT)/src/apps/fb_logo/fb_logo $(TARGET_DIR)/opt/elecard/bin/

fb_logo: fb_logo-install

fb_logo-clean:
	make CROSS_COMPILE=sh4-linux- -C $(PRJROOT)/src/apps/fb_logo clean


ifeq ($(BR2_PACKAGE_STMFB_LOGO),y)
TARGETS+=fb_logo
endif

