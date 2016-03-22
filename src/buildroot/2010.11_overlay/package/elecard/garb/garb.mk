#############################################################
#
# garb overlays
#
#############################################################
include package/elecard/overlayTemplate.mk

GARB_VERSION:=2016.03.03
GARB_SOURCE:=elc-garb-bin-$(GARB_VERSION).tar.xz
ifeq ($(STB830_SDK),)
GARB_SITE:=$(ELECARD_SMITHY_TARBALLS)
else
GARB_SITE:=$(ELECARD_UPLOAD_SERVER)
endif
GARB_DEPENDENCIES:=libglib2_bin

$(eval $(call ELC_OVERLAY_TEMPLATE,garb))
