##########################################################
#
# CCID
#
# ########################################################
CCID_VERSION = 1.4.4
CCID_SOURCE = ccid-$(CCID_VERSION).tar.bz2
CCID_SITE = https://alioth.debian.org/frs/download.php/3579
CCID_INSTALL_STAGING = YES
CCID_INSTALL_TARGET = YES
CCID_DEPENDENCIES = pkg-config libusb pcsc-lite

$(eval $(call AUTOTARGETS, package, ccid))
