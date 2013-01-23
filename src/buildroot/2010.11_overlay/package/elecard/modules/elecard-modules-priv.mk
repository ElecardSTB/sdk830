#############################################################
#
# Elecards private modules.
#
#############################################################

ELECARD_MODULES_PRIV_DEPENDENCIES=
ifeq ($(STB830_SDK),)

elecard-modules-priv-install:
	make -C $(PRJROOT)/src/elecard/modules all

elecard-modules-priv-dirclean elecard-modules-priv-clean:
	make -C $(PRJROOT)/src/elecard/modules clean

elecard-modules-priv: $(ELECARD_MODULES_PRIV_DEPENDENCIES) elecard-modules-priv-install

ifeq ($(BR2_PACKAGE_ELECARD_MODULES_PRIV),y)
TARGETS+=elecard-modules-priv
endif
else #ifeq ($(STB830_SDK),)

include package/elecard/sdk_env
ELECARD_MODULES_PRIV_VERSION:=$(ELECARD_MODULES_PRIV_PACK_VERSION)
ELECARD_MODULES_PRIV_SOURCE:=elecard-modules-priv-$(ELECARD_MODULES_PRIV_PACK_VERSION).tar.gz
ELECARD_MODULES_PRIV_SITE:=$(ELECARD_UPLOAD_SERVER)

define ELECARD_MODULES_PRIV_INSTALL_TARGET_CMDS
	TARGET_DIR=$(TARGET_DIR) make -C $(ELECARD_MODULES_PRIV_DIR) -f Makefile.install
endef

$(eval $(call GENTARGETS, package/elecard, elecard-modules-priv))

# Unpack the archive. Overvrite default target, becase it uses --strip-components=1 tar option.
$(ELECARD_MODULES_PRIV_TARGET_EXTRACT):
	@$(call MESSAGE,"Extracting")
	mkdir -p $(ELECARD_MODULES_PRIV_DIR)
	tar -C $(ELECARD_MODULES_PRIV_DIR) -xf $(DL_DIR)/$(ELECARD_MODULES_PRIV_SOURCE)
	@touch $@

# Reinstall elecard-modules-priv when kernel config is updated. Because /lib/modules/`uname -r` removes when kernel config is updated.
$(ELECARD_MODULES_PRIV_TARGET_INSTALL_TARGET): $(KDIR)/.config
endif #ifeq ($(STB830_SDK),)
