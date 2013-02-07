#############################################################
#
# Elecard STB830 modules
#
#############################################################

ELECARD_MODULES_DEPENDENCIES = stapisdk

elecard-modules-clean:
	make -C $(PRJROOT)/src/modules clean

elecard-modules: $(ELECARD_MODULES_DEPENDENCIES)
	make -C $(PRJROOT)/src/modules

ifeq ($(BR2_PACKAGE_ELECARD_MODULES),y)
TARGETS+=elecard-modules
endif
