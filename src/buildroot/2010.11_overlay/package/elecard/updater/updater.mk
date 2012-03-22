#############################################################
#
# updater
#
#############################################################

UPDATER_DEPENDENCIES = commonlib

ifeq ($(BR2_PACKAGE_UPDATER_USE_HTTP),y)
UPDATER_DEPENDENCIES += libcurl
UPDATER_DEFINES += HTTP_UPDATE=1
endif

ifeq ($(BR2_PACKAGE_UPDATER_USE_SSL),y)
UPDATER_DEPENDENCIES += openssl
UPDATER_DEFINES += CHECK_SIGNATURES=1
endif

ifeq ($(STB830_SDK),)
UPDATER_DIR=$(PRJROOT)/src/elecard/updater

updater-make:
	$(UPDATER_DEFINES) TARGET_DIR=$(TARGET_DIR) STAGINGDIR=$(STAGING_DIR) make -C $(UPDATER_DIR) make_updater

updater-hwconfig-make:
	$(UPDATER_DEFINES) TARGET_DIR=$(TARGET_DIR) STAGINGDIR=$(STAGING_DIR) make -C $(UPDATER_DIR) make_hwconfigManager

firmwarePackGenerator-make:
	$(UPDATER_DEFINES) HOST_DIR=$(HOST_DIR) make -C $(UPDATER_DIR) make_firmwarePackGenerator

updater-install: updater-make
updater-hwconfig-install: updater-hwconfig-make
firmwarePackGenerator-install: firmwarePackGenerator-make

else #ifeq ($(STB830_SDK),)
include package/elecard/sdk_env
UPDATER_PACKAGE:=updater-$(UPDATER_PACK_VERSION).tar.gz
UPDATER_DIR:=$(BUILD_DIR)/updater-$(UPDATER_PACK_VERSION)

$(DL_DIR)/$(UPDATER_PACKAGE):
	 $(call DOWNLOAD,$(ELECARD_UPLOAD_SERVER),$(UPDATER_PACKAGE))

$(UPDATER_DIR)/.unpacked: $(DL_DIR)/$(UPDATER_PACKAGE)
	mkdir -p $(UPDATER_DIR)
	$(ZCAT) $(DL_DIR)/$(UPDATER_PACKAGE) | tar -C $(UPDATER_DIR) $(TAR_OPTIONS) -
	touch $@

updater-install updater-hwconfig-install firmwarePackGenerator-install: $(UPDATER_DIR)/.unpacked
endif #ifeq ($(STB830_SDK),)


updater-hwconfig-install:
	mkdir -p $(TARGET_DIR)/opt/elecard/bin/
	install -m 755 -p $(UPDATER_DIR)/hwconfigManager/sh4/hwconfigManager $(TARGET_DIR)/opt/elecard/bin/
	install -m 755 -p $(UPDATER_DIR)/hwconfig/hwconfig_stb830.conf $(TARGET_DIR)/etc/hwconfig.conf

updater-install: updater-hwconfig
	install -m 755 -p $(UPDATER_DIR)/clientUpdater2/sh4/clientUpdater $(TARGET_DIR)/opt/elecard/bin/

updater-uninstall:
	rm -f $(TARGET_DIR)/opt/elecard/bin/hwconfigManager $(TARGET_DIR)/opt/elecard/bin/clientUpdater $(TARGET_DIR)/etc/hwconfig_stb830.conf

firmwarePackGenerator-install:
	mkdir -p $(HOST_DIR)/usr/bin
	install -m 755 -p $(UPDATER_DIR)/firmwarePackGenerator/x86_new_sum/firmwarePackGenerator $(HOST_DIR)/usr/bin

updater-hwconfig: $(UPDATER_DEPENDENCIES) updater-hwconfig-install
updater: $(UPDATER_DEPENDENCIES) updater-install
firmwarePackGenerator: commonlib firmwarePackGenerator-install

TARGETS+=firmwarePackGenerator
ifeq ($(BR2_PACKAGE_UPDATER),y)
TARGETS+=updater
else
ifeq ($(BR2_PACKAGE_UPDATER_HWCONFIG),y)
TARGETS+=updater-hwconfig
endif
endif
