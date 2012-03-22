#!/bin/sh

[% SKIPFILE %]


case "$1" in
	start)
		if [ -n "`cat /proc/cmdline | grep jtag_boot`" ]; then
			#this start when board loading throught jtag
			/opt/elecard/bin/jtagBurnFlash.sh
			/bin/sh --login
			exit
		fi
		;;
	stop)
		;;
	*)
		echo "Usage: $0 {start|stop}"
		exit 1
		;;
esac
