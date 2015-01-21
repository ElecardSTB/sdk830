#############################################################
#
# encfs
#
#############################################################
ENCFS_VERSION:=1.7.4
ENCFS_SOURCE:=encfs-$(ENCFS_VERSION).tgz
ENCFS_SITE:=http://encfs.googlecode.com/files/
ENCFS_LIBTOOL_PATCH = NO
ENCFS_INSTALL_STAGING = YES
ENCFS_INSTALL_TARGET = YES

ENCFS_DEPENDENCIES += boost libfuse rlog

ENCFS_CONF_OPT =--with-boost-libdir=$(STAGING_DIR)/usr/lib 
#--without-boost

ENCFS_CONF_ENV = CPPFLAGS="-I$(STAGING_DIR)/usr/include/fuse -I$(STAGING_DIR)/usr/include/boost" 
ENCFS_CONF_ENV += LDFLAGS="-L$(STAGING_DIR)/usr/lib -lboost_serialization -lboost_system"

$(eval $(call AUTOTARGETS,package/elecard,encfs))


