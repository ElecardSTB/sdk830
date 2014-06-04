
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
	keys=$(BUILD_ADD_KEYS_TO_FW); \
	[ "$${BUILD_SKIP_ELECARD_KEY:-0}" == "0" ] && keys="$$keys elecard"; \
	for i in $$keys; do \
		found=0; \
		echo "Copying \"$$i\" sertificat (open key)"; \
		for dir in $(PRJROOT)/src $(PRJROOT)/src/elecard; do \
			if [ -d "$$dir" -a -e "$$dir/firmware/keys/open/$$i.pem" ]; then \
				cp -f $$dir/firmware/keys/open/$$i.pem $(TARGET_DIR)/config.firmware/keys/; \
				found=1; \
				break; \
			fi; \
		done; \
		if [ "$$found" -eq 0 ]; then \
			echo "Can't find \"$$i\" sertificat (open key)"; \
			false; \
		fi; \
	done
	@echo

endif #ifneq ($(FS_TYPE),)
