#!/bin/sh

if [ -n "$DEVNAME" ]; then
	if [ "$ACTION" = "add" ]; then
[% IF ENV.ENABLE_MOBILE_LTE -%]
		/usr/sbin/pppd call mobile-noauth-lte
[% ELSE -%]
		/usr/sbin/pppd call mobile-noauth
[% END -%]
	else
		timeout=3
		killall pppd
		while killall pppd; do
			let timeout=timeout-1
			if [ $timeout -le 0 ]; then
				killall -9 pppd
				break
			fi
			sleep 1
		done
	fi
fi

