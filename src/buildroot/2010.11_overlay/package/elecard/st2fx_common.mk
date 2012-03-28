
ifeq ($(_ST2FX_COMMON_MK_),)
_ST2FX_COMMON_MK_:=1

ifeq ($(STB830_SDK),)
include $(STSDKROOT)/apilib/src/st2fx/make/specific.mak
LIBPNG:=$(PNG)

define GENTARGETS_ST2FX_INNER

$(2)_SOURCE_DIR=$(STSDKROOT)/apilib/src/st2fx/src/$$($(2))
$(2)_NAME=$(1)
DERIVED_OBJS:=_32BITS
ST_OBJS_DIR:=$(STSDKROOT)/apilib/lib/$(DVD_PLATFORM)_$(DVD_BACKEND)_$(ARCHITECTURE)$(DVD_CPU)_$(DVD_OS)$(DERIVED_OBJS)


#$(2)_LIBS=$(sort $(wildcard $(STSDKROOT)/apilib/lib/$(DVD_PLATFORM)_$(DVD_BACKEND)_$(ARCHITECTURE)$(DVD_CPU)_$(DVD_OS)_32BITS/$(3).so*))
$(2)_HEADERS=$(sort $(wildcard $(STSDKROOT)/apilib/include/$(4)/*))

$(2)_INSTALL_TS = $(BUILD_DIR)/.$(1)_installed $$($(2)_SOURCE_DIR)/.installed


$$($(2)_SOURCE_DIR)/.compiled:
	$(MAKE) -C $$($(2)_SOURCE_DIR)
	touch $$@


#$$($(2)_SOURCE_DIR)/.installed: $$($(2)_SOURCE_DIR)/.compiled $$($(2)_LIBS)
$$($(2)_INSTALL_TS): $$($(2)_SOURCE_DIR)/.compiled
	cp -dfr $(STSDKROOT)/apilib/include/$(4)/* $(STAGING_DIR)/usr/include
	cp -df $$(ST_OBJS_DIR)/$(3).so* $(STAGING_DIR)/usr/lib
	cp -df $$(ST_OBJS_DIR)/$(3).so* $(TARGET_DIR)/usr/lib
	touch $$@


$(1)-clean:
	$(MAKE) -C $$($(2)_SOURCE_DIR) clean
	rm -f $$($(2)_SOURCE_DIR)/.compiled

$(1)-install: $$($(2)_INSTALL_TS)


$(1)-uninstall:
	rm -f $(STAGING_DIR)/usr/lib/$(3).so* $(TARGET_DIR)/usr/lib/$(3).so*
	for i in $$($(2)_HEADERS); do rm -fr $(STAGINGDIR)/usr/include/`basename $$$$i`; done
	rm -f $$($(2)_INSTALL_TS)


$(1): stapisdk-apilib $$($(2)_DEPENDENCIES) $$($(2)_INSTALL_TS)


TARGETS += $(1)

endef #define GENTARGETS_ST2FX_INNER


define GENTARGETS_ST2FX_DIRECTFB_INNER
DIRECTFB_ST_SOURCE_DIR=$(STSDKROOT)/apilib/src/st2fx/src/$(DIRECTFB)
DIRECTFB_ST_DEPENDENCIES = stapisdk-apilib zlib jpeg tiff freetype libpng

DIRECTFB_ST_ST2FX_COMMON_DIR := $(STSDKROOT)/apilib/src/st2fx/src/common
DIRECTFB_ST_ST2FX_EXTENSION_DIR=$(STSDKROOT)/apilib/src/st2fx/src/extensions

DERIVED_OBJS:=_32BITS
DIRECTFB_ST_LIBS_DIR=$(STSDKROOT)/apilib/lib/$(DVD_PLATFORM)_$(DVD_BACKEND)_$(ARCHITECTURE)$(DVD_CPU)_$(DVD_OS)$$(DERIVED_OBJS)
DIRECTFB_ST_MAIN_LIBS=	libdirectfb-$(ST2FX_DIRECTFB_VERSION)*.so* \
				libdirect-$(ST2FX_DIRECTFB_VERSION)*.so* \
				libfusion-$(ST2FX_DIRECTFB_VERSION)*.so* \
				libst2fx.so* \
				libbmp.so* \
				libgif.so*

#				libshm.so* \

DIRECTFB_INSTALL_TS = $(BUILD_DIR)/.directfb_installed $$(DIRECTFB_ST_SOURCE_DIR)/.installed

$$(DIRECTFB_ST_SOURCE_DIR)/.compiled:
	$(MAKE) -C $$(DIRECTFB_ST_ST2FX_COMMON_DIR)
	$(MAKE) -C $(STSDKROOT)/apilib/src/st2fx/src/$(BMP)
	$(MAKE) -C $(STSDKROOT)/apilib/src/st2fx/src/$(GIF)
	$(MAKE) -C $$(DIRECTFB_ST_SOURCE_DIR)
	$(MAKE) -C $$(DIRECTFB_ST_ST2FX_EXTENSION_DIR)
#	$(MAKE) -C $(STSDKROOT)/apilib/src/st2fx/src
	touch $$@

$$(DIRECTFB_INSTALL_TS): $$(DIRECTFB_ST_SOURCE_DIR)/.compiled
	rm -rf $(STAGING_DIR)/usr/include/directfb-$(ST2FX_DIRECTFB_VERSION)
	rm -rf $(STAGING_DIR)/usr/include/directfb
	cp -dfr $(STSDKROOT)/apilib/include/directfb $(STAGING_DIR)/usr/include/directfb-$(ST2FX_DIRECTFB_VERSION)
#	if [ ! -e $(STAGING_DIR)/usr/include/directfb ]; then ln -s directfb-$(ST2FX_DIRECTFB_VERSION) $(STAGING_DIR)/usr/include/directfb; fi
	ln -s directfb-$(ST2FX_DIRECTFB_VERSION) $(STAGING_DIR)/usr/include/directfb
	cd $$(DIRECTFB_ST_LIBS_DIR) && cp -df $$(DIRECTFB_ST_MAIN_LIBS) $(STAGING_DIR)/usr/lib
	cd $$(DIRECTFB_ST_LIBS_DIR) && cp -dfr `find -name directfb-$(ST2FX_DIRECTFB_VERSION)* -type d` $(STAGING_DIR)/usr/lib
	cd $$(DIRECTFB_ST_LIBS_DIR) && cp -df $$(DIRECTFB_ST_MAIN_LIBS) $(TARGET_DIR)/usr/lib
	cd $$(DIRECTFB_ST_LIBS_DIR) && cp -dfr `find -name directfb-$(ST2FX_DIRECTFB_VERSION)* -type d` $(TARGET_DIR)/usr/lib
	touch $$@

directfb-clean:
	$(MAKE) -C $$(DIRECTFB_ST_ST2FX_COMMON_DIR) clean
	$(MAKE) -C $(STSDKROOT)/apilib/src/st2fx/src/libbmp clean
	$(MAKE) -C $(STSDKROOT)/apilib/src/st2fx/src/giflib-4.1.6 clean
	$(MAKE) -C $$(DIRECTFB_ST_SOURCE_DIR) clean
	$(MAKE) -C $$(DIRECTFB_ST_ST2FX_EXTENSION_DIR) clean
	rm -f $$(DIRECTFB_ST_SOURCE_DIR)/.compiled

directfb-install: $$(DIRECTFB_INSTALL_TS)

directfb-uninstall:
	cd $(STAGING_DIR)/usr/lib && rm -f $$(DIRECTFB_ST_MAIN_LIBS) && find -name directfb-$(ST2FX_DIRECTFB_VERSION)* -type d | xargs rm -fr
	cd $(TARGET_DIR)/usr/lib && rm -f $$(DIRECTFB_ST_MAIN_LIBS) && find -name directfb-$(ST2FX_DIRECTFB_VERSION)* -type d | xargs rm -fr
	rm -fr $(STAGING_DIR)/usr/include/directfb-$(ST2FX_DIRECTFB_VERSION) $(STAGING_DIR)/usr/include/directfb
	rm -f $$(DIRECTFB_INSTALL_TS)

directfb: $$(DIRECTFB_ST_DEPENDENCIES) $$(DIRECTFB_INSTALL_TS)

TARGETS+=directfb
endef #define GENTARGETS_ST2FX_DIRECTFB_INNER

define GENTARGETS_ST2FX_DIRECTFB
$(eval $(call GENTARGETS_ST2FX_DIRECTFB_INNER,))
endef

define GENTARGETS_ST2FX
$(eval $(call GENTARGETS_ST2FX_INNER,$(1),$(call UPPERCASE,$(1)),$(2),$(3)))
endef

else #ifeq ($(STB830_SDK),)
include package/elecard/sdk_env
ST2FX_PACKAGE:=st2fx-$(ST2FX_PACK_VERSION).tar.gz
ST2FX_DIR:=$(BUILD_DIR)/st2fx-$(ST2FX_PACK_VERSION)

$(DL_DIR)/$(ST2FX_PACKAGE):
	 $(call DOWNLOAD,$(ELECARD_UPLOAD_SERVER),$(ST2FX_PACKAGE))

$(ST2FX_DIR)/.unpacked: $(DL_DIR)/$(ST2FX_PACKAGE)
	mkdir -p $(ST2FX_DIR)
	$(ZCAT) $(DL_DIR)/$(ST2FX_PACKAGE) | tar -C $(ST2FX_DIR) $(TAR_OPTIONS) -
	touch $@

$(ST2FX_DIR)/.installed: $(ST2FX_DIR)/.unpacked
	for i in bmp freetype gif jpeg png tiff zlib; do cp -rf $(ST2FX_DIR)/include/$$i/* $(STAGING_DIR)/usr/include/; done
	cd $(ST2FX_DIR)/include; for i in `ls | grep directfb`; do rm -rf $(STAGING_DIR)/usr/include/$$i; cp -rf $$i $(STAGING_DIR)/usr/include/; done
	cp -rf $(ST2FX_DIR)/lib/sdk7105_7105_ST40_LINUX_32BITS/* $(STAGING_DIR)/usr/lib/
	cp -rf $(ST2FX_DIR)/lib/sdk7105_7105_ST40_LINUX_32BITS/* $(TARGET_DIR)/usr/lib/
	touch $@

define GENTARGETS_ST2FX_DIRECTFB
directfb: $$(ST2FX_DIR)/.installed
TARGETS+=directfb
endef

define GENTARGETS_ST2FX
$(1): $$(ST2FX_DIR)/.installed
TARGETS+=$(1)
endef

endif #ifeq ($(STB830_SDK),)

endif #ifeq ($(_ST2FX_COMMON_MK_),)
