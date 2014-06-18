#!/bin/sh
#
# Start updater....
#

. /opt/elecard/bin/need_network.sh

DEFAULT_HTTP_URL=http://192.168.0.1/STB830_last.efp
DEFAULT_NAMESERVER=8.8.8.8

waitNET() {
	if [ -z "$NETWORK_NEED" ]; then
		return
	fi
	local x=0
	while [ ! -f /tmp/resolv.conf ] ; do
		if [ $x -ge 15 ]; then
			echo "WARNING: Cant wait for resolv.conf!!! Use default nameserver $DEFAULT_NAMESERVER."
			echo "nameserver $DEFAULT_NAMESERVER" >/tmp/resolv.conf
			break
		fi
		usleep 200000
#		echo "waitNET(): $x"
		let x+=1
	done
	echo "waitNET(): done $x"
}

#dummy wait for time when usb mass storage is appiear in system
#this should be improved, and maybe moved to clientUpdater
waitUSB() {
	local HAS_USB_MASS_STORAGE=`dmesg | grep "SCSI emulation for USB Mass Storage devices"`
	if [ -z "$HAS_USB_MASS_STORAGE" ]; then
		echo "There no usb mass storages! Skip waiting."
		waitNET
		return
	fi

	local x=0
	while ! grep "/mnt/sd[a-z]" /proc/mounts; do
		[ $x -ge 30 ] && break
		usleep 200000
#		echo "waitUSB(): $x"
		let x+=1
	done
	echo "waitUSB(): done $x"
}


case "$1" in
  start)
	echo "Starting update... "

	echo -n "Check and set STATE flag in HW-Config ... "
	UPDATER_FLAGS=""
#	eval LASTSTATE=`hwconfigManager h 0 STATE 2>/dev/null | grep "^VALUE:" | sed 's/.*: \(.*\)/$((0x\1))/'`
	LASTSTATE=`hwconfigManager h 0 STATE 2>/dev/null | grep "^VALUE:" | cut -d ' ' -f 2`
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

	hwconfigManager s 0 STATE 1 2>&1 1>/dev/null
	if [ "$NETWORK_NEED" ]; then
	#	UPDATERFLAGS=`hwconfigManager h 0 UPFLAG 2>/dev/null | grep "^VALUE:" | sed 's/.*: \(.*\)/$((0x\1%10))/'`
		UPDATERFLAGS=`hwconfigManager h 0 UPFLAG 2>/dev/null | grep "^VALUE:" | cut -d ' ' -f 2`
		let UPDATERFLAGS=0x${UPDATERFLAGS:-0}%10
		if [ $UPDATERFLAGS -ne 0 ]; then
			echo "Use extended timeout value for network update..."
			UPDATER_FLAGS="-w$UPDATERFLAGS $UPDATER_FLAGS"
		fi

		UPDATERURL=`hwconfigManager a 0 UPURL 2>/dev/null | grep "^VALUE:.*tp://" | cut -d ' ' -f 2`
		if [ "$UPDATERURL" != "" ]; then
			UPDATER_FLAGS="$UPDATER_FLAGS -h $UPDATERURL"
		else
			UPDATER_FLAGS="$UPDATER_FLAGS -h $DEFAULT_HTTP_URL"
		fi

		NOMUL=`hwconfigManager h 0 UPNOMUL 2>/dev/null | grep "^VALUE:" | cut -d ' ' -f 2`
		let NOMUL=0x${NOMUL:-0}
		if [ $NOMUL -ne 0 ]; then
			echo "Disable multicast update"
			UPDATER_FLAGS="-n $UPDATER_FLAGS"
		fi
	else
		#disable multicast, and dont set http url
		UPDATER_FLAGS="-n $UPDATER_FLAGS"
	fi

	eval NOUSB=`hwconfigManager h 0 UPNOUSB 2>/dev/null | grep "^VALUE:" | cut -d ' ' -f 2`
	let NOUSB=0x${NOUSB:-0}
	if [ $NOUSB -ne 0 ]; then
		echo "Disable USB update"
		UPDATER_FLAGS="-u $UPDATER_FLAGS"
		waitNET
	else
		waitUSB
	fi

	hwconfigManager u
	rm -f /tmp/reboot

	echo "UPDATER_FLAGS=\"$UPDATER_FLAGS\""
	clientUpdater $UPDATER_FLAGS
	RET=$?

	hwconfigManager s 0 UPFOUND 0 2>&1 1>/dev/null
	hwconfigManager s 0 STATE 0 2>&1 1>/dev/null

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
