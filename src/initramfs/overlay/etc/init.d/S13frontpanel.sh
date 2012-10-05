#/bin/sh
#
# run frontpanel daemon

export PATH=$PATH:/opt/elecard/bin

case "$1" in
	start)
		frontpanel -t
		;;
	stop)
		killall frontpanel
		;;
	*)
		echo "Usage: $0 {start|stop}"
		exit 1
		;;
esac
