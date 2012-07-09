#!/bin/sh


case "$1" in
	start)
		echo -n "Check HW-Config... "

		MYSYSID=`hwconfigManager h 0 SYSID | grep "^VALUE:" | cut -d ' ' -f 2`
		if [ "$MYSYSID" != "08024001" ]; then
			echo "HW-Config is missing or corrupted (MYSYSID=\"$MYSYSID\"). Restoring factory defaults... "
			hwconfigManager g 0 /etc/hwconfig.conf
			if [ $? != 0 ]; then
				echo "Failed to restore HW-Config!"
				exit 1
			fi
		fi
		hwconfigManager k 0

		echo "done"
		;;
	stop)
		;;
	*)
		echo "Usage: $0 {start|stop}"
		exit 1
		;;
esac
