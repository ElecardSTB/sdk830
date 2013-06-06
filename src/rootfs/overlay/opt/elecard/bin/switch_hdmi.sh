#!/bin/sh

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
	echo $gpio >export
	echo out >gpio$gpio/direction
	echo 0 >gpio$gpio/value
done

echo 1 >gpio8$1/value

