##########################################################
#
# PCSC-Lite
#
# ########################################################
PCSC_LITE_VERSION = 1.8.10
PCSC_LITE_SOURCE = pcsc-lite-$(PCSC_LITE_VERSION).tar.bz2
PCSC_LITE_SITE = https://alioth.debian.org/frs/download.php/3516
PCSC_LITE_INSTALL_STAGING = YES
PCSC_LITE_INSTALL_TARGET = YES
PCSC_LITE_CONF_OPT = --disable-libudev --disable-libhal --enable-libusb --enable-embedded
PCSC_LITE_DEPENDENCIES = libusb

define PCSC_LITE_TARGET_FILES_INSTALL
	$(INSTALL) -m0644 package/elecard/pcsc-lite/reader.conf $(TARGET_DIR)/etc/reader.conf
	$(INSTALL) -m0755 package/elecard/pcsc-lite/pcsc.init $(TARGET_DIR)/etc/init.d/S71pcsc
endef

define PCSC_LITE_UNINSTALL_TARGET_CMDS
	-rm -f $(TARGET_DIR)/etc/reader.conf
	-rm -f $(TARGET_DIR)/etc/init.d/S71pcsc
endef

PCSC_LITE_POST_INSTALL_TARGET_HOOKS += PCSC_LITE_TARGET_FILES_INSTALL

$(eval $(call AUTOTARGETS, package/elecard, pcsc-lite))
