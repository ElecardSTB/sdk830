#############################################################
#
# mkfs
#
#############################################################
include package/elecard/overlayTemplate.mk

MKFS_VERSION:=2015.04.14
MKFS_SOURCE:=elc-mkfsext2-bin-$(MKFS_VERSION).tar.xz
MKFS_SITE:=$(ELECARD_SMITHY_TARBALLS)

$(eval $(call ELC_OVERLAY_TEMPLATE,mkfs))
