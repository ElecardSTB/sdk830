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
	$(UPDATER_DEFINES) TARGET_DIR=$(TARGET_DIR) STAGINGDIR=$(STAGING_DIR) make -C $(UPDATER_DIR) $(UPDATER_MAKE_TARGETS)

firmwarePackGenerator-host-make:
	$(UPDATER_DEFINES) HOST_DIR=$(HOST_DIR) make -C $(UPDATER_DIR) make_firmwarePackGenerator

updater-install updaterDaemon-install hwconfig-install: updater-make
firmwarePackGenerator-host-install: firmwarePackGenerator-host-make

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

updater-install updaterDaemon-install hwconfig-install firmwarePackGenerator-host-install: $(UPDATER_DIR)/.unpacked
endif #ifeq ($(STB830_SDK),)

updater_target_dir:
	mkdir -p $(TARGET_DIR)/opt/elecard/bin/

updater-install: updater_target_dir
	install -m 755 -p $(UPDATER_DIR)/clientUpdater2/sh4/$(FS_TYPE)/clientUpdater $(TARGET_DIR)/opt/elecard/bin/clientUpdater

updaterDaemon-install: updater_target_dir
	install -m 755 -p $(UPDATER_DIR)/updaterDaemon/sh4/updaterDaemon $(TARGET_DIR)/opt/elecard/bin/

hwconfig-install: updater_target_dir
	install -m 755 -p $(UPDATER_DIR)/hwconfigManager/sh4/hwconfigManager $(TARGET_DIR)/opt/elecard/bin/
	install -m 755 -p $(UPDATER_DIR)/hwconfig/hwconfig_stb830.conf $(TARGET_DIR)/etc/hwconfig.conf

updater-uninstall:
	rm -f $(TARGET_DIR)/opt/elecard/bin/hwconfigManager $(TARGET_DIR)/opt/elecard/bin/clientUpdater $(TARGET_DIR)/opt/elecard/bin/updaterDaemon $(TARGET_DIR)/etc/hwconfig_stb830.conf

updater: $(UPDATER_DEPENDENCIES) updater-install
hwconfig: $(UPDATER_DEPENDENCIES) hwconfig-install
updaterDaemon: $(UPDATER_DEPENDENCIES) updaterDaemon-install

ifeq ($(BR2_PACKAGE_UPDATER),y)
updater-packages: updater
UPDATER_MAKE_TARGETS+=make_updater
endif
ifeq ($(BR2_PACKAGE_UPDATER_HWCONFIG),y)
updater-packages: hwconfig
UPDATER_MAKE_TARGETS+=make_hwconfigManager
endif
ifeq ($(BR2_PACKAGE_UPDATER_DAEMON),y)
updater-packages: updaterDaemon
UPDATER_MAKE_TARGETS+=make_updaterDaemon
endif

firmwarePackGenerator-host-install:
	mkdir -p $(HOST_DIR)/usr/bin
	install -m 755 -p $(UPDATER_DIR)/firmwarePackGenerator/x86_new_sum/firmwarePackGenerator $(HOST_DIR)/usr/bin

firmwarePackGenerator-host: commonlib firmwarePackGenerator-host-install

TARGETS+=firmwarePackGenerator-host
ifneq ($(filter y,$(BR2_PACKAGE_UPDATER) $(BR2_PACKAGE_UPDATER_HWCONFIG) $(BR2_PACKAGE_UPDATER_DAEMON)),)
TARGETS+=updater-packages
endif
