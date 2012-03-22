#!/bin/bash

unset CONFIG_BUILD_DIR_NAME
unset BUILDROOT
CONFIG_TEMPLATE=$PRJROOT/etc/configs/config_stb830_template

if [ -z "$CONFIG" ]; then
	echo "Use default config $CONFIG_TEMPLATE."
	CONFIG=$CONFIG_TEMPLATE
fi
if [ ! -e $CONFIG ]; then
	echo "ERROR"
	echo "Cant find $CONFIG"
	echo "PRJROOT=$PRJROOT"
	return
fi

eval `grep "^CONFIG_BUILD_DIR_NAME=[^[]" $CONFIG`
if [ -z "$CONFIG_BUILD_DIR_NAME" ]; then
	echo "ERROR"
	echo "No CONFIG_BUILD_DIR_NAME env in $CONFIG"
	return
fi
export BUILDROOT=$PRJROOT/$CONFIG_BUILD_DIR_NAME
if [ "`basename $CONFIG`" != ".prjconfig" ]; then
	if [ ! -e $BUILDROOT/.prjconfig ]; then
		mkdir -p $BUILDROOT
		$PRJROOT/bin/prjfilter -c /dev/null $CONFIG $BUILDROOT/.prjconfig
	fi
else
#check
	if [ "`dirname $CONFIG`" != "$BUILDROOT" ]; then
		echo "ERROR: `dirname $CONFIG` != $BUILDROOT"
		return
	fi
fi
#check config version
if [ "`grep "CONFIG_VERSION" $CONFIG_TEMPLATE`" != "`grep "CONFIG_VERSION" $BUILDROOT/.prjconfig`" ]; then
	cp -f $BUILDROOT/.prjconfig $BUILDROOT/.prjconfig_old
	$PRJROOT/bin/prjfilter -c $BUILDROOT/.prjconfig_old $CONFIG_TEMPLATE $BUILDROOT/.prjconfig
fi
unset CONFIG CONFIG_TEMPLATE CONFIG_BUILD_DIR_NAME

source $BUILDROOT/.prjconfig

export BOARD_NAME=$CONFIG_BOARD_NAME
if [ -z "$BOARD_NAME" ]; then
	echo "ERROR"
	echo "Not setted configuration name of the board in $BUILDROOT/.prjconfig"
	return
fi
if [ -z "$CONFIG_STAPISDK_VERSION" ]; then
	echo "ERROR"
	echo "Not setted CONFIG_STAPISDK_VERSION in $BUILDROOT/.prjconfig"
	return
fi

if [ "$BOARD_NAME" = "stb830" ]; then
	BOARD_CONFIG_NAME=SDK7105_7105_LINUX
elif [ "$BOARD_NAME" = "stb840" ]; then
	BOARD_CONFIG_NAME=HDK7167_7167_LINUX
else
	BOARD_CONFIG_NAME=SDK7105_7105_LINUX
fi

export STAPISDK_VERSION=$CONFIG_STAPISDK_VERSION
if [ -z "$STB830_SDK" ]; then
	export STSDKROOT=/opt/STM/stapisdk-$STAPISDK_VERSION
	#setup STAPISDK environment
	source $STSDKROOT/bin/setenv.sh $BOARD_CONFIG_NAME

	export LIBCURL=1
	export CURLROOT=$STSDKROOT/opensource/curl

	export LINUX_SERVERDIR=$BUILDROOT/rootfs
	export KTARGET=$LINUX_SERVERDIR/root
	export DEBUG=0

	if [ -n "$CONFIG_DVD_FRONTEND_TUNER" ]; then
		export DVD_FRONTEND_TUNER=$CONFIG_DVD_FRONTEND_TUNER
	fi

	if [ -n "$CONFIG_DVD_DISPLAY_HD" ]; then
		export DVD_DISPLAY_HD=$CONFIG_DVD_DISPLAY_HD
	fi
else
	export LINUX_VERSION=2.4
fi

#LINUX_VERSION - this variable sets in setenv.sh
KDIR=/opt/STM/STLinux-${LINUX_VERSION}/devkit/sources/kernel/linux-sh4
if [ "$STAPISDK_VERSION" = "30.0" ]; then
	FULL_LINUX_VERSION=2.3
elif [ "$STAPISDK_VERSION" = "35.0" -o "$STAPISDK_VERSION" = "35.1" ]; then
#	FULL_LINUX_VERSION=2.6.32.28_stm24_V3.0
	FULL_LINUX_VERSION=2.6.32.42_stm24_V4.0
	KDIR=/opt/STM/STLinux-${LINUX_VERSION}/devkit/sources/kernel/linux-sh4-${FULL_LINUX_VERSION}
elif [ "$STAPISDK_VERSION" = "36.0" -o "$STAPISDK_VERSION" = "36.2" ]; then
	FULL_LINUX_VERSION=2.6.32.42_stm24_V4.0
	KDIR=/opt/STM/STLinux-${LINUX_VERSION}/devkit/sources/kernel/linux-sh4-${FULL_LINUX_VERSION}
	export MULTICOM_SOURCE=/opt/STM/MULTICOM/R4.0.5
else
	echo "ERROR: not setted linux version for $STAPISDK_VERSION!!!!"
	return
#	exit 1
#	FULL_LINUX_VERSION=2.3
fi
export FULL_LINUX_VERSION KDIR

export STAGINGDIR=$BUILDROOT/packages/buildroot/output_rootfs/staging
export ROOTFS=$BUILDROOT/rootfs
export INITRAMFS=$BUILDROOT/initramfs


addToEnv() {
	if ! echo ${!1} | grep -E "(^|:)$2(:|$)" > /dev/null; then
		if [ -z "${!1}" ]; then
			export $1=$2
		else
			export $1=${!1}:$2
		fi
	fi
}
addToEnv PATH $PRJROOT/bin:/opt/STM/STLinux-${LINUX_VERSION}/host/bin
addToEnv PERLLIB $PRJROOT/etc/perllib
if [ -n "$STB830_SDK" ]; then
	addToEnv PATH /opt/STM/STLinux-${LINUX_VERSION}/devkit/sh4/bin
fi

#unset variables that came from source $BUILDROOT/.prjconfig
#unset `set | grep "^CONFIG_" | cut -f 1 -d =`
unset `cat $BUILDROOT/.prjconfig | grep "^CONFIG_" | cut -f 1 -d =`

rm -f $PRJROOT/.maketools

