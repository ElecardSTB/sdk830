#!/bin/sh


MOUNT_DIR="/var/etc"

case "$1" in
	start)
		echo -n "Mounting user fs... "

#		USERFS=`cat /proc/mtd | grep "\"User\"" | sed 's/^mtd\(.\):.*/mtd\1/'`
		USERFS=`grep "\"User\"" /proc/mtd | sed 's/^mtd\(.\):.*/mtd\1/'`

		if [ "$USERFS" ]; then
			mount -o noatime,rw -t jffs2 $USERFS $MOUNT_DIR
		fi

		echo "done"
		;;
	stop)
		echo -n "Unmounting user fs... "

		umount $MOUNT_DIR

		echo "done"
		;;
	*)
		echo "Usage: $0 {start|stop}"
		exit 1
		;;
esac