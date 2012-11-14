include package/elecard/*/*.mk

ifeq ($(FS_TYPE),rootfs)

SDK830_INSTALLED_OPTPACKS_FILE:=$(BUILD_DIR)/installedOptPacks
SDK830_OPTPACKS_LIST_FILE:=$(PRJROOT)/src/buildroot/optional_packages.txt
SDK830_OPTPACKS_LIST:=$(shell cat $(SDK830_OPTPACKS_LIST_FILE))


SDK830_OPTPACKS_INSTALL:=$(patsubst %,%-install,$(SDK830_OPTPACKS_LIST))
SDK830_OPTPACKS_UNINSTALL:=$(patsubst %,%-uninstall,$(SDK830_OPTPACKS_LIST))

TARGETS:=update-curent-config $(TARGETS)
update-curent-config:
	if [ -f "$(SDK830_INSTALLED_OPTPACKS_FILE)" ]; then\
		mv -f $(SDK830_INSTALLED_OPTPACKS_FILE) $(SDK830_INSTALLED_OPTPACKS_FILE).prev;\
	fi;
	touch $(SDK830_INSTALLED_OPTPACKS_FILE)

$(SDK830_OPTPACKS_INSTALL) $(SDK830_OPTPACKS_UNINSTALL):%: %-adjast-with-config

%-install-adjast-with-config:
	if ! grep "$*" $(SDK830_INSTALLED_OPTPACKS_FILE) >/dev/null; then \
		echo "$*" >> $(SDK830_INSTALLED_OPTPACKS_FILE); \
	fi;

%-uninstall-adjast-with-config:
	if grep "$*" $(SDK830_INSTALLED_OPTPACKS_FILE) >/dev/null; then \
		sed -i -e '/$*/d' $(SDK830_INSTALLED_OPTPACKS_FILE);\
	fi;

target-finalize: uninstall-additional

uninstall-additional:
	@$(call MESSAGE,"Uninstall optional packages")
	cat $(SDK830_INSTALLED_OPTPACKS_FILE).prev
	cat $(SDK830_INSTALLED_OPTPACKS_FILE)
	cat $(SDK830_INSTALLED_OPTPACKS_FILE).prev | cut -d':' -f1 | \
	while read pack_name; do \
		if ! grep $$pack_name $(SDK830_INSTALLED_OPTPACKS_FILE) >/dev/null; then \
			make $$pack_name-uninstall O=$(O) FS_TYPE=$(FS_TYPE); \
		fi; \
	done

endif #ifeq ($(FS_TYPE),rootfs)

#LIBFOO_UNINSTALL_TARGET_OPT, contains the make options used to uninstall the package from the target directory. By default, 
#the value is DESTDIR=$$(TARGET_DIR) uninstall. 
