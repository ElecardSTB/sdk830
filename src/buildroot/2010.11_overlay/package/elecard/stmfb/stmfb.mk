#############################################################
#
# stmfb
#
#############################################################

STMFB_PATH=/opt/STM/STLinux-2.4/devkit/sources/stmfb/stmfb
STMFB_FIRMWARE_PATH=/opt/STM/STLinux-2.4/devkit/sh4/target/lib/firmware

stmfb-clean:
	make -C $(STMFB_PATH) KERNELDIR=$(KDIR) ARCH=sh CROSS_COMPILE=sh4-linux- clean

stmfb:
	make -C $(STMFB_PATH) KERNELDIR=$(KDIR) ARCH=sh CROSS_COMPILE=sh4-linux-

stmfb-install:
	$(INSTALL) -D -m 0644 $(STMFB_FIRMWARE_PATH)/fdvo0_7105.fw     $(TARGET_DIR)/lib/firmware/fdvo0.fw
	$(INSTALL) -D -m 0644 $(STMFB_FIRMWARE_PATH)/component_7105.fw $(TARGET_DIR)/lib/firmware/component.fw
	$(INSTALL) -D -m 0644 $(STMFB_PATH)/linux/kernel/drivers/stm/coredisplay/sti7105_7106/stmcore-display-sti7105.ko \
	                   $(TARGET_DIR)/lib/modules/STLinux-2.4/stmcore-display-sti7105.ko
	$(INSTALL) -D -m 0644 $(STMFB_PATH)/linux/kernel/drivers/video/stmfb.ko \
	                   $(TARGET_DIR)/lib/modules/STLinux-2.4/stmfb.ko


$(PRJROOT)/src/apps/fb_logo/fb_logo: $(wildcard $(PRJROOT)/src/apps/fb_logo/*.c)
	make -C $(PRJROOT)/src/apps/fb_logo CROSS_COMPILE=sh4-linux-

fb_logo: $(PRJROOT)/src/apps/fb_logo/fb_logo

fb_logo-clean:
	make -C $(PRJROOT)/src/apps/fb_logo CROSS_COMPILE=sh4-linux- clean

fb_logo-install: $(PRJROOT)/src/apps/fb_logo/fb_logo
	$(INSTALL) -D -m 0755 $(PRJROOT)/src/apps/fb_logo/fb_logo $(TARGET_DIR)/opt/elecard/bin/


ifeq ($(BR2_PACKAGE_STMFB),y)
TARGETS+=stmfb stmfb-install
endif

ifeq ($(BR2_PACKAGE_STMFB_LOGO),y)
TARGETS+=fb_logo fb_logo-install
endif

#trick, set dependence to kernel config
$(STMFB_TARGET_BUILD): $(KDIR)/.config
