#!/bin/sh


case "$1" in
	start)
		echo -n "Check HW-Config... "
		
		MYSYSID=`/opt/elecard/bin/hwconfigManager h 0 SYSID | grep "^VALUE:" | sed 's/.*: \(.*\)/\1/'`
		if [ "$MYSYSID" != "08024001" ]; then
			echo "HW-Config is missing or corrupted (MYSYSID=\"$MYSYSID\"). Restoring factory defaults... "
			/opt/elecard/bin/hwconfigManager g 0 /etc/hwconfig.conf
			if [ $? != 0 ]; then
				echo "Failed to restore HW-Config!"
				exit 1
			fi
		fi
		/opt/elecard/bin/hwconfigManager k 0
		echo "done"
		;;
	stop)
		;;
	*)
		echo "Usage: $0 {start|stop}"
		exit 1
		;;
esac
