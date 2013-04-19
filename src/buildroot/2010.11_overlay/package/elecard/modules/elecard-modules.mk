#############################################################
#
# Elecard STB830 modules
#
#############################################################

ELECARD_MODULES_DEPENDENCIES = stapisdk

ifneq ($(BR2_PACKAGE_LINUXTV),)
ELECARD_MODULES_DEPENDENCIES += linuxtv
endif

elecard-modules-clean:
	make -C $(PRJROOT)/src/modules clean

elecard-modules: $(ELECARD_MODULES_DEPENDENCIES)
	make -C $(PRJROOT)/src/modules

ifeq ($(BR2_PACKAGE_ELECARD_MODULES),y)
TARGETS+=elecard-modules
endif
