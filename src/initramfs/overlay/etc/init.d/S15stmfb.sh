#!/bin/sh

STMFB_PARAMS=display0=720x576-24@50i:3M:0:PAL:CVBS:CVBS

case "$1" in
	start)
		echo -n "Starting stmfb... "
		insmod /lib/modules/STLinux-2.4/stmcore-display-sti7105.ko
		insmod /lib/modules/STLinux-2.4/stmfb.ko $STMFB_PARAMS

		/opt/elecard/bin/fb_logo &
		echo "done"
		;;
	stop)
		while killall fb_logo; do :;done
		# rmmod stmfb
		# rmmod stmcore-display-sti7105
		;;
	*)
		echo "Usage: $0 {start|stop}"
		exit 1
		;;
esac
