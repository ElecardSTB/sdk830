#############################################################
#
# xl2tpd
#
#############################################################
XL2TPD_VERSION = 1.3.0
XL2TPD_SOURCE = xl2tpd-$(XL2TPD_VERSION).tar.gz
XL2TPD_SITE = ftp://ftp.xelerance.com/xl2tpd/

XL2TPD_DEPENDENCIES = libpcap

define XL2TPD_BUILD_CMDS
	$(MAKE) CC=$(TARGET_CROSS)gcc -C $(@D) xl2tpd
endef

define XL2TPD_INSTALL_TARGET_CMDS
	$(INSTALL) $(@D)/xl2tpd $(TARGET_DIR)/usr/sbin/
endef

define XL2TPD_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/usr/sbin/xl2tpd
endef

define XL2TPD_CLEAN_CMDS
	-$(MAKE) -C $(@D) clean
endef

$(eval $(call GENTARGETS, package/elecard, xl2tpd))
