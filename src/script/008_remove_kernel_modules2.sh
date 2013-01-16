#!/bin/sh

LINUX_VERSION_PATH=${FULL_LINUX_VERSION}-hdk7105
#
rm -rf $BUILDROOT/rootfs/lib/modules/$LINUX_VERSION_PATH
if [ -e $BUILDROOT/rootfs_nfs/lib/modules/$LINUX_VERSION_PATH ]; then
	cd $BUILDROOT/rootfs_nfs/lib/modules/
	mv $LINUX_VERSION_PATH ${LINUX_VERSION_PATH}_`date +%y.%m.%d`
fi
#for rebuilding compat-wireless
rm $KDIR/.ts_configlinux