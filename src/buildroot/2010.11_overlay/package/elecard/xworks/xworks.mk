#############################################################
#
# xworks
#
#############################################################


XWORKS_NAME=xworks
XWORKS_PACKAGES_DIR=$(PRJROOT)/src/update/source/xworks/

XWORKS_INSTALL_DIR=$(patsubst %,$(XWORKS_PACKAGES_DIR)%,$(shell ls $(XWORKS_PACKAGES_DIR) ))
XWORKS_OVERLAY_FILE=$(patsubst $(XWORKS_PACKAGES_DIR)%,$(ROOTFS)/%,$(shell find $(XWORKS_PACKAGES_DIR)* -type f))
XWORKS_OVERLAY_DIR=$(patsubst $(XWORKS_PACKAGES_DIR)%,$(ROOTFS)/%,$(shell find $(XWORKS_PACKAGES_DIR)* -type d | sort))

$(XWORKS_NAME)-make:

$(XWORKS_NAME)-install: $(XWORKS_NAME)-make
		for i in $(XWORKS_INSTALL_DIR); do \
			echo "copy dir $$i in $(ROOTFS)";\
			cp -r -f $$i $(ROOTFS);\
		done

$(XWORKS_NAME): $(XWORKS_DEPENDENCES) $(XWORKS_NAME)-install

$(XWORKS_NAME)-uninstall:
	for i in $(XWORKS_OVERLAY_FILE); do \
		if [ -f $$i ]; then\
			echo "remove file $$i";\
			rm -f $$i;\
		fi;\
	done;\
	for i in $(XWORKS_OVERLAY_DIR); do \
		if [ -d $$i ]; then\
			rmdir $$i;\
		fi;\
	done

ifeq ($(BR2_PACKAGE_XWORKS),y)
TARGETS+=$(XWORKS_NAME)
endif

