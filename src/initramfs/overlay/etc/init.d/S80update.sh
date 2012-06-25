#!/bin/sh
#
# Start updater....
#

DEFAULT_HTTP_URL=http://192.168.0.1/STB830_last.efp

#dummy wait for time when usb mass storage is appiear in system
#this should be improved, and maybe moved to clientUpdater
waitUSB() {
	HAS_USB_MASS_STORAGE=`dmesg | grep "SCSI emulation for USB Mass Storage devices"`
	if [ -z "$HAS_USB_MASS_STORAGE" ]; then
		echo "There no usb mass storages! Skip waiting."
		return
	fi

	x=0
	while [ $x -lt 30 ]; do
		[ $x -ne 0 ] && usleep 200000
		[ -n "`mount | grep "/mnt/sd[a-z]"`" ] && break
		let x+=1
	done
	echo "x=$x"
}

. /opt/elecard/bin/need_network.sh

case "$1" in
  start)
	echo "Starting update... "

	echo -n "Check and set STATE flag in HW-Config ... "
	UPDATER_FLAGS=""
#	eval LASTSTATE=`/opt/elecard/bin/hwconfigManager h 0 STATE 2>/dev/null | grep "^VALUE:" | sed 's/.*: \(.*\)/$((0x\1))/'`
	LASTSTATE=`/opt/elecard/bin/hwconfigManager h 0 STATE 2>/dev/null | grep "^VALUE:" | cut -d ' ' -f 2`
	if [ -z "$LASTSTATE" ]; then
		echo "Not found. Assuming failure"
		LASTSTATE=1
	else
		let LASTSTATE=0x$LASTSTATE
		if [ "$LASTSTATE" != "0" ]; then
			echo "Non-zero. Must be failure"
		else
			echo "State is OK"
			UPDATER_FLAGS="-c $UPDATER_FLAGS"
		fi
	fi

	/opt/elecard/bin/hwconfigManager s 0 STATE 1 2>&1 1>/dev/null
	if [ "$NETWORK_NEED" ]; then
	#	UPDATERFLAGS=`/opt/elecard/bin/hwconfigManager h 0 UPFLAG 2>/dev/null | grep "^VALUE:" | sed 's/.*: \(.*\)/$((0x\1%10))/'`
		UPDATERFLAGS=`/opt/elecard/bin/hwconfigManager h 0 UPFLAG 2>/dev/null | grep "^VALUE:" | cut -d ' ' -f 2`
		let UPDATERFLAGS=0x${UPDATERFLAGS:-0}%10
		if [ "$UPDATERFLAGS" != "0" ]; then
			echo "Use extended timeout value for network update..."
			UPDATER_FLAGS="-w$UPDATERFLAGS $UPDATER_FLAGS"
		fi

		UPDATERURL=`/opt/elecard/bin/hwconfigManager a 0 UPURL 2>/dev/null | grep "^VALUE:.*tp://" | cut -d ' ' -f 2`
		if [ "$UPDATERURL" ]; then
			UPDATER_FLAGS="$UPDATER_FLAGS -h $UPDATERURL"
		else
			UPDATER_FLAGS="$UPDATER_FLAGS -h $DEFAULT_HTTP_URL"
		fi

		eval NOMUL=`/opt/elecard/bin/hwconfigManager a 0 UPNOMUL 2>/dev/null | grep "^VALUE:" | cut -d ' ' -f 2`
		if [ "$NOMUL" ]; then
			if [ "$NOMUL" != "0" ]; then
				echo "Disable multicast update"
				UPDATER_FLAGS="-n $UPDATER_FLAGS"
			fi
		fi
	else
		#disable multicast, and dont set http url
		UPDATER_FLAGS="-n $UPDATER_FLAGS"
	fi

	eval NOUSB=`/opt/elecard/bin/hwconfigManager a 0 UPNOUSB 2>/dev/null | grep "^VALUE:" | cut -d ' ' -f 2`
	if [ "${NOUSB:-0}" != "0" ]; then
		echo "Disable USB update"
		UPDATER_FLAGS="-u $UPDATER_FLAGS"
	else
		waitUSB
	fi

	/opt/elecard/bin/hwconfigManager u

	echo "UPDATER_FLAGS=\"$UPDATER_FLAGS\""
	/opt/elecard/bin/clientUpdater $UPDATER_FLAGS
	RET=$?

	/opt/elecard/bin/hwconfigManager s 0 STATE 0 2>&1 1>/dev/null
#	/opt/elecard/bin/hwconfigManager h 0 STATE

	rm -f /tmp/reboot
	if [ $RET -eq 1 ]; then
		echo "Reboot requested!"
		touch /tmp/reboot
	fi

	echo "done"

	;;
  stop)
#	echo "Can't stop updater"
	;;
  restart|reload)
	"$0" stop
	"$0" start
	;;
  *)
	echo $"Usage: $0 {start|stop|restart}"
	exit 1
esac

exit $?
