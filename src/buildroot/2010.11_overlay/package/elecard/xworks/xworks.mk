#############################################################
#
# xworks
#
#############################################################
include package/elecard/overlayTemplate.mk

XWORKS_VERSION:=2012.11.16
XWORKS_SOURCE:=elc-xworks-bin-$(XWORKS_VERSION).tar.xz
XWORKS_SITE:=$(ELECARD_SMITHY_TARBALLS)
XWORKS_DEPENDENCIES:=libglib2_bin

$(eval $(call ELC_OVERLAY_TEMPLATE,xworks))
