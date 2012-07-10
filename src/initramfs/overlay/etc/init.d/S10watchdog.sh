#!/bin/sh
#
# Start/stop watchdog.
#

case "$1" in
	start)
		echo -n "Starting watchdog..."
		watchdog -t 10 -T 30 /dev/watchdog
		echo "done."
		;;
	stop)
		echo -n "Stopping watchdog..."
		killall watchdog
		echo "done."
		;;
	*)
		echo $"Usage: $0 {start|stop}"
		exit 1
esac

exit 0
