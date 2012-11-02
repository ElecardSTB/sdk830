#############################################################
#
# libglib2_bin
#
#############################################################
LIBGLIB2_BIN_NAME=libglib2_bin
LIBGLIB2_BIN_PACKAGES_DIR=$(PRJROOT)/src/update/source/libglib2_bin/

LIBGLIB2_BIN_INSTALL_DIR=$(patsubst %,$(LIBGLIB2_BIN_PACKAGES_DIR)%,$(shell ls $(LIBGLIB2_BIN_PACKAGES_DIR) ))
LIBGLIB2_BIN_OVERLAY_FILE=$(patsubst $(LIBGLIB2_BIN_PACKAGES_DIR)%,$(ROOTFS)/%,$(shell find $(LIBGLIB2_BIN_PACKAGES_DIR)* -type f))
LIBGLIB2_BIN_OVERLAY_DIR=$(patsubst $(LIBGLIB2_BIN_PACKAGES_DIR)%,$(ROOTFS)/%,$(shell find $(LIBGLIB2_BIN_PACKAGES_DIR)* -type d | sort -r))


$(LIBGLIB2_BIN_NAME)-make:
	

$(LIBGLIB2_BIN_NAME)-install: $(LIBGLIB2_BIN_NAME)-make
	for i in $(LIBGLIB2_BIN_INSTALL_DIR); do \
		echo "copy dir $$i";\
		cp -r -f $$i $(ROOTFS);\
	done

$(LIBGLIB2_BIN_NAME): $(LIBGLIB2_BIN_DEPENDENCES) $(LIBGLIB2_BIN_NAME)-install

$(LIBGLIB2_BIN_NAME)-uninstall:
	for i in $(LIBGLIB2_BIN_OVERLAY_FILE); do \
		if [ -f $$i ]; then\
			echo "remove file $$i";\
			rm -f $$i;\
		fi;\
	done;\
	for i in $(LIBGLIB2_BIN_OVERLAY_DIR); do \
		if [ -d $$i ]; then\
			rmdir --ignore-fail-on-non-empty $$i;\
		fi;\
	done;\

ifeq ($(BR2_PACKAGE_LIBGLIB2_BIN),y)
TARGETS+=$(LIBGLIB2_BIN_NAME)
endif
