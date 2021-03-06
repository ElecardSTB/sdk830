#!/bin/sh

BOARD=stb830
if [ ! -e /proc/board/name ]; then
	#BOARD=`stbstm -m 2>/dev/null`
	BOARD=stb820
fi

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

name="$BOARD${1:+.$1}-`date +%Y%m%d%H%M`"
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
echo -e "\n#netstat -tunp:" >$SYSTEM_REPORT_DIR/netstat
netstat -tunp >>$SYSTEM_REPORT_DIR/netstat 2>&1
echo -e "\n#netstat -tunlp:" >>$SYSTEM_REPORT_DIR/netstat
netstat -tunlp >>$SYSTEM_REPORT_DIR/netstat 2>&1
lsusb >>$SYSTEM_REPORT_DIR/lsusb

if [ $INITRAMFS -eq 0 ]; then
	cp -f $LOGS_DIR/messages $SYSTEM_REPORT_DIR/
else
	dmesg >$SYSTEM_REPORT_DIR/dmesg
fi
cp /proc/cmdline /proc/version $SYSTEM_REPORT_DIR
if [ "$BOARD" = "stb830" ]; then
	cp /sys/class/thermal/thermal_zone0/temp $SYSTEM_REPORT_DIR/temp
	echo `cat /proc/board/name`.`cat /proc/board/ver` >$SYSTEM_REPORT_DIR/board_name
fi

grep /sys/kernel/debug /proc/mounts || mount -t debugfs none /sys/kernel/debug/
mkdir -p $SYSTEM_REPORT_DIR/debug
for i in bpa2 gpio ilc pads sysconf; do
	cp -a /sys/kernel/debug/$i $SYSTEM_REPORT_DIR/debug
done
cp -a /sys/kernel/debug/usb/devices $SYSTEM_REPORT_DIR/debug/usb_devices


copyFile() {
	if [ ! -e "$1" ]; then
		echo "\"$1\" not exist!"
		return
	fi
	if [ ! -d "$2" ]; then
		echo "\"$2\" not directory!"
		return
	fi
	cp -a $1 $2
}

#logs
LOGS_REPORT_DIR=$TMP_DEST_DIR/logs
mkdir -p $LOGS_REPORT_DIR
for i in $LOGS_DIR/mainapp.log $LOGS_ADD_FILES; do
	copyFile $i $LOGS_REPORT_DIR
done

#StbMainApp config files
copyFile $STBMAINAPP_CFGDIR $TMP_DEST_DIR

#files
if [ "$ADD_FILES" ]; then
	for i in $ADD_FILES; do
		copyFile $i $TMP_DEST_DIR
	done
fi

ls -la $CFG_MOUNT_POUNT >$TMP_DEST_DIR/config_ls
find $CFG_MOUNT_POUNT >$TMP_DEST_DIR/config_find
#nanddump -o -b -f $TMP_DEST_DIR/config_dump /dev/mtd`grep '"Sys-Config"' /proc/mtd | cut -b4` 2>&1 >$TMP_DEST_DIR/config_dump.log

REPORT_FILENAME=${TMP_ARCH_FILE#/tmp/}

tar -C /tmp -zcf $TMP_ARCH_FILE $name/
if [ "$BOARD" = "stb820" ]; then
	if [ $INITRAMFS -eq 1 ]; then
		cp -f $TMP_ARCH_FILE $USB_MOUNT_POINT
	else
		for f in `ls /dev/sd? 2>/dev/null`; do
			diskLetter=${f#/dev/sd}
			if ls $f[0-9] 2>/dev/null 1>/dev/null; then
				cp -f $TMP_ARCH_FILE "$USB_MOUNT_POINT/Disk $diskLetter Partition 1"
				echo "Copy into \"$USB_MOUNT_POINT/Disk $diskLetter Partition 1/$REPORT_FILENAME\""
			else
				#no partitions
				cp -f $TMP_ARCH_FILE "$USB_MOUNT_POINT/Disk $diskLetter"
				echo "Copy into \"$USB_MOUNT_POINT/Disk $diskLetter/$REPORT_FILENAME\""
			fi
		done
	fi
else #stb830
	for f in `ls /dev/sd* 2>/dev/null`; do
		f1=$USB_MOUNT_POINT/${f#/dev/}
		[ -d "$f1" ] || continue
		echo "Copy report into $f1/$REPORT_FILENAME"
		cp -f $TMP_ARCH_FILE $f1/
	done
	mkdir -p $CFG_MOUNT_POUNT/reports
	cp $TMP_ARCH_FILE $CFG_MOUNT_POUNT/reports
	echo "Copy into \"$CFG_MOUNT_POUNT/reports/$REPORT_FILENAME\""
fi

#for nfs mounts
[ -d /tmp/nfs ] && cp $TMP_ARCH_FILE /tmp/nfs
[ -d /serga/report ] && cp $TMP_ARCH_FILE /serga/report

rm -rf $TMP_DEST_DIR/ $TMP_ARCH_FILE

sync
