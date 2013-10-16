#!/bin/sh

ELCD_PROGNAME=main_sdk7105_7105_ST40_LINUX_32BITS.out
LOGGER_OPTS="-t elcd-watchdog -p 2"

while :; do
	sleep 5
	if ! pidof $ELCD_PROGNAME &/dev/null; then
		logger $LOGGER_OPTS "ERROR: elcd is down!"
		logger $LOGGER_OPTS "Creating report and reboot now."
		create-report.sh
		reboot
		break
	fi
done
