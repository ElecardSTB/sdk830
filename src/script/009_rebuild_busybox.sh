#!/bin/bash

BUILDROOT_SRC_DIR=$BUILDROOT/packages/buildroot
ROOTFS_BUSYBOX_DIR=$BUILDROOT_SRC_DIR/output_rootfs/build/busybox-1.17.4
if [ -d "$ROOTFS_BUSYBOX_DIR" ]; then
	cp $BUILDROOT_SRC_DIR/package/busybox/busybox-1.17.x.config $ROOTFS_BUSYBOX_DIR/.config
	rm -f $ROOTFS_BUSYBOX_DIR/.stamp_built $ROOTFS_BUSYBOX_DIR/.stamp_target_installed
fi
