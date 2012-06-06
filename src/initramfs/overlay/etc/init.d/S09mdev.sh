#!/bin/sh

# Start/stop mdev


case "$1" in
	start)
		echo -n "Starting mdev... "
		/bin/mkdir -p /dev/pts
		mount -t devpts devpts /dev/pts
		echo /sbin/mdev > /proc/sys/kernel/hotplug
#		if [ `lsusb | grep -c .` -gt 4 ]; then #first 4 devices are build in STi7105 SoC
#		if [ `ls /sys/block/ | grep "sd." -c` -gt 0 ]; then #check block devices
#			echo n "Scanning /sys ... "
			mdev -s
#		fi
		echo "done"
		;;
	stop)
		echo  > /proc/sys/kernel/hotplug
		umount /dev/pts
		;;
	*)
		echo "Usage: $0 {start|stop}"
		exit 1
		;;
esac
