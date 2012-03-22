#!/bin/sh
#
# Start updater....
#

#dummy wait for time when usb mass storage is appiear in system
#this should be improved, and maybe moved to clientUpdater
waitUSB() {

	HAS_USB_MASS_STORAGE=`dmesg | grep "SCSI emulation for USB Mass Storage devices"`
	if [ -z "$HAS_USB_MASS_STORAGE" ]; then
		echo "There no usb mass storages! Skip waiting."
		return
	fi
	
	x=0
	while [ $x -lt 6 ]; do

		if [ $x -ne 0 ]; then
			sleep 1
		fi

		if [ -n "`mount | grep "/mnt/sd[a-z]"`" ]; then
			break;
		fi
		let x+=1

	done
	echo "x=$x"
}


case "$1" in
  start)
	echo "Starting update... "

	echo -n "Check and set STATE flag in HW-Config ... "
	UPDATER_FLAGS=""
	eval LASTSTATE=`/opt/elecard/bin/hwconfigManager h 0 STATE 2>/dev/null | grep "^VALUE:" | sed 's/.*: \(.*\)/$((0x\1))/'`
#echo "LASTSTATE=\"$LASTSTATE\""
	if [ -z "$LASTSTATE" ]; then
		echo "Not found. Assuming failure"
		LASTSTATE=1
	else
		if [ "$LASTSTATE" != "0" ]; then
			echo "Non-zero. Must be failure"
		else
			echo "State is OK"
			UPDATER_FLAGS="-c $UPDATER_FLAGS"
		fi
	fi
	/opt/elecard/bin/hwconfigManager s 0 STATE 1 2>&1 1>/dev/null

	eval UPDATERFLAGS=`/opt/elecard/bin/hwconfigManager h 0 UPFLAG 2>/dev/null | grep "^VALUE:" | sed 's/.*: \(.*\)/$((0x\1%10))/'`
	if [ "$UPDATERFLAGS" ]; then
		if [ "$UPDATERFLAGS" != "0" ]; then
			echo "Use extended timeout value for network update..."
			UPDATER_FLAGS="-w$UPDATERFLAGS $UPDATER_FLAGS"
		fi
	fi

	UPDATERURL=`/opt/elecard/bin/hwconfigManager a 0 UPURL 2>/dev/null | grep "^VALUE:" | grep "tp://" | sed 's/.*: \(.*\)/\1/'`
	if [ "$UPDATERURL" ]; then
		UPDATER_FLAGS="$UPDATER_FLAGS -h $UPDATERURL"
	fi

	eval NOUSB=`/opt/elecard/bin/hwconfigManager a 0 UPNOUSB 2>/dev/null | grep "^VALUE:" | sed 's/.*: \(.*\)/\1/'`
	if [ "$NOUSB" ]; then
		if [ "$NOUSB" != "0" ]; then
			echo "Disable USB update"
			UPDATER_FLAGS="-u $UPDATER_FLAGS"
			DONTWAITUSB=1
		fi
	fi

	eval NOMUL=`/opt/elecard/bin/hwconfigManager a 0 UPNOMUL 2>/dev/null | grep "^VALUE:" | sed 's/.*: \(.*\)/\1/'`
	if [ "$NOMUL" ]; then
		if [ "$NOMUL" != "0" ]; then
			echo "Disable multicast update"
			UPDATER_FLAGS="-n $UPDATER_FLAGS"
		fi
	fi

	/opt/elecard/bin/hwconfigManager u

	waitUSB

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
