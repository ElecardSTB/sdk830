#!/bin/bash

source $(dirname $0)/../etc/checkEnvs.sh

USR_LIB_SO_LIBS=" \
			libbmp.so* \
			libdirect-*.so* \
			libdirectfb-*.so* \
			libfreetype.so* \
			libfusion-*.so* \
			libgif.so* \
			libjpeg.so* \
			libpng.so* \
			libshm.so* \
			libst2fx.so* \
			libtiff.so* \
			libz.so* \
			libQt*.so*"

#TODO: Is need to remove usr/lib/directfb-1.4* directory??

echo "$USR_LIB_SO_LIBS"
echo "Cleaning staging staging $STAGINGDIR"
pushd $STAGINGDIR/usr/lib && rm -f $USR_LIB_SO_LIBS && popd

echo "Cleaning staging rootfs $ROOTFS"
pushd $ROOTFS/usr/lib && rm -f $USR_LIB_SO_LIBS && popd

echo "Cleaning staging rootfs_nfs ${ROOTFS}_nfs"
pushd ${ROOTFS}_nfs/usr/lib && rm -f $USR_LIB_SO_LIBS && popd

