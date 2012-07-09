#!/bin/sh

if [ -d $BUILDROOT/initramfs/lib -a -d $BUILDROOT/rootfs/lib ]; then
	cp -dfp $BUILDROOT/rootfs/lib/libnss_dns* $BUILDROOT/initramfs/lib/
	cp -dfp $BUILDROOT/rootfs/lib/libdl* $BUILDROOT/initramfs/lib/
	rm -f $BUILDROOT/timestamps/.makebuildroot_initramfs
fi
