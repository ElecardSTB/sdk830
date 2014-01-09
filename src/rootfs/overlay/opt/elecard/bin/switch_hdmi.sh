#!/bin/sh
# HDMI switcher:
#  80: PIO10.0  - S1  SoC
#  81: PIO10.1  - S2  HDMI in2
#  82: PIO10.2  - S3  HDMI in3

usage() {
	echo "Usage:"
	echo "${0##*/} input"
	echo -e "\tvalid inputs:"
	echo -e "\t\t0 - from SoC"
	echo -e "\t\t1 - hdmi in 2"
	echo -e "\t\t2 - hdmi in 3"
}

if [ -z "$1" ]; then
	usage
	exit 1
fi
if [ "$1" -lt 0 -o "$1" -gt 2 ]; then
	usage
	exit 2
fi

cd /sys/class/gpio/
for gpio in 80 81 82; do
	if [ ! -e gpio${gpio} ]; then
		echo $gpio >export
	fi
	echo out >gpio${gpio}/direction
	echo 0 >gpio${gpio}/value
done

echo 1 >gpio8$1/value

