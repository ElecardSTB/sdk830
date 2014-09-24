#!/bin/sh

# Redirect stderr to /dev/null
exec 3>&2
exec 2>/dev/null

wifi_led.sh 0

# this should be done by ifdown
# if [ -e /var/run/udhcpc.wlan0.pid ]; then
# 	kill `cat /var/run/udhcpc.wlan0.pid`
# fi
killall hostapd
# killall wpa_supplicant
sleep 1
killall -9 wpa_supplicant
rm -rf /var/run/wpa_supplicant

# Restore stderr
exec 2>&3 3>&-

exit 0
