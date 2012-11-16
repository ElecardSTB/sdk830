#############################################################
#
# libglib2_bin
#
#############################################################
include package/elecard/overlayTemplate.mk

LIBGLIB2_BIN_VERSION:=2012.11.16
LIBGLIB2_BIN_SOURCE:=elc-libglib2-bin-$(LIBGLIB2_BIN_VERSION).tar.xz
LIBGLIB2_BIN_SITE:=$(ELECARD_SMITHY_TARBALLS)
LIBGLIB2_BIN_DEPENDENCIES:=

$(eval $(call ELC_OVERLAY_TEMPLATE,libglib2_bin))
