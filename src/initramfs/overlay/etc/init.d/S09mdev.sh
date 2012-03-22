#!/bin/sh

# Start/stop mdev


case "$1" in
	start)
		echo -n "Starting mdev... "
		/bin/mount -t tmpfs mdev /dev
		/bin/mkdir -p /dev/pts
		echo /sbin/mdev > /proc/sys/kernel/hotplug
#is need scanning???
		mdev -s
		echo "done"
		;;
	stop)
		echo  > /proc/sys/kernel/hotplug
		umount /dev
		;;
	*)
		echo "Usage: $0 {start|stop}"
		exit 1
		;;
esac
