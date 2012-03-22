
include ../../etc/envvars.mk
include $(PRJROOT)/etc/util.mk
include $(PRJROOT)/etc/patch.mk


_ts_untarbuildroot := $(TIMESTAMPS_DIR)/.untarbuildroot
_ts_patchbuildroot := $(TIMESTAMPS_DIR)/.patchbuildroot
_ts_makebuildroot := $(TIMESTAMPS_DIR)/.makebuildroot


BUILDROOT_VERSION?=2010.11

BUILDROOT_ROOT := $(BUILDROOT)/packages/buildroot

.SECONDARY:
#.SECONDARY: $(_ts_makebuildroot)_% $(BUILDROOT_ROOT)/output_%/.config
#.SECONDARY: $(BUILDROOT_ROOT)/output_%/.config

#all: initramfs rootfs

all:
	echo " You should set one of the target: rootfs, initramfs"

rootfs: $(_ts_makebuildroot)_rootfs

initramfs: $(_ts_makebuildroot)_initramfs


%_rm_make_ts:
	rm -f $(_ts_makebuildroot)_$*

$(_ts_makebuildroot)_rootfs: force
#$(_ts_makebuildroot)_initramfs: force

$(_ts_makebuildroot)_%: $(_ts_patchbuildroot)_rootfs $(BUILDROOT_ROOT)/output_%/.config
	$(call ECHO_MESSAGE,Building $*)
	make -C $(BUILDROOT_ROOT) O=output_$* FS_TYPE=$* $(sub)
ifeq ($(sub),)
	touch $(_ts_makebuildroot)_$*
endif

$(eval $(call createPatchOverlayScriptTarget,$(_ts_patchbuildroot)_rootfs,$(BUILDROOT_VERSION),$(BUILDROOT_ROOT),buildroot,$(_ts_untarbuildroot)_rootfs))

BULDROOT_PACK_SITE=http://git.buildroot.net/buildroot/snapshot
BULDROOT_PACK_NAME=buildroot-$(BUILDROOT_VERSION).tar.gz

$(_ts_untarbuildroot)_rootfs:
	test -e $(TARBALLS_DIR)/$(BULDROOT_PACK_NAME) || wget --passive-ftp -nd -P $(TARBALLS_DIR) $(BULDROOT_PACK_SITE)/$(BULDROOT_PACK_NAME)
	$(call ECHO_MESSAGE,Unpackage buildroot)
	mkdir -p $(BUILDROOT)/packages
	tar -xzf $(TARBALLS_DIR)/$(BULDROOT_PACK_NAME) -C $(BUILDROOT)/packages
	ln -s buildroot-$(BUILDROOT_VERSION) $(BUILDROOT_ROOT)
	mkdir -p $(BUILDROOT_ROOT)/output_rootfs $(BUILDROOT_ROOT)/output_initramfs
	touch $(_ts_untarbuildroot)_rootfs


$(BUILDROOT_ROOT)/output_%/.config: ./buildroot-$(BUILDROOT_VERSION)_%.config
	$(call ECHO_MESSAGE,Configuring $*)
	$(call CONFEDIT_INIT,$(BUILDROOT_ROOT)/output_$*/,$(PRJROOT)/src/buildroot/buildroot-$(BUILDROOT_VERSION)_$*.config)
	$(call CONFEDIT_SET_STRING,$(BUILDROOT_ROOT)/output_$*,BR2_TOOLCHAIN_EXTERNAL_PATH,/opt/STM/STLinux-$(LINUX_VERSION)/devkit/sh4)
	$(call CONFEDIT_EXECUTE,$(BUILDROOT_ROOT)/output_$*)
	touch $@
	ls -la $@ $?


SDK_ENV_DEST:=$(BUILDROOT_VERSION)_overlay/package/elecard/sdk_env
update-sdk-env:
ifneq ($(SDK_ENV_SOURCE),)
	@if ! cmp $(SDK_ENV_SOURCE) $(SDK_ENV_DEST) >/dev/null; then \
		echo "Updating src/buildroot/$(SDK_ENV_DEST). Commit it please!"; \
		cp -f $(SDK_ENV_SOURCE) $(SDK_ENV_DEST); \
	fi
else
	@echo "Warning SDK_ENV_SOURCE not setted!"
endif

