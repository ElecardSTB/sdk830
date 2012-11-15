#!/bin/sh

if [ ! "$PRJROOT" ]; then
	echo "Error: PRJROOT not setted! Did you setup environment?"
	exit 1
fi

echo_message() {
	echo
	echo   "************************************************************************"
	printf "##   %-65s##\n" "$1"
	echo   "************************************************************************"
}
