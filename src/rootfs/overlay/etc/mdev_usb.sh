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

if [ "$DEVTYPE" = "usb_device" ]; then
	if [ "$ACTION" = "add" ]; then
		VID=${PRODUCT:0:4}
		PID=${PRODUCT:5:4}
		if [ -f "/usr/share/usb_modeswitch/${VID}:${PID}" ]; then
			/usr/sbin/usb_modeswitch -D -c /usr/share/usb_modeswitch/${VID}:${PID} -v $VID -p $PID
		fi
	fi
fi
