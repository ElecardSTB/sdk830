#!/bin/sh
#
# Start the network....
#


interfacesFile=/var/etc/interfaces

parseInterface() {
	interface=$1
	interfacesFileOut=$2
	echo -e "\n# $interface" >> $interfacesFileOut
	match=0
	if grep -q "addif br0 $interface" $interfacesFile; then
		cat $interfacesFile | while read LINE ; do
			if echo $LINE | grep -q "auto br0"; then
				match=1
			fi
			if [ $match -eq 1 ]; then
				if echo $LINE | grep -q "broadcast +"; then
					match=0
					continue
				fi
				echo $LINE | sed "s/br0/$interface/g" >> $interfacesFileOut
			fi
		done
		eval $1=br0
	else
		cat $interfacesFile | while read LINE ; do
			if echo $LINE | grep -q "auto $interface"; then
				match=1
			fi
			if [ $match -eq 1 ]; then
				if [ -z "$LINE" ]; then
					match=0
					continue
				fi
				echo $LINE >> $interfacesFileOut
			fi
		done
	fi
}



case "$1" in
	start)
		UPDATERURL=`/opt/elecard/bin/hwconfigManager a 0 UPURL 2>/dev/null | grep "^VALUE:" | grep "tp://" | sed 's/.*: \(.*\)/\1/'`
		eval NOMUL=`/opt/elecard/bin/hwconfigManager a 0 UPNOMUL 2>/dev/null | grep "^VALUE:" | sed 's/.*: \(.*\)/\1/'`
		if [ -z "$UPDATERURL" -a "$NOMUL" -a $NOMUL -ne 0 ]; then
			echo "URL not setted and multicast update disabled, so skip network start!!!"
			exit 0;
		fi

		echo -n "Starting network... "

		echo "" > /tmp/interfaces_eth
		parseInterface eth0 /tmp/interfaces_eth
		parseInterface eth1 /tmp/interfaces_eth
		if [ -z "`cat /proc/cmdline | grep /dev/nfs`" ]; then
			/sbin/ifup -i /tmp/interfaces_eth eth0
			if [ "$eth0" != "br0" -o "$eth1" != "br0" ]; then
				/sbin/ifup -i /tmp/interfaces_eth eth1
			fi
		else
			# Get routes and nameservers from dhcp
			udhcpc -n -i eth0 -s /opt/elecard/bin/udhcpc.nfs
			/sbin/ifup -i /tmp/interfaces_eth eth1
		fi

		route add -net 224.0.0.0 netmask 240.0.0.0 eth0

#		echo -e "\n\n /tmp/interfaces_eth"
#		cat /tmp/interfaces_eth
#		ifconfig -a

		echo "done"

		;;
	stop)
		echo -n "Stopping network... "
		killall udhcpc
	#	iptables -t nat -F
		if [ -z "`cat /proc/cmdline | grep /dev/nfs`" ]; then
			ifdown -i /tmp/interfaces_eth -a
		else
			ifdown -i /tmp/interfaces_eth eth1
		fi

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
