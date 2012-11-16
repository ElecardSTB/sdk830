
ifeq ($(_ELC_OVERLAY_TEMPLATE_MK_),)
_ELC_OVERLAY_TEMPLATE_MK_:=1

include package/elecard/sdk_env

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
	@$$(call MESSAGE,"Installing to target")
	source $(PRJROOT)/etc/overlay.sh; overlay $$($(2)_DIR)/overlay $(STAGING_DIR) 1 $(ELC_OVERLAY_VERBOSE)
	$(Q)touch $$@

# Uninstall package from target and staging
$$($(2)_TARGET_UNINSTALL):
	@$$(call MESSAGE,"Uninstalling")
	source $(PRJROOT)/etc/overlay.sh; \
	overlay $$($(2)_DIR)/overlay $(TARGET_DIR) 0 $(ELC_OVERLAY_VERBOSE); \
	overlay $$($(2)_DIR)/overlay $(STAGING_DIR) 0 $(ELC_OVERLAY_VERBOSE)
	rm -f $$($(2)_TARGET_INSTALL_TARGET)
	rm -f $$($(2)_TARGET_INSTALL_STAGING)

endef #define OVERLAY_TEMPLATE_INNER

ifeq ($(FS_TYPE),rootfs)
# Macro: ELC_OVERLAY_TEMPLATE
# High level macro for creating rules for overlay package. Overlay package consist of files that shold be "copy to" or "remove from" rootfs.
# This enabled only for rootfs (not for initramfs).
# $1 - package name
define ELC_OVERLAY_TEMPLATE
$(eval $(call ELC_OVERLAY_TEMPLATE_INNER,$(1),$(call UPPERCASE,$(1))))
endef
endif #ifeq ($(FS_TYPE),rootfs)

endif #ifeq ($(_ELC_OVERLAY_TEMPLATE_MK_),)
