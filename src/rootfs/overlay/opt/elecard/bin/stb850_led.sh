#!/bin/sh

DELAY=1000000

SSD_FB_DEV=/dev/fb1
if [ "`cat /proc/cmdline | grep /dev/nfs`" ]; then
#nfs boot
	[ ! -e /dev/fb0 ] && SSD_FB_DEV=/dev/fb0
else
#nand boot, we should wait while elcd create /dev/fb0
	while [ ! -e /dev/fb0 ]; do
		usleep $DELAY;
	done
fi

echo "1" >/sys/devices/platform/ct1628/disabled
modprobe ssd1307
usleep 50000
if [ -c $SSD_FB_DEV ]; then
	cat /opt/elecard/share/logo.bin > $SSD_FB_DEV
fi
modprobe -r ssd1307
echo "0" >/sys/devices/platform/ct1628/disabled
