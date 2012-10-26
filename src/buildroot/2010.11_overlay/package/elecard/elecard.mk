include package/elecard/*/*.mk
TARGETS:=update-curent-config $(TARGETS)
	
PACKAGES_CONFIG_FILE=$(PRJROOT)/build_stb830_24/packages/buildroot/output_rootfs/build/config
OPTIONAL_PACKAGES_FILE=$(PRJROOT)/src/buildroot/optional_packages.txt
#OPTIONAL_PACKAGES = $(shell cat $(OPTIONAL_PACKAGES_FILE))

OPTIONAL_PACKAGES:=$(patsubst %,%-install,$(shell cat $(OPTIONAL_PACKAGES_FILE)))

$(OPTIONAL_PACKAGES):%: %-write-file

%-write-file:
	if ! grep $(patsubst %-install,%,$*) $(PACKAGES_CONFIG_FILE) > /dev/null; then \
	  echo $(patsubst %-install,%,$*) >> $(PACKAGES_CONFIG_FILE); \
	fi;

update-curent-config:
	$(info $(PRJROOT))
	if [ -f "$(PACKAGES_CONFIG_FILE)" ]; then\
	  mv -f $(PACKAGES_CONFIG_FILE) $(PACKAGES_CONFIG_FILE).tmp;\
	fi;
	touch $(PACKAGES_CONFIG_FILE)
	

target-finalize: uninstall-additional

uninstall-additional:
	@$(call MESSAGE,"Uninstall optional packages");\
	cat $(PACKAGES_CONFIG_FILE).tmp | while read line; do \
	  PACKAGE_NAME=`echo $$line | cut -d':' -f1`; \
	  if ! grep $$PACKAGE_NAME $(PACKAGES_CONFIG_FILE) > /dev/null; then \
	    make $$PACKAGE_NAME-uninstall O=$(O) FS_TYPE=$(FS_TYPE); \
	  fi; \
	done ;\

	
	
