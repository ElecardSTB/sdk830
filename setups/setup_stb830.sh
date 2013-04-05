#!/bin/bash

PRJROOT_DIRTY=`dirname ${BASH_SOURCE[0]}`
export PRJROOT=`readlink -f ${PRJROOT_DIRTY%/setups}`
unset PRJROOT_DIRTY

unset CONFIG

if [ -n "$1" ]; then
	TEMP_CONFIG=`readlink -f $1`
	if [ -d $TEMP_CONFIG ]; then
		if [ -f $TEMP_CONFIG/.prjconfig ]; then
			CONFIG=$TEMP_CONFIG/.prjconfig
		else
			echo "Warning: cant find .prjconfig in $TEMP_CONFIG directory"
		fi
	elif [ -f $TEMP_CONFIG ]; then
		CONFIG=$TEMP_CONFIG
	else
		echo "Warning: Unknown argument: $1"
	fi
	unset TEMP_CONFIG
else
	if [ `ls */.prjconfig 2>/dev/null | wc -l` -eq 1 ]; then
		CONFIG=`readlink -f */.prjconfig`
	fi
fi

echo "Selected config: $CONFIG"

if [ ! -e $PRJROOT/setups/common.sh ]; then
	echo "ERROR"
	echo "Cant find \$PRJROOT/setups/common.sh"
	echo "\$PRJROOT=$PRJROOT"
	return
fi

#export PATH=$PATH:/opt/elecard/DSP/STB830_st/build_stb830/packages/buildroot-2010.11_rootfs/output/staging/usr/bin

source $PRJROOT/setups/common.sh

export HW_VER=stb830_st


