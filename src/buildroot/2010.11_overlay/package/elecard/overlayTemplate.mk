
ifeq ($(FS_TYPE),rootfs)
ifeq ($(_ELC_OVERLAY_TEMPLATE_MK_),)
_ELC_OVERLAY_TEMPLATE_MK_:=1

include package/elecard/sdk_env

SDK830_INSTALLED_OPTPACKS_FILE := $(BUILD_DIR)/installedOptPacks

target-finalize: uninstall-optional-packs

ifeq ($(wildcard $(SDK830_INSTALLED_OPTPACKS_FILE).forbid),)
initialize-opt-packs-cfg: $(SDK830_INSTALLED_OPTPACKS_FILE).prev
	@echo "" >$(SDK830_INSTALLED_OPTPACKS_FILE)

%-install-adjast-with-opt-packs-cfg: initialize-opt-packs-cfg
	@if ! grep "$*" $(SDK830_INSTALLED_OPTPACKS_FILE) >/dev/null; then \
		sed -i "1 i $*" $(SDK830_INSTALLED_OPTPACKS_FILE); \
	fi
	@if ! grep "$*" $(SDK830_INSTALLED_OPTPACKS_FILE).prev >/dev/null; then \
		sed -i "1 i $*" $(SDK830_INSTALLED_OPTPACKS_FILE).prev; \
	fi
else
%-install-adjast-with-opt-packs-cfg:
	@true
endif

uninstall-optional-packs: initialize-opt-packs-cfg
	@$(call MESSAGE,"Uninstall optional packages")
	cat $(SDK830_INSTALLED_OPTPACKS_FILE)
	cat $(SDK830_INSTALLED_OPTPACKS_FILE).prev
	touch $(SDK830_INSTALLED_OPTPACKS_FILE).forbid
	cat $(SDK830_INSTALLED_OPTPACKS_FILE).prev | cut -d':' -f1 | \
	while read pack_name; do \
		[ -z "$$pack_name" ] && continue; \
		echo "pack_name=$$pack_name"; \
		if ! grep $$pack_name $(SDK830_INSTALLED_OPTPACKS_FILE) >/dev/null; then \
			make $${pack_name}-uninstall O=$(O) FS_TYPE=$(FS_TYPE); \
		fi; \
	done
	rm $(SDK830_INSTALLED_OPTPACKS_FILE).forbid
	mv -f $(SDK830_INSTALLED_OPTPACKS_FILE) $(SDK830_INSTALLED_OPTPACKS_FILE).prev

$(SDK830_INSTALLED_OPTPACKS_FILE).prev:
	echo "" >>$@


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
	$(Q)source $(PRJROOT)/etc/overlay.sh; overlay $$($(2)_DIR)/overlay $(TARGET_DIR) 1 $(ELC_OVERLAY_VERBOSE)
	$(Q)touch $$@

# Install to staging dir
$$($(2)_TARGET_INSTALL_STAGING):
	@$$(call MESSAGE,"Installing to staging")
	$(Q)source $(PRJROOT)/etc/overlay.sh; overlay $$($(2)_DIR)/overlay $(STAGING_DIR) 1 $(ELC_OVERLAY_VERBOSE)
	$(Q)touch $$@

# Uninstall package from target and staging
$$($(2)_TARGET_UNINSTALL):
	@$$(call MESSAGE,"Uninstalling")
	$(Q)source $(PRJROOT)/etc/overlay.sh; \
	echo "Uninstall from rootfs"; \
	overlay $$($(2)_DIR)/overlay $(TARGET_DIR) 0 $(ELC_OVERLAY_VERBOSE); \
	echo "Uninstall from staging"; \
	overlay $$($(2)_DIR)/overlay $(STAGING_DIR) 0 $(ELC_OVERLAY_VERBOSE); \
	if grep -E "^CONFIG_UNTAR_ROOTFS_FOR_NFS" $(BUILDROOT)/.prjconfig >/dev/null; then \
		echo "Uninstall from rootfs_nfs"; \
		overlay $$($(2)_DIR)/overlay $(BUILDROOT)/rootfs_nfs 0 $(ELC_OVERLAY_VERBOSE); \
	fi
	$(Q)rm -f $$($(2)_TARGET_INSTALL_TARGET)
	$(Q)rm -f $$($(2)_TARGET_INSTALL_STAGING)

$(1)-install: $(1)-install-adjast-with-opt-packs-cfg
#$(1)-uninstall: $(1)-uninstall-adjast-with-opt-packs-cfg

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
