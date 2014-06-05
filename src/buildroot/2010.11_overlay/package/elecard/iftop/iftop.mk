#############################################################
#
# iftop
#
#############################################################

IFTOP_VERSION = 0.17
IFTOP_SOURCE = iftop-$(IFTOP_VERSION).tar.gz
IFTOP_SITE = http://www.ex-parrot.com/pdw/iftop/download/
IFTOP_LIBTOOL_PATCH = NO
IFTOP_INSTALL_STAGING = YES
IFTOP_INSTALL_TARGET = NO
IFTOP_DEPENDENCIES = host-autoconf libpcap ncurses


#IFTOP_CONF_OPT = --without-x --with-kerneldir=$(KDIR)

$(eval $(call AUTOTARGETS,package/elecard,iftop))
