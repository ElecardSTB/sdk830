#!/bin/sh

source $(dirname $0)/default_env.sh

UPD_CONFIG=dev
#ENABLE_VIDIMAX=1

BUILD_SCRIPT_FW=eng
SHORT_COMMENT=${SHORT_COMMENT:-eng}

mkdir -p $PRJROOT/src/rootfs/overlay/etc/defaults/elecard/StbMainApp 2>/dev/null
cat << EOF > $PRJROOT/src/rootfs/overlay/etc/defaults/elecard/StbMainApp/settings.conf
LANGUAGE=English
EOF

make -C $PRJROOT firmware

rm -f $PRJROOT/src/rootfs/overlay/etc/defaults/elecard/StbMainApp/settings.conf
rmdir $PRJROOT/src/rootfs/overlay/etc/defaults/elecard/StbMainApp 2>/dev/null
(cd $PRJROOT && git checkout $PRJROOT/src/rootfs/overlay/etc/defaults/elecard/StbMainApp/settings.conf 2>/dev/null)
