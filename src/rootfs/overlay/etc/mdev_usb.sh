#!/bin/sh

# Actions with usb devices:
#  * load/unload modules

#For debug uncomment below line:
#exec 1>/dev/console 2>&1

if [ "$MODALIAS" ]; then
	flags=""
	[ "$ACTION" != "add" ] && flags="-r"
#	echo "modprobe $flags $MODALIAS"
	modprobe $flags $MODALIAS;
fi
