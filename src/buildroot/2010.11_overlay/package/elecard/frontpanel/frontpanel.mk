#############################################################
#
# frontpanel
#
#############################################################

FRONTPANEL_DIR=$(PRJROOT)/src/apps/frontpanel

frontpanel-make:
	make BUILD_TARGET=sh4/ CROSS_COMPILE=sh4-linux- -C $(FRONTPANEL_DIR)

frontpanel-clean:
	make BUILD_TARGET=sh4/ -C $(FRONTPANEL_DIR) clean

frontpanel-install: frontpanel-make
	mkdir -p $(TARGET_DIR)/opt/elecard/bin
	install -m 755 -p $(FRONTPANEL_DIR)/sh4/frontpanel $(TARGET_DIR)/opt/elecard/bin 

frontpanel: $(FRONTPANEL_DEPENDENCES) frontpanel-install

ifeq ($(BR2_PACKAGE_FRONTPANEL),y)
TARGETS+=frontpanel
endif