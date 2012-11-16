#############################################################
#
# snmp
#
#############################################################
include package/elecard/overlayTemplate.mk

SNMP_VERSION:=2012.11.16
SNMP_SOURCE:=elc-snmp-bin-$(SNMP_VERSION).tar.xz
SNMP_SITE:=$(ELECARD_SMITHY_TARBALLS)
SNMP_DEPENDENCIES:=libglib2_bin

$(eval $(call ELC_OVERLAY_TEMPLATE,snmp))
