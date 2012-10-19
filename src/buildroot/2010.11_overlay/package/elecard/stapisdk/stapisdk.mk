#############################################################
#
# stapisdk
#
#############################################################

STAPISDK_DEPENDENCIES = zlib tiff libpng jpeg freetype directfb openssl commonlib linuxtv-dvb-apps bzip2
STAPISDK_APILIB_DEPENDENCIES = elcdrpclib

elcdrpclib:
	make CROSS_COMPILE=sh4-linux- BUILD_TARGET=sh4/ -C $(PRJROOT)/src/apps/elcdRpcLib
	mkdir -p $(TARGET_DIR)/opt/elecard/lib/
	install -m 755 $(PRJROOT)/src/apps/elcdRpcLib/sh4/libelcdrpc.so $(TARGET_DIR)/opt/elecard/lib/

ifeq ($(STB830_SDK),)
stapisdk-apilib-clean:
	make -C $(PRJROOT)/src/elecard/stapisdk apilib-clean

stapisdk-all-clean:
	make -C $(PRJROOT)/src/elecard/stapisdk all-clean

stapisdk: $(STAPISDK_DEPENDENCIES)
	make -C $(PRJROOT)/src/elecard/stapisdk STAGINGDIR=$(STAGING_DIR) all

stapisdk-apilib: $(STAPISDK_APILIB_DEPENDENCIES)
	make -C $(PRJROOT)/src/elecard/stapisdk apilib_make

else #ifeq ($(STB830_SDK),)
include package/elecard/sdk_env
STAPISDK_PACKAGE:=stapisdk-$(STAPISDK_PACK_VERSION).tar.gz
STAPISDK_DIR:=$(BUILD_DIR)/stapisdk-$(STAPISDK_PACK_VERSION)

$(DL_DIR)/$(STAPISDK_PACKAGE):
	 $(call DOWNLOAD,$(ELECARD_UPLOAD_SERVER),$(STAPISDK_PACKAGE))

$(STAPISDK_DIR)/.unpacked: $(DL_DIR)/$(STAPISDK_PACKAGE)
	mkdir -p $(STAPISDK_DIR)
	$(ZCAT) $(DL_DIR)/$(STAPISDK_PACKAGE) | tar -C $(STAPISDK_DIR) $(TAR_OPTIONS) -
	touch $@

$(STAPISDK_DIR)/.installed: $(STAPISDK_DIR)/.unpacked
	cp -rf $(STAPISDK_DIR)/root/* $(TARGET_DIR)/root/
	touch $@

stapisdk: $(STAPISDK_DEPENDENCIES) $(STAPISDK_DIR)/.installed
stapisdk-apilib: $(STAPISDK_APILIB_DEPENDENCIES)
endif #ifeq ($(STB830_SDK),)


ifeq ($(BR2_PACKAGE_STAPISDK),y)
TARGETS+=stapisdk stapisdk-apilib
endif
