#############################################################
#
# browser
#
#############################################################
BROWSER_NAME=browser
BROWSER_PACKAGES_DIR=$(PRJROOT)/src/update/source/browser/
BROWSER_DEPENDENCES=xworks libglib2_bin

BROWSER_INSTALL_DIR=$(patsubst %,$(BROWSER_PACKAGES_DIR)%,$(shell ls $(BROWSER_PACKAGES_DIR) ))
BROWSER_OVERLAY_FILE=$(patsubst $(BROWSER_PACKAGES_DIR)%,$(ROOTFS)/%,$(shell find $(BROWSER_PACKAGES_DIR)* -type f))
BROWSER_OVERLAY_DIR=$(patsubst $(BROWSER_PACKAGES_DIR)%,$(ROOTFS)/%,$(shell find $(BROWSER_PACKAGES_DIR)* -type d | sort))


$(BROWSER_NAME)-make:
	

$(BROWSER_NAME)-install: $(BROWSER_NAME)-make
	for i in $(BROWSER_INSTALL_DIR); do \
		echo "copy dir $$i";\
		cp -r -f $$i $(ROOTFS);\
	done

$(BROWSER_NAME): $(BROWSER_DEPENDENCES) $(BROWSER_NAME)-install

$(BROWSER_NAME)-uninstall:
	for i in $(BROWSER_OVERLAY_FILE); do \
		if [ -f $$i ]; then\
			echo "remove file $$i";\
			rm -f $$i;\
		fi;\
	done;\
	for i in $(BROWSER_OVERLAY_DIR); do \
		if [ -d $$i ]; then\
			rmdir $$i;\
		fi;\
	done;\

ifeq ($(BR2_PACKAGE_BROWSER),y)
TARGETS+=$(BROWSER_NAME)
endif
