#############################################################
#
# accel-pptp
#
#############################################################
ACCEL_PPTP_VERSION = 0.8.5
ACCEL_PPTP_SITE = http://sourceforge.net/projects/accel-pptp/files/accel-pptp/
ACCEL_PPTP_SOURCE = accel-pptp-$(ACCEL_PPTP_VERSION).tar.bz2
ACCEL_PPTP_DEPENDENCIES = pppd
ACCEL_PPTP_SUBDIR = pppd_plugin
PPPD_VERSION=2.4.5

define ACCEL_PPTP_INSTALL_TARGET_CMDS
	$(INSTALL) $(@D)/$(ACCEL_PPTP_SUBDIR)/src/.libs/pptp.so.0.0.0 $(TARGET_DIR)/usr/lib/pppd/$(PPPD_VERSION)/pptp.so
	(cd $(@D)/kernel/driver; $(MAKE) ARCH=sh CROSS_COMPILE=$(TARGET_CROSS) INSTALL_MOD_PATH=$(TARGET_DIR) all install)
endef

define ACCEL_PPTP_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/usr/lib/pppd/$(PPPD_VERSION)/pptp.so
	rm -f $(TARGET_DIR)/lib/modules/*/extra/pptp.ko
endef

$(eval $(call AUTOTARGETS, package/elecard, accel-pptp))

# FIXME:
# accel-pptp-0.8.5.tar.bz2 is packed with two slashes in path,
# and extraction don't work with tar --strip-components=1
$(ACCEL_PPTP_TARGET_EXTRACT):
	@$(call MESSAGE,"Extracting")
	$(INFLATE$(suffix $(ACCEL_PPTP_SOURCE))) $(DL_DIR)/$(ACCEL_PPTP_SOURCE) | \
		$(TAR) -C $(BUILD_DIR) $(TAR_OPTIONS) -
	$(Q)touch $@
