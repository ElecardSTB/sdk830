#############################################################
#
# Elecards private modules.
#
#############################################################

MODULES_ELECARD_DEPENDENCES=
ifeq ($(STB830_SDK),)

modules-elecard-install:
	make -C $(PRJROOT)/src/elecard/modules all

modules-elecard-dirclean modules-elecard-clean:
	make -C $(PRJROOT)/src/elecard/modules clean

else #ifeq ($(STB830_SDK),)

include package/elecard/sdk_env
MODULES_ELECARD_PACKAGE:=modules-elecard-$(MODULES_ELECARD_PACK_VERSION).tar.gz
MODULES_ELECARD_PACKAGE_DIR:=$(BUILD_DIR)/modules-elecard-$(MODULES_ELECARD_PACK_VERSION)
INSTALL_DIR := $(TARGET_DIR)/lib/modules/STLinux-$(LINUX_VERSION)

$(DL_DIR)/$(MODULES_ELECARD_PACKAGE):
	 $(call DOWNLOAD,$(ELECARD_UPLOAD_SERVER),$(MODULES_ELECARD_PACKAGE))

$(MODULES_ELECARD_PACKAGE_DIR)/.unpacked: $(DL_DIR)/$(MODULES_ELECARD_PACKAGE)
	mkdir -p $(MODULES_ELECARD_PACKAGE_DIR)
	$(ZCAT) $(DL_DIR)/$(MODULES_ELECARD_PACKAGE) | tar -C $(MODULES_ELECARD_PACKAGE_DIR) $(TAR_OPTIONS) -
	touch $@

modules-elecard-install: $(MODULES_ELECARD_PACKAGE_DIR)/.unpacked
	mkdir -p $(INSTALL_DIR)
	install -m 644 -p $(MODULES_ELECARD_PACKAGE_DIR)/st_dvb/st_dvb.ko $(INSTALL_DIR)

modules-elecard-dirclean modules-elecard-clean:
	rm -rf $(MODULES_ELECARD_PACKAGE_DIR)

endif #ifeq ($(STB830_SDK),)

modules-elecard: $(MODULES_ELECARD_DEPENDENCES) modules-elecard-install

ifeq ($(BR2_PACKAGE_MODULES_ELECARD),y)
TARGETS+=modules-elecard
endif
