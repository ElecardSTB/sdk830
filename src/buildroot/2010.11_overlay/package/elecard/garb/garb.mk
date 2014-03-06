#############################################################
#
# garb overlays
#
#############################################################
include package/elecard/overlayTemplate.mk

GARB_VERSION:=2014.03.05
GARB_SOURCE:=elc-garb-bin-$(GARB_VERSION).tar.xz
GARB_SITE:=$(ELECARD_SMITHY_TARBALLS)
GARB_DEPENDENCIES:=libglib2_bin

$(eval $(call ELC_OVERLAY_TEMPLATE,garb))
