#############################################################
#
# LinuxTV project
#
#############################################################

LINUXTV_DIR=$(BUILDROOT)/packages/media_build

LINUXTV_DEPENDENCIES =
LINUXTV_URL=/media/sda5/STM/work/linuxtv/media_build_elc.bare
LINUXTV_MAKE_OPTS=DIR=$(KDIR) ARCH=sh CROSS_COMPILE=sh4-linux- DESTDIR=$(TARGET_DIR)/ KDIR26=lib/modules/2.6.32.57_stm24_V5.0-hdk7105/linuxtv

linuxtv-clean:
#	make -C $(PRJROOT)/src/modules clean

linuxtv-dirclean:
	rm -rf $(LINUXTV_DIR)

$(LINUXTV_DIR)/.stamp_target_installed: $(LINUXTV_DIR)/.stamp_built
	make -C $(LINUXTV_DIR) $(LINUXTV_MAKE_OPTS) modules_install
	touch $@

$(LINUXTV_DIR)/.stamp_built: $(LINUXTV_DIR)/.stamp_untar FORCE
	make -C $(LINUXTV_DIR) $(LINUXTV_MAKE_OPTS)
	touch $@

$(LINUXTV_DIR)/.stamp_untar: $(LINUXTV_DIR)/linux/linux-media.tar.bz2
	make -C $(LINUXTV_DIR) untar
	touch $@

$(LINUXTV_DIR)/.stamp_downloaded: FORCE
	make -C $(LINUXTV_DIR) download
	touch $@

$(LINUXTV_DIR)/.stamp_updated: 
	cd $(LINUXTV_DIR) && git pull
	touch $@

$(LINUXTV_DIR)/.stamp_clened:
	git clone $(LINUXTV_URL) $(LINUXTV_DIR)
	touch $@

linuxtv-menuconfig:
	make -C $(LINUXTV_DIR) $(LINUXTV_MAKE_OPTS) menuconfig

linuxtv-install: linuxtv-build $(LINUXTV_DIR)/.stamp_target_installed

linuxtv-build: linuxtv-untar $(LINUXTV_DIR)/.stamp_built

linuxtv-untar: linuxtv-download $(LINUXTV_DIR)/.stamp_untar

linuxtv-download: linuxtv-update $(LINUXTV_DIR)/.stamp_downloaded

linuxtv-update: linuxtv-clone $(LINUXTV_DIR)/.stamp_updated

linuxtv-clone: $(LINUXTV_DIR)/.stamp_clened

linuxtv: $(LINUXTV_DEPENDENCIES) linuxtv-install

FORCE:
.PHONY: FORCE

ifeq ($(BR2_PACKAGE_LINUXTV),y)
TARGETS+=linuxtv
endif
