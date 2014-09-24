#!/bin/sh

WIFI_LED_DIR=/sys/class/leds/WIFI
if [ -e "$WIFI_LED_DIR" ]; then
	echo $1 > $WIFI_LED_DIR/brightness
fi
exit 0
