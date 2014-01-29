#############################################################
#
# oscam overlays
#
#############################################################
include package/elecard/overlayTemplate.mk

OSCAM_VERSION:=2014.01.20
OSCAM_SOURCE:=elc-oscam-bin-$(OSCAM_VERSION).tar.xz
OSCAM_SITE:=$(ELECARD_SMITHY_TARBALLS)
OSCAM_DEPENDENCIES:=libglib2_bin

$(eval $(call ELC_OVERLAY_TEMPLATE,oscam))
