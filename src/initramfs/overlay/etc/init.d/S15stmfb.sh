#!/bin/sh

STMFB_PARAMS=display0=1280x720-24@60:4M:0:PAL:YUV:RGB

insmodSafe() {
	local module=$1
	shift
	test -e "$module" && insmod $module "$@"
}

case "$1" in
	start)
		echo -n "Starting stmfb... "
		insmodSafe /lib/modules/STLinux-2.4/stmcore-display-sti7105.ko
		insmodSafe /lib/modules/STLinux-2.4/stmfb.ko $STMFB_PARAMS

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
