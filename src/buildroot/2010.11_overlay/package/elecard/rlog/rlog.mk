#############################################################
#
# rlog
#
#############################################################
RLOG_VERSION:=1.4
RLOG_SOURCE:=rlog-$(RLOG_VERSION).tar.gz
RLOG_SITE:=http://rlog.googlecode.com/files/
RLOG_INSTALL_STAGING = YES

$(eval $(call AUTOTARGETS,package/elecard,rlog))
#$(eval $(call GENTARGETS,package/elecard,rlog))

