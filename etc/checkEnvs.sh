#!/bin/sh

if [ -z "$PRJROOT" ]; then
	echo "Error: PRJROOT not setted! Did you setup environment?"
	exit 1
fi
if [ ! -e $BUILDROOT/timestamps/.stamp_validenvironment ]; then
	echo "Environment is obsolete! Please setup environment again."
	exit 1
fi

echo_message() {
	echo
	echo   "************************************************************************"
	printf "##   %-65s##\n" "$1"
	echo   "************************************************************************"
}
