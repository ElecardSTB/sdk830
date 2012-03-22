#############################################################
#
# lirc
#
#############################################################

#LIRC_VERSION = 0.8.6
LIRC_VERSION = 0.9.0
LIRC_SOURCE = lirc-$(LIRC_VERSION).tar.bz2
LIRC_SITE = http://prdownloads.sourceforge.net/lirc
LIRC_LIBTOOL_PATCH = NO
LIRC_INSTALL_STAGING = YES
LIRC_INSTALL_TARGET = YES
LIRC_DEPENDENCIES = host-autoconf


LIRC_CONF_OPT = --without-x --with-kerneldir=$(KDIR)
#LIRC_CONF_OPT = --with-x --without-transmitter \


ifeq ($(BR2_PACKAGE_LIRC_ALL),y)
LIRC_CONF_OPT += --with-driver=all
endif
ifeq ($(BR2_PACKAGE_LIRC_USERSPACE),y)
LIRC_CONF_OPT += --with-driver=userspace
endif
ifeq ($(BR2_PACKAGE_LIRC_STM),y)
LIRC_CONF_OPT += --with-driver=stm
endif
ifeq ($(BR2_PACKAGE_LIRC_NONE),y)
LIRC_CONF_OPT += --with-driver=none
endif

define LIRC_AUTORECONFIGURE
#	cd $(LIRC_SRCDIR) && PERLLIB=$$PERLLIB:$(HOST_DIR)/usr/share/autoconf $(HOST_DIR)/usr/bin/autoreconf
	cd $(LIRC_SRCDIR) && $(AUTORECONF)
#	cd $(LIRC_SRCDIR) && autoreconf
endef

define LIRC_INSTALL_TARGET_SCRIPTS
	mkdir -p $(TARGET_DIR)/etc/init.d
	$(INSTALL) -m 0755 package/elecard/lirc/S70lircd $(TARGET_DIR)/etc/init.d/
endef

define LIRC_INSTALL_TARGET_SCRIPTS_2
	mkdir -p $(TARGET_DIR)/etc/init.d
	$(INSTALL) -m 0755 package/elecard/lirc/S70lircd $(TARGET_DIR)/etc/init.d/
	$(INSTALL) -m 0555 $(LIRC_SRCDIR)tools/irw $(TARGET_DIR)/usr/bin
	$(INSTALL) -m 0555 $(LIRC_SRCDIR)daemons/lircd $(TARGET_DIR)/usr/sbin
endef

define LIRC_UNINSTALL_TARGET_SCRIPTS
	rm -f $(TARGET_DIR)/etc/init.d/S70lircd
endef

define LIRC_UNINSTALL_TARGET_SCRIPTS_2
	rm -f $(TARGET_DIR)/etc/init.d/S70lircd
	rm -f $(TARGET_DIR)/usr/sbin/lircd
	rm -f $(TARGET_DIR)/usr/bin/irw
endef

LIRC_PRE_CONFIGURE_HOOKS += LIRC_AUTORECONFIGURE
LIRC_POST_INSTALL_TARGET_HOOKS += LIRC_INSTALL_TARGET_SCRIPTS
#LIRC_POST_INSTALL_STAGING_HOOKS += LIRC_INSTALL_TARGET_SCRIPTS_2
LIRC_POST_UNINSTALL_TARGET_HOOKS += LIRC_UNINSTALL_TARGET_SCRIPTS
#LIRC_POST_UNINSTALL_STAGING_HOOKS += LIRC_UNINSTALL_TARGET_SCRIPTS_2

$(eval $(call AUTOTARGETS,package/elecard,lirc))
