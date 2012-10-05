#!/bin/sh

if [ -d $BUILDROOT/initramfs/lib -a -d $BUILDROOT/rootfs/lib ]; then
	cp -dfp $BUILDROOT/rootfs/lib/libgcc_s* $BUILDROOT/initramfs/lib/
	rm -f $BUILDROOT/timestamps/.makebuildroot_initramfs
fi
