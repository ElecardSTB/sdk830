#############################################################
#
# Pure FTPD
#
#############################################################

PURE_FTPD_VERSION = 1.0.36
PURE_FTPD_SOURCE = pure-ftpd-$(PURE_FTPD_VERSION).tar.gz
PURE_FTPD_SITE = ftp://ftp.pureftpd.org/pub/pure-ftpd/releases
PURE_FTPD_LIBTOOL_PATCH = NO
PURE_FTPD_INSTALL_STAGING = YES
PURE_FTPD_INSTALL_TARGET = YES
PURE_FTPD_DEPENDENCIES = host-autoconf


PURE_FTPD_CONF_OPT = --with-minimal


$(eval $(call AUTOTARGETS,package/elecard,pure-ftpd))

pure-ftpd-menuconfig:
	@echo TARGET_MAKE_ENV=$(TARGET_MAKE_ENV)
	@echo PURE_FTPD_MAKE_ENV=$(PURE_FTPD_MAKE_ENV)
	@echo PURE_FTPD_DIR=$(PURE_FTPD_DIR)
	$(TARGET_MAKE_ENV) $(PURE_FTPD_MAKE_ENV) make -C $(PURE_FTPD_DIR) menuconfig
