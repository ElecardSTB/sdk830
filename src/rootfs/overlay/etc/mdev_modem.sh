#!/bin/sh

if [ -n "$DEVNAME" ]; then
	if [ "$ACTION" = "add" ]; then
		/usr/sbin/pppd call mobile-noauth
	else
		timeout=3
		while [ $timeout -gt 0 ]; do
			killall pppd || break
			sleep 1
			let timeout=timeout-1
		done
		killall -9 pppd
	fi
fi

