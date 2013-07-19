#!/bin/sh


BOARD=stb830
#BOARD=`stbstm -m 2>/dev/null`
#if [ -z "$BOARD" ]; then BOARD="stb830"; fi

ADD_FILES=
LOGS_ADD_FILES=
INITRAMFS=0
LOGS_DIR=/var/log

if [ "$BOARD" = "stb820" ]; then
	ROOTFS_MTD=/dev/mtdblock`grep '"Root"' /proc/mtd | cut -b4`
	if ! grep "$ROOTFS_MTD" /proc/mounts >/dev/null; then #detecting rootfs/initramfs
		INITRAMFS=1
	fi
	if [ $INITRAMFS -eq 0 ]; then
		CFG_MOUNT_POUNT=/config
		USB_MOUNT_POINT=/usb
	else
		CFG_MOUNT_POUNT=/configfs
		USB_MOUNT_POINT=/mnt
	fi
	LOGS_ADD_FILES="$CFG_MOUNT_POUNT/debug/update_*.log"
	STBMAINAPP_CFGDIR=$CFG_MOUNT_POUNT/StbMainApp

elif [ "$BOARD" = "stb830" ]; then
	CFG_MOUNT_POUNT=/var/etc
	LOGS_ADD_FILES="$LOGS_DIR/elcd.log /tmp/updaterDaemon.log $CFG_MOUNT_POUNT/updater_last.log"
	ADD_FILES="/firmwareDesc $CFG_MOUNT_POUNT/interfaces"
	STBMAINAPP_CFGDIR=$CFG_MOUNT_POUNT/elecard/StbMainApp
	USB_MOUNT_POINT=/mnt
else
	echo "Unknown board"
	exit 1
fi

name="$BOARD-`date +%Y%m%d%H%M`"
TMP_DEST_DIR=/tmp/$name
TMP_ARCH_FILE=/tmp/$name.tgz

mkdir -p $TMP_DEST_DIR 2>/dev/null

#system report
SYSTEM_REPORT_DIR=$TMP_DEST_DIR/system
mkdir -p $SYSTEM_REPORT_DIR
ifconfig -a >$SYSTEM_REPORT_DIR/ifconfig
route -n >$SYSTEM_REPORT_DIR/route
free >$SYSTEM_REPORT_DIR/free
df >$SYSTEM_REPORT_DIR/df
mount >$SYSTEM_REPORT_DIR/mount
lsmod >$SYSTEM_REPORT_DIR/lsmod
ps >$SYSTEM_REPORT_DIR/ps
if [ $INITRAMFS -eq 0 ]; then
	cp -f $LOGS_DIR/messages $SYSTEM_REPORT_DIR/
else
	dmesg >$SYSTEM_REPORT_DIR/dmesg
fi
cp /proc/cmdline /proc/version $SYSTEM_REPORT_DIR
if [ "$BOARD" = "stb830" ]; then
	cp /sys/class/thermal/thermal_zone0/temp $SYSTEM_REPORT_DIR/temp
fi

#logs
LOGS_REPORT_DIR=$TMP_DEST_DIR/logs
mkdir -p $LOGS_REPORT_DIR
if [ $INITRAMFS -eq 0 ]; then
	cp -f $LOGS_DIR/mainapp.log $LOGS_REPORT_DIR/
fi
cp -f \
	$LOGS_ADD_FILES \
	$LOGS_REPORT_DIR/


#StbMainApp
STBMAINAPP_REPORT_DIR=$TMP_DEST_DIR/StbMainApp
mkdir -p $STBMAINAPP_REPORT_DIR
cp -f \
	$STBMAINAPP_CFGDIR/settings.conf \
	$STBMAINAPP_CFGDIR/playlist.txt \
	$STBMAINAPP_CFGDIR/channels.conf \
	$STBMAINAPP_REPORT_DIR/

#files
cp -f \
	$ADD_FILES \
	$TMP_DEST_DIR/

ls -la $CFG_MOUNT_POUNT >$TMP_DEST_DIR/config_ls
find $CFG_MOUNT_POUNT >$TMP_DEST_DIR/config_find
#nanddump -o -b -f $TMP_DEST_DIR/config_dump /dev/mtd`grep '"Sys-Config"' /proc/mtd | cut -b4` 2>&1 >$TMP_DEST_DIR/config_dump.log

tar -C /tmp -zcf $TMP_ARCH_FILE $name/
if [ "$BOARD" = "stb820" -a $INITRAMFS -eq 1 ]; then
	cp -f $TMP_ARCH_FILE $USB_MOUNT_POINT
else
	for f in `find /dev -name sd*`; do
		f1=$USB_MOUNT_POINT/${f#/dev/}
		[ -d "$f1" ] || continue
		echo "Copy report into $f1"
		cp -f $TMP_ARCH_FILE $f1/
	done
fi

#for nfs mounts
[ -d /tmp/nfs ] && cp $TMP_ARCH_FILE /tmp/nfs
[ -d /serga/report ] && cp $TMP_ARCH_FILE /serga/report

rm -rf $TMP_DEST_DIR/ $TMP_ARCH_FILE

