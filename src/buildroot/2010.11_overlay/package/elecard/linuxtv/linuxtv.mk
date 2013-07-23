#############################################################
#
# LinuxTV project
#
#############################################################

include package/elecard/sdk_env

LINUXTV_VERSION := 13-07-23
LINUXTV_SOURCE := media_build-elc-$(LINUXTV_VERSION).tar.gz
LINUXTV_SITE := $(ELECARD_UPLOAD_SERVER)
# LINUXTV_INSTALL_TARGET := YES
LINUXTV_DEPENDENCIES := 

LINUXTV_CFG_FILE := package/elecard/linuxtv/linuxtv-$(LINUXTV_VERSION).config
LINUXTV_MAKE_OPTS := DIR=$(KDIR) SRCDIR=$(KDIR) ARCH=sh CROSS_COMPILE=sh4-linux- DESTDIR=$(TARGET_DIR)/ KDIR26=lib/modules/2.6.32.57_stm24_V5.0-hdk7105/linuxtv

define LINUXTV_CONFIGURE_CMDS
	cp $(LINUXTV_CFG_FILE) $(LINUXTV_DIR)/v4l/.config
endef

define LINUXTV_BUILD_CMDS
	make -C $(LINUXTV_DIR) $(LINUXTV_MAKE_OPTS)
endef

define LINUXTV_INSTALL_TARGET_CMDS
	make -C $(LINUXTV_DIR) $(LINUXTV_MAKE_OPTS) modules_install
endef

define LINUXTV_DOWNLOAD_LINUXTV_MEDIA
	$(call MESSAGE,download linuxtv drivers)
	make -C $(LINUXTV_DIR) download
	$(call MESSAGE,unpack linuxtv drivers)
	make -C $(LINUXTV_DIR) untar
endef

LINUXTV_POST_EXTRACT_HOOKS += LINUXTV_DOWNLOAD_LINUXTV_MEDIA

$(eval $(call GENTARGETS,package/elecard,linuxtv))

$(LINUXTV_TARGET_BUILD): $(KDIR)/.config $(LINUXTV_DIR)/v4l/.config
$(LINUXTV_TARGET_CONFIGURE): $(LINUXTV_CFG_FILE)
$(LINUXTV_TARGET_INSTALL_TARGET): $(LINUXTV_TARGET_BUILD)

linuxtv-menuconfig:
	make -C $(LINUXTV_DIR) $(LINUXTV_MAKE_OPTS) menuconfig
