#############################################################
#
# Elecard STB830 modules
#
#############################################################

ELECARD_MODULES_DEPENDENCIES = stapisdk

elecard-modules-clean:
	USE_LINUXTV=$(BR2_PACKAGE_LINUXTV) make -C $(PRJROOT)/src/modules clean

elecard-modules: $(ELECARD_MODULES_DEPENDENCIES)
	USE_LINUXTV=$(BR2_PACKAGE_LINUXTV) make -C $(PRJROOT)/src/modules

ifeq ($(BR2_PACKAGE_ELECARD_MODULES),y)
TARGETS+=elecard-modules
endif
