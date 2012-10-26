#############################################################
#
# xworks
#
#############################################################


PROGRAMS_NAME=xworks
PROGRAMS_PACKAGES_DIR =$(PRJROOT)/src/update/source/xworks/

PROGRAM_INSTALL_DIR=$(patsubst %,$(PROGRAMS_PACKAGES_DIR)%,$(shell ls $(PROGRAMS_PACKAGES_DIR) ))
PROGRAM_OVERLAY_FILE=$(patsubst $(PROGRAMS_PACKAGES_DIR)%,$(ROOTFS)/%,$(shell find $(PROGRAMS_PACKAGES_DIR)* -type f))
PROGRAM_OVERLAY_DIR=$(patsubst $(PROGRAMS_PACKAGES_DIR)%,$(ROOTFS)/%,$(shell find $(PROGRAMS_PACKAGES_DIR)* -type d | sort))

$(PROGRAMS_NAME)-make:

$(PROGRAMS_NAME)-install: $(PROGRAMS_NAME)-make
		for i in $(PROGRAM_INSTALL_DIR); do \
			echo "copy dir $$i in $(ROOTFS)";\
			cp -r -f $$i $(ROOTFS);\
		done

$(PROGRAMS_NAME): $(PROGRAMS_DEPENDENCES) $(PROGRAMS_NAME)-install

$(PROGRAMS_NAME)-uninstall:
	for i in $(PROGRAM_OVERLAY_FILE); do \
		if [ -f $$i ]; then\
			echo "remove file $$i";\
			rm -f $$i;\
		fi;\
	done;\
	for i in $(PROGRAM_OVERLAY_DIR); do \
		if [ -d $$i ]; then\
			rmdir $$i;\
		fi;\
	done

ifeq ($(BR2_PACKAGE_XWORKS),y)
TARGETS+=$(PROGRAMS_NAME)
endif

