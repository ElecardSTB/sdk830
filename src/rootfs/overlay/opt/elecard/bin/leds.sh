#!/bin/sh

DELAY=1000000

led_list=/sys/class/leds/*;

while :; do
	for i in $led_list; do
		echo "1" > $i/brightness;
	done;
	usleep $DELAY;
	for i in $led_list; do
		echo "0" > $i/brightness;
	done;
	usleep $DELAY;
done