
ifneq ($(FS_TYPE),)

target-finalize: fs-overlays

fs-overlays:
	@$(call MESSAGE,"Overlays for $(FS_TYPE)");
	prjfilter $(PRJROOT)/src/$(FS_TYPE)/overlay $(TARGET_DIR) -c $(BUILDROOT)/.prjconfig -c $(BASE_DIR)/.config
ifeq ($(FS_TYPE),rootfs)
#rootfs specific overlays
	cp -f $(BUILDROOT)/comps/fwinfo/firmwareDesc $(TARGET_DIR)
	cp $(PRJROOT)/src/$(FS_TYPE)/dev/dev-stapi-$(STAPISDK_VERSION).tar $(TARGET_DIR)/etc/dev-stapi.tar
endif
#Add open keys. clientUpdater work from initramfs and rootfs (check only mode), so copy keys there.
	rm -rf $(TARGET_DIR)/config.firmware/keys
	mkdir -p $(TARGET_DIR)/config.firmware/keys
	for i in elecard $(BUILD_ADD_KEYS_TO_FW); do \
		cp -f $(PRJROOT)/src/firmware/keys/open/$$i.pem $(TARGET_DIR)/config.firmware/keys/; \
	done
	@echo

endif #ifneq ($(FS_TYPE),)
