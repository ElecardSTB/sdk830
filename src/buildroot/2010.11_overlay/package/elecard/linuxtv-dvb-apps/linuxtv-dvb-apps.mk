#############################################################
#
# linuxtv-dvb-apps
#
#############################################################

# changeset 1458:0c9932885287 Thu Jan 05 15:33:51 2012
LINUXTV_DVB_APPS_VERSION = 0c9932885287
LINUXTV_DVB_APPS_SOURCE = $(LINUXTV_DVB_APPS_VERSION).tar.gz
LINUXTV_DVB_APPS_SITE = http://linuxtv.org/hg/dvb-apps/archive
LINUXTV_DVB_APPS_INSTALL_STAGING = YES
LINUXTV_DVB_APPS_ALL_LIBS = libdvbapi libdvbcfg libdvben50221 libdvbsec libesg libucsi
LINUXTV_DVB_APPS_ALL_BINARIES = dib3000-watch dvbdate dvbnet dvbscan dvbtraffic gnutv scan tzap zap 

ifeq ($(BR2_PACKAGE_LINUXTV_DVB_APPS_TOOLS),y)
define BUILD_TOOLS
	$(MAKE)  $(TARGET_CONFIGURE_OPTS) -C $(LINUXTV_DVB_APPS_DIR)/util
endef
endif

define LINUXTV_DVB_APPS_BUILD_CMDS
	$(MAKE)  $(TARGET_CONFIGURE_OPTS) -C $(LINUXTV_DVB_APPS_DIR)/lib
	$(BUILD_TOOLS)
endef

define LINUXTV_DVB_APPS_CLEAN_CMDS
	$(MAKE)  $(TARGET_CONFIGURE_OPTS) -C $(LINUXTV_DVB_APPS_DIR) clean
endef

define LINUXTV_DVB_APPS_INSTALL_STAGING_CMDS
	$(MAKE)  $(TARGET_CONFIGURE_OPTS) DESTDIR=$(STAGING_DIR) -C $(LINUXTV_DVB_APPS_DIR)/lib install
endef

define LINUXTV_DVB_APPS_INSTALL_TARGET_CMDS
	for f in $(LINUXTV_DVB_APPS_ALL_LIBS); do \
		$(INSTALL) -D $(@D)/lib/$$f/$$f.so $(TARGET_DIR)/usr/lib/ ; \
		$(STRIPCMD) $(TARGET_DIR)/usr/lib/$$f.so; \
	done
endef

ifeq ($(BR2_PACKAGE_LINUXTV_DVB_APPS_TOOLS),y)
define UNINSTALL_TOOLS
	rm -f $(addprefix $(TARGET_DIR)/usr/bin/,$(LINUXTV_DVB_APPS_ALL_BINARIES))
endef
endif

define LINUXTV_DVB_APPS_UNINSTALL_TARGET_CMDS
	rm -f $(addprefix $(TARGET_DIR)/usr/lib/,$(addsuffix .so,$(LINUXTV_DVB_APPS_ALL_LIBS)))
	rm -f $(addprefix $(TARGET_DIR)/usr/lib/,$(addsuffix .a,$(LINUXTV_DVB_APPS_ALL_LIBS)))
	$(UNINSTALL_TOOLS)
endef

define LINUXTV_DVB_APPS_UNINSTALL_STAGING_CMDS
	rm -f  $(addprefix $(STAGING_DIR)/usr/lib/,$(LINUXTV_DVB_APPS_ALL_LIBS_SO))
	rm -rf $(addprefix $(STAGING_DIR)/usr/include/,$(LINUXTV_DVB_APPS_ALL_LIBS))
endef

$(eval $(call GENTARGETS,package/elecard,linuxtv-dvb-apps))
