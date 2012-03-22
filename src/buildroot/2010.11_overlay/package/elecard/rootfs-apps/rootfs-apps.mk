#############################################################
#
# Rootfs applications
#
#############################################################

ROOTFS_APPS_DEPENDENCIES = stapisdk commonlib samba libcurl wireless_tools


rootfs-apps-clean:
	make -C $(PRJROOT)/src/apps rootfs-apps-clean

rootfs-apps: $(ROOTFS_APPS_DEPENDENCIES)
	make -C $(PRJROOT)/src/apps rootfs-apps

ifeq ($(BR2_PACKAGE_ROOTFS_APPS),y)
TARGETS+=rootfs-apps
endif
