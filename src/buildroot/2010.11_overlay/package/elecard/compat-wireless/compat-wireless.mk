#############################################################
#
# compat-wireless
#
#############################################################

COMPAT_WIRELESS_VERSION = 3.0-2
COMPAT_WIRELESS_SITE = http://www.orbit-lab.org/kernel/compat-wireless-3-stable/v3.0
COMPAT_WIRELESS_SOURCE = compat-wireless-$(COMPAT_WIRELESS_VERSION).tar.bz2

define COMPAT_WIRELESS_BUILD_CMDS
	$(COMPAT_WIRELESS_MAKE_ENV) $(MAKE) ARCH=$(KERNEL_ARCH) \
		CROSS_COMPILE="$(TARGET_CROSS)" KLIB_BUILD=$(KDIR) \
		-C $(@D)
endef

define COMPAT_WIRELESS_INSTALL_BINARY
	$(COMPAT_WIRELESS_MAKE_ENV) $(MAKE) ARCH=$(KERNEL_ARCH) \
		CROSS_COMPILE="$(TARGET_CROSS)" KLIB_BUILD=$(KDIR) \
		KLIB=$(TARGET_DIR) \
		-C $(@D) install-modules
endef

define COMPAT_WIRELESS_INSTALL_TARGET_CMDS
	$(COMPAT_WIRELESS_INSTALL_BINARY)
endef

define COMPAT_WIRELESS_UNINSTALL_TARGET_CMDS
	rm -rf $(TARGET_DIR)/lib/modules/*/updates/*
endef

define COMPAT_WIRELESS_CLEAN_CMDS
	$(COMPAT_WIRELESS_MAKE_ENV) $(MAKE) ARCH=$(KERNEL_ARCH) \
		CROSS_COMPILE="$(TARGET_CROSS)" KLIB_BUILD=$(KDIR) \
		-C $(@D) clean
endef


$(eval $(call GENTARGETS,package/elecard,compat-wireless))


#trick, set dependence to kernel config
$(COMPAT_WIRELESS_TARGET_BUILD): $(KDIR)/.config
$(COMPAT_WIRELESS_TARGET_INSTALL_TARGET): $(KDIR)/.config
