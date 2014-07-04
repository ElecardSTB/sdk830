#!/bin/sh

reset_AC97() {
	echo -n "Reseting AC97... "
	echo 83 >/sys/class/gpio/export
	echo out >/sys/class/gpio/gpio83/direction
	echo 0 >/sys/class/gpio/gpio83/value
	usleep 1000
	echo 1 >/sys/class/gpio/gpio83/value
	usleep 1000
	echo 83 >/sys/class/gpio/unexport
	echo "done"
}

case "$1" in
	start)
#		echo "Starting loading em28xx..."
		reset_AC97

		while :; do
			modprobe -r em28xx_v4l
			modprobe em28xx_v4l

			num_alt=`grep "dev->num_alt=" /tmp/messages | tail -1 | cut -d '=' -f 2`
			if [ "$num_alt" != "0" ]; then
#				echo "em28xx loaded successfully!"
				break
			else
				echo "Trying to load em28xx one more time!"
			fi
		done
#		echo "Loading em28xx - done"
		;;
	stop)
		modprobe -r em28xx
		;;
	*)
		echo "Usage: $0 {start|stop}"
		exit 1
esac

exit $?
