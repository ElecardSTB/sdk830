

include etc/envvars.mk
include $(BUILDROOT)/.prjconfig


DIRS := $(FIRMWARE_DIR) $(TIMESTAMPS_DIR) $(COMPONENT_DIR) $(BUILDROOT)/initramfs $(BUILDROOT)/rootfs
_ts_commonscript := $(TIMESTAMPS_DIR)/.commonscript


.PHONY : all firmware maketools make_description make_components untar_rootfs clean br buildroot rootfs br_i buildroot_i initramfs linux kernel stapisdk stsdk

all: $(DIRS) $(_ts_commonscript) make_description make_components untar_rootfs
firmware: $(DIRS) $(_ts_commonscript) make_description make_components make_firmware untar_rootfs


maketools:
	make -C $(PRJROOT)/etc/tools


COMMON_SCRIPT_FILES=$(sort $(wildcard ./src/script/*.sh))
$(_ts_commonscript): $(COMMON_SCRIPT_FILES)
	$(call ECHO_MESSAGE,Common scripts)
	@echo "Scripts:"
	@for i in $?; do \
		is_script=`echo $$i | grep "script/.*.sh"`; \
		if [ -n "$$is_script" ]; then \
			echo -e "\n ***Execute $$i\n"; eval $$is_script; \
		fi; \
	done
	touch $(_ts_commonscript)

make_description: $(DIRS)
	$(call ECHO_MESSAGE,Generate firmware description:)
	$(PRJROOT)/bin/genFirmwarePackConf.sh

define CHECK_COMP_SIZE
	@filesize=$$(stat -L -c%s $(1)); \
	if [ $$filesize -gt $(3) ]; then \
		echo "ERROR!!! $(1) $$filesize is greater than $(3) (partition size for 256MB NAND)"; \
	else \
		if [ $$filesize -gt $(2) ]; then \
			echo "WARNING!!! $(1) $$filesize is greater than $(2) (partition size for 128MB NAND)"; \
		fi; \
	fi;
endef

firmwarePackGenerator=$(BUILDROOT)/packages/buildroot/output_rootfs/host/usr/bin/firmwarePackGenerator
make_firmware:
	$(call ECHO_MESSAGE,Creating firmware pack:)
	$(firmwarePackGenerator) $(COMPONENT_DIR)/stb830_efp.conf
	@echo "Creating symlink on latest firmware."
	@fw_name=`grep "OutputFile = " $(COMPONENT_DIR)/stb830_efp.conf | sed s%.*/%%`; \
		rm -f $(BUILDROOT)/firmware/STB830_last.efp; \
		ln -s $${fw_name%?} $(BUILDROOT)/firmware/STB830_last.efp
	$(call CHECK_COMP_SIZE,$(COMPONENT_DIR)/kernel1,10485760,15728640)
	$(call CHECK_COMP_SIZE,$(COMPONENT_DIR)/rootfs1,77594624,134217728)

make_components: $(DIRS)
ifneq "$(BUILD_WITHOUT_COMPONENTS_FW)" "1"
	make -C src/linux
	make -C src/rootfs
endif
ifneq ($(BUILD_SCRIPT_FW),)
	$(call ECHO_MESSAGE,Creating script component:)
	rm -f $(COMPONENT_DIR)/script.tgz
	cd $(PRJROOT)/src/update/scripts/$(BUILD_SCRIPT_FW) && tar -czf $(COMPONENT_DIR)/script.tgz ./*
endif

$(TIMESTAMPS_DIR) $(COMPONENT_DIR) $(FIRMWARE_DIR) $(PACKAGES_DIR) $(TARBALLS_DIR):
	mkdir -p $@

#	cd $(BUILDROOT) && rm -f images_initramfs initramfs images rootfs
$(BUILDROOT)/initramfs:
	test -h $@ || ln -s packages/buildroot/output_initramfs/target $@

$(BUILDROOT)/rootfs:
	test -h $@ || ln -s packages/buildroot/output_rootfs/target $@


user=$(shell whoami)
group=$(shell id -g)
UNTAR_ROOTFS_NFS 	 = \
	mkdir -p $(BUILDROOT)/rootfs_nfs; \
	sudo tar -xf $(BUILDROOT)/packages/buildroot/output_rootfs/images/rootfs.tar -C $(BUILDROOT)/rootfs_nfs; \
	sudo chown -R $(user):$(group) $(BUILDROOT)/rootfs_nfs

untar_rootfs:
ifneq "$(BUILD_WITHOUT_COMPONENTS_FW)" "1"
	$(call ECHO_MESSAGE,Untar rootfs for nfs share:)
	$(if $(CONFIG_UNTAR_ROOTFS_FOR_NFS),$(call UNTAR_ROOTFS_NFS),)
endif


clean:
	echo "clean"


br buildroot rootfs:
	make -C ./src/rootfs

bri br_i buildroot_i initramfs:
	make -C ./src/buildroot initramfs_rm_make_ts
	make -C ./src/initramfs

linux kernel:
	make -C ./src/linux kernel_only


ifeq ($(STB830_SDK),)
packs: $(PACKAGES_DIR)
	$(PRJROOT)/src/elecard/bin/genPackages.sh

stapisdk stsdk:
	make -C ./src/elecard/stapisdk stapisdk
else
stapisdk stsdk packs:
	@echo "You should run it in FULL build (not SDK)!"
endif

