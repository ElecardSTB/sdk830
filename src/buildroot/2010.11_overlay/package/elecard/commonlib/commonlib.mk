#############################################################
#
# commonlib netLib
#
#############################################################

ifeq ($(STB830_SDK),)
COMMONLIB_DIR=$(PRJROOT)/src/elecard/apps/COMMONLib
NETLIB_DIR=$(PRJROOT)/src/elecard/apps/NETLib

commonlib-make:
	#we should pass NEW_SUM define for using correct calculate checksum algo for both target and host platform!!!
	make BUILD_TARGET=sh4/ CROSS_COMPILE=sh4-linux- STAGINGDIR=$(STAGING_DIR) ROOTFS=$(TARGET_DIR) CFLAGS="-DNEW_SUM" -C $(COMMONLIB_DIR)
	make BUILD_TARGET=x86_new_sum/ CFLAGS="-fno-stack-protector -DNEW_SUM -DLOCK_DPRINT" -C $(COMMONLIB_DIR)

netlib-make:
	make BUILD_TARGET=sh4/ CROSS_COMPILE=sh4-linux- STAGINGDIR=$(STAGING_DIR) ROOTFS=$(TARGET_DIR) -C $(NETLIB_DIR)
	make BUILD_TARGET=sh4/ CROSS_COMPILE=sh4-linux- STAGINGDIR=$(STAGING_DIR) ROOTFS=$(TARGET_DIR) -C $(NETLIB_DIR)/ex/RTPTest

commonlib-install: commonlib-make
netlib-install: netlib-make

commonlib-clean:
	make BUILD_TARGET=sh4/ -C $(COMMONLIB_DIR) clean
	make BUILD_TARGET=x86_new_sum/ -C $(COMMONLIB_DIR) clean

netlib-clean:
	make BUILD_TARGET=sh4/ -C $(NETLIB_DIR) clean
	make BUILD_TARGET=sh4/ -C $(NETLIB_DIR)/ex/RTPTest clean

else #ifeq ($(STB830_SDK),)
include package/elecard/sdk_env
COMMONLIB_PACKAGE:=commonlib-$(COMMONLIB_PACK_VERSION).tar.gz
COMMONLIB_PACKAGE_DIR:=$(BUILD_DIR)/commonlib-$(COMMONLIB_PACK_VERSION)
COMMONLIB_DIR:=$(COMMONLIB_PACKAGE_DIR)/COMMONLib
NETLIB_DIR:=$(COMMONLIB_PACKAGE_DIR)/NETLib

$(DL_DIR)/$(COMMONLIB_PACKAGE):
	 $(call DOWNLOAD,$(ELECARD_UPLOAD_SERVER),$(COMMONLIB_PACKAGE))

$(COMMONLIB_PACKAGE_DIR)/.unpacked: $(DL_DIR)/$(COMMONLIB_PACKAGE)
	mkdir -p $(COMMONLIB_PACKAGE_DIR)
	$(ZCAT) $(DL_DIR)/$(COMMONLIB_PACKAGE) | tar -C $(COMMONLIB_PACKAGE_DIR) $(TAR_OPTIONS) -
	touch $@

netlib-install commonlib-install: $(COMMONLIB_PACKAGE_DIR)/.unpacked

commonlib-dirclean:
	rm -rf $(COMMONLIB_PACKAGE_DIR)

endif #ifeq ($(STB830_SDK),)

commonlib-install:
	mkdir -p $(STAGING_DIR)/opt/elecard/lib $(STAGING_DIR)/opt/elecard/include $(HOST_DIR)/usr/lib
	install -m 755 -p $(COMMONLIB_DIR)/sh4/libcommon.* $(STAGING_DIR)/opt/elecard/lib
	install -m 755 -p $(COMMONLIB_DIR)/x86_new_sum/libcommon.* $(HOST_DIR)/usr/lib
	install -m 755 -p $(COMMONLIB_DIR)/sh4/*.h $(STAGING_DIR)/opt/elecard/include
	mkdir -p $(TARGET_DIR)/opt/elecard/lib
	install -m 755 -p $(COMMONLIB_DIR)/sh4/libcommon.so $(TARGET_DIR)/opt/elecard/lib

netlib-install:
	mkdir -p $(STAGING_DIR)/opt/elecard/lib $(STAGING_DIR)/opt/elecard/include
	install -m 755 -p $(NETLIB_DIR)/sh4/libnet.* $(STAGING_DIR)/opt/elecard/lib
	install -m 755 -p $(NETLIB_DIR)/sh4/*.h $(STAGING_DIR)/opt/elecard/include
	mkdir -p $(TARGET_DIR)/opt/elecard/lib $(TARGET_DIR)/opt/elecard/bin
	install -m 755 -p $(NETLIB_DIR)/sh4/libnet.so $(TARGET_DIR)/opt/elecard/lib
	install -m 755 -p $(NETLIB_DIR)/ex/RTPTest/sh4/rtptest $(TARGET_DIR)/opt/elecard/bin

commonlib: commonlib-install netlib-install

ifeq ($(BR2_PACKAGE_COMMONLIB),y)
TARGETS+=commonlib
endif
