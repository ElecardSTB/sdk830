#############################################################
#
# Elecards private modules.
#
#############################################################

MODULES_ELECARD_DEPENDENCIES=
ifeq ($(STB830_SDK),)

modules-elecard-install:
	make -C $(PRJROOT)/src/elecard/modules all

modules-elecard-dirclean modules-elecard-clean:
	make -C $(PRJROOT)/src/elecard/modules clean

modules-elecard: $(MODULES_ELECARD_DEPENDENCIES) modules-elecard-install

ifeq ($(BR2_PACKAGE_MODULES_ELECARD),y)
TARGETS+=modules-elecard
endif
else #ifeq ($(STB830_SDK),)

include package/elecard/sdk_env
MODULES_ELECARD_VERSION:=$(MODULES_ELECARD_PACK_VERSION)
MODULES_ELECARD_SOURCE:=modules-elecard-$(MODULES_ELECARD_PACK_VERSION).tar.gz
MODULES_ELECARD_SITE:=$(ELECARD_UPLOAD_SERVER)

define MODULES_ELECARD_INSTALL_TARGET_CMDS
	TARGET_DIR=$(TARGET_DIR) make -C $(MODULES_ELECARD_DIR) -f Makefile.install
endef

$(eval $(call GENTARGETS, package/elecard, modules-elecard))

# Unpack the archive. Overvrite default target, becase it uses --strip-components=1 tar option.
$(MODULES_ELECARD_TARGET_EXTRACT):
	@$(call MESSAGE,"Extracting")
	mkdir -p $(MODULES_ELECARD_DIR)
	tar -C $(MODULES_ELECARD_DIR) -xf $(DL_DIR)/$(MODULES_ELECARD_SOURCE)
	@touch $@

# Reinstall modules-elecard when kernel config is updated. Because /lib/modules/`uname -r` removes when kernel config is updated.
$(MODULES_ELECARD_TARGET_INSTALL_TARGET): $(KDIR)/.config
endif #ifeq ($(STB830_SDK),)
