
ifeq ($(FS_TYPE),rootfs)
ifeq ($(_ELC_OVERLAY_TEMPLATE_MK_),)
_ELC_OVERLAY_TEMPLATE_MK_:=1

include package/elecard/sdk_env

SDK830_INSTALLED_OPTPACKS_FILE := $(BUILD_DIR)/installedOptPacks

%-install-adjast-with-config: $(SDK830_INSTALLED_OPTPACKS_FILE)
	@if ! grep "$*" $(SDK830_INSTALLED_OPTPACKS_FILE) >/dev/null; then \
		if [ `stat -c %s $(SDK830_INSTALLED_OPTPACKS_FILE)` -eq 0 ]; then \
			echo "$*" > $(SDK830_INSTALLED_OPTPACKS_FILE); \
		else \
			sed -i "1 i $*" $(SDK830_INSTALLED_OPTPACKS_FILE); \
		fi; \
	fi

%-uninstall-adjast-with-config: $(SDK830_INSTALLED_OPTPACKS_FILE)
	@if grep "$*" $(SDK830_INSTALLED_OPTPACKS_FILE) >/dev/null; then \
		sed -i "/$*/d" $(SDK830_INSTALLED_OPTPACKS_FILE);\
	fi;

target-finalize: uninstall-additional

uninstall-additional: $(SDK830_INSTALLED_OPTPACKS_FILE) $(SDK830_INSTALLED_OPTPACKS_FILE).prev
	@$(call MESSAGE,"Uninstall optional packages")
	cat $^
#copy installedOptPacks because it can be changed while uninstalling unused packages
	cp -f $(SDK830_INSTALLED_OPTPACKS_FILE) $(SDK830_INSTALLED_OPTPACKS_FILE).copy
	cat $(SDK830_INSTALLED_OPTPACKS_FILE).prev | cut -d':' -f1 | \
	while read pack_name; do \
		echo "pack_name=$$pack_name"; \
		if ! grep $$pack_name $(SDK830_INSTALLED_OPTPACKS_FILE).copy >/dev/null; then \
			make $${pack_name}-uninstall O=$(O) FS_TYPE=$(FS_TYPE); \
		fi; \
	done
	rm -f $(SDK830_INSTALLED_OPTPACKS_FILE).copy
	mv -f $(SDK830_INSTALLED_OPTPACKS_FILE) $(SDK830_INSTALLED_OPTPACKS_FILE).prev

$(SDK830_INSTALLED_OPTPACKS_FILE) $(SDK830_INSTALLED_OPTPACKS_FILE).prev:
	touch $@

ELC_OVERLAY_VERBOSE:=1

# Macro: ELC_OVERLAY_TEMPLATE_INNER
# Creates rules for overlay package.
# $1 - package name
# $2 - package name in uppercase
define ELC_OVERLAY_TEMPLATE_INNER

$(eval $(call GENTARGETS, package/elecard, $(1)))

# Unpack the archive
$$($(2)_TARGET_EXTRACT):
	@$$(call MESSAGE,"Extracting")
	mkdir -p $$($(2)_DIR)/overlay
	tar -C $$($(2)_DIR)/overlay -xf $(DL_DIR)/$$($(2)_SOURCE)
	@touch $$@

# Install to target dir
$$($(2)_TARGET_INSTALL_TARGET):
	@$$(call MESSAGE,"Installing to target")
	source $(PRJROOT)/etc/overlay.sh; overlay $$($(2)_DIR)/overlay $(TARGET_DIR) 1 $(ELC_OVERLAY_VERBOSE)
	$(Q)touch $$@

# Install to staging dir
$$($(2)_TARGET_INSTALL_STAGING):
	@$$(call MESSAGE,"Installing to staging")
	source $(PRJROOT)/etc/overlay.sh; overlay $$($(2)_DIR)/overlay $(STAGING_DIR) 1 $(ELC_OVERLAY_VERBOSE)
	$(Q)touch $$@

# Uninstall package from target and staging
$$($(2)_TARGET_UNINSTALL):
	@$$(call MESSAGE,"Uninstalling")
	source $(PRJROOT)/etc/overlay.sh; \
	echo "Uninstall from rootfs"; \
	overlay $$($(2)_DIR)/overlay $(TARGET_DIR) 0 $(ELC_OVERLAY_VERBOSE); \
	echo "Uninstall from staging"; \
	overlay $$($(2)_DIR)/overlay $(STAGING_DIR) 0 $(ELC_OVERLAY_VERBOSE); \
	if grep -E "^CONFIG_UNTAR_ROOTFS_FOR_NFS" $(BUILDROOT)/.prjconfig >/dev/null; then \
		echo "Uninstall from rootfs_nfs"; \
		overlay $$($(2)_DIR)/overlay $(BUILDROOT)/rootfs_nfs 0 $(ELC_OVERLAY_VERBOSE); \
	fi
	rm -f $$($(2)_TARGET_INSTALL_TARGET)
	rm -f $$($(2)_TARGET_INSTALL_STAGING)

$(1)-install: $(1)-install-adjast-with-config
$(1)-uninstall: $(1)-uninstall-adjast-with-config

endef #define OVERLAY_TEMPLATE_INNER

# Macro: ELC_OVERLAY_TEMPLATE
# High level macro for creating rules for overlay package. Overlay package consist of files that shold be "copy to" or "remove from" rootfs.
# This enabled only for rootfs (not for initramfs).
# $1 - package name
define ELC_OVERLAY_TEMPLATE
$(eval $(call ELC_OVERLAY_TEMPLATE_INNER,$(1),$(call UPPERCASE,$(1))))
endef

endif #ifeq ($(_ELC_OVERLAY_TEMPLATE_MK_),)
endif #ifeq ($(FS_TYPE),rootfs)
