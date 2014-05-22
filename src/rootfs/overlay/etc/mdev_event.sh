#!/bin/sh

# Actions with input events:

#For debug uncomment below line:
#exec 1>/dev/console 2>&1

if [ "$ACTION" == "add" ]; then
	mkdir -p input && chmod 755 input && mv $MDEV input/
	/opt/elecard/bin/mdevmonitor $ACTION@/$MDEV
elif [ "$ACTION" == "remove" ]; then
	/opt/elecard/bin/mdevmonitor $ACTION@/$MDEV
	rm input/$MDEV
fi
