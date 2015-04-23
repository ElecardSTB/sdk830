#############################################################
#
# backports
#
#############################################################

BACKPORTS_VERSION = 3.14.22-1
BACKPORTS_SITE = http://www.kernel.org/pub/linux/kernel/projects/backports/stable/v3.14.22
# BACKPORTS_VERSION = 3.14-1
# BACKPORTS_SITE = https://www.kernel.org/pub/linux/kernel/projects/backports/stable/v3.14
BACKPORTS_SOURCE = backports-$(BACKPORTS_VERSION).tar.gz

BACKPORTS_CFG_FILE := package/elecard/backports/backports-$(BACKPORTS_VERSION).config


define BACKPORTS_CONFIGURE_CMDS
	cp $(BACKPORTS_CFG_FILE) $(@D)/.config
endef

define BACKPORTS_BUILD_CMDS
	$(BACKPORTS_MAKE_ENV) $(MAKE) ARCH=$(KERNEL_ARCH) \
		CROSS_COMPILE="$(TARGET_CROSS)" KLIB_BUILD=$(KDIR) \
		-C $(@D)
endef

define BACKPORTS_INSTALL_TARGET_CMDS
	$(BACKPORTS_MAKE_ENV) $(MAKE) ARCH=$(KERNEL_ARCH) \
		CROSS_COMPILE="$(TARGET_CROSS)" KLIB_BUILD=$(KDIR) \
		KLIB=$(TARGET_DIR) KMODDIR=backports \
		-C $(@D) install
endef

define BACKPORTS_UNINSTALL_TARGET_CMDS
	rm -rf $(TARGET_DIR)/lib/modules/*/backports
endef

define BACKPORTS_CLEAN_CMDS
	$(BACKPORTS_MAKE_ENV) $(MAKE) ARCH=$(KERNEL_ARCH) \
		CROSS_COMPILE="$(TARGET_CROSS)" KLIB_BUILD=$(KDIR) \
		-C $(@D) clean
endef

$(eval $(call GENTARGETS,package/elecard,backports))


#trick, set dependence to kernel config
$(BACKPORTS_TARGET_BUILD): $(KDIR)/.config
$(BACKPORTS_TARGET_INSTALL_TARGET): $(KDIR)/.config

backports-menuconfig: backports-configure
	$(BACKPORTS_MAKE_ENV) $(MAKE) ARCH=$(KERNEL_ARCH) \
		CROSS_COMPILE="$(TARGET_CROSS)" KLIB_BUILD=$(KDIR) \
		-C $(BACKPORTS_DIR) menuconfig
