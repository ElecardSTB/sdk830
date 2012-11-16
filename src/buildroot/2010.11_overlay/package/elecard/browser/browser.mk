#############################################################
#
# browser
#
#############################################################
include package/elecard/overlayTemplate.mk

BROWSER_VERSION:=2012.11.16
BROWSER_SOURCE:=elc-browser-bin-$(BROWSER_VERSION).tar.xz
BROWSER_SITE:=$(ELECARD_SMITHY_TARBALLS)
BROWSER_DEPENDENCIES:=libglib2_bin

$(eval $(call ELC_OVERLAY_TEMPLATE,browser))
