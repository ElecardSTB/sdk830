#############################################################
#
# LinuxTV project
#
#############################################################

#LINUXTV_DIR=$(BUILDROOT)/packages/media_build
LINUXTV_DIR=$(BUILD_DIR)/media_build

LINUXTV_DEPENDENCIES =
LINUXTV_URL=http://smithy.elecard.net.ru/misc_repos/media_build_elc.bare
LINUXTV_MAKE_OPTS=DIR=$(KDIR) SRCDIR=$(KDIR) ARCH=sh CROSS_COMPILE=sh4-linux- DESTDIR=$(TARGET_DIR)/ KDIR26=lib/modules/2.6.32.57_stm24_V5.0-hdk7105/linuxtv

LINUXTV_MESSAGE = @echo "$(TERM_BOLD)>>> LinuxTV: $(1)$(TERM_RESET)"

linuxtv-clean:
#	make -C $(PRJROOT)/src/modules clean

linuxtv-dirclean:
	rm -rf $(LINUXTV_DIR)

$(LINUXTV_DIR)/.stamp_target_installed: $(LINUXTV_DIR)/.stamp_built
	$(call LINUXTV_MESSAGE,install)
	make -C $(LINUXTV_DIR) $(LINUXTV_MAKE_OPTS) modules_install
	touch $@

$(LINUXTV_DIR)/.stamp_built: $(LINUXTV_DIR)/.stamp_unpacked FORCE
	$(call LINUXTV_MESSAGE,build)
	make -C $(LINUXTV_DIR) $(LINUXTV_MAKE_OPTS)
	touch $@

$(LINUXTV_DIR)/.stamp_unpacked: $(LINUXTV_DIR)/linux/linux-media.tar.bz2
	$(call LINUXTV_MESSAGE,unpack linux media drivers)
	make -C $(LINUXTV_DIR) untar
	touch $@

$(LINUXTV_DIR)/.stamp_downloaded: FORCE
	$(call LINUXTV_MESSAGE,download latest linux media drivers)
	make -C $(LINUXTV_DIR) download
	touch $@

$(LINUXTV_DIR)/.stamp_updated: FORCE
	$(call LINUXTV_MESSAGE,update media_build)
	cd $(LINUXTV_DIR) && git pull
	touch $@

$(LINUXTV_DIR)/.stamp_cloned:
	$(call LINUXTV_MESSAGE,clone media_build)
	git clone -b SDK830 $(LINUXTV_URL) $(LINUXTV_DIR)
	touch $@

linuxtv-menuconfig:
	make -C $(LINUXTV_DIR) $(LINUXTV_MAKE_OPTS) menuconfig

linuxtv-install: linuxtv-build $(LINUXTV_DIR)/.stamp_target_installed

linuxtv-build: linuxtv-unpack $(LINUXTV_DIR)/.stamp_built

linuxtv-unpack: linuxtv-download $(LINUXTV_DIR)/.stamp_unpacked

linuxtv-download: linuxtv-update $(LINUXTV_DIR)/.stamp_downloaded

linuxtv-update: linuxtv-clone $(LINUXTV_DIR)/.stamp_updated

linuxtv-clone: $(LINUXTV_DIR)/.stamp_cloned

linuxtv: $(LINUXTV_DEPENDENCIES) linuxtv-install

FORCE:
.PHONY: FORCE

ifeq ($(BR2_PACKAGE_LINUXTV),y)
TARGETS+=linuxtv
endif
