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
	BUILDROOT_REAL=`readlink -f $BUILDROOT`
	CONFIG_DIR=`dirname $CONFIG`
	if [ "$CONFIG_DIR" != "$BUILDROOT_REAL" ]; then
		echo "BUILDROOT=$BUILDROOT"
		echo "BUILDROOT_REAL=$BUILDROOT_REAL"
		echo "CONFIG_DIR=$CONFIG_DIR"
		echo "ERROR: CONFIG_DIR != BUILDROOT_REAL"
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
#FULL_LINUX_VERSION2 - version for downloading from ftp://ftp.stlinux.com
if [ "$STAPISDK_VERSION" = "35.0" -o "$STAPISDK_VERSION" = "35.1" ]; then
#	FULL_LINUX_VERSION2=2.6.32.28_stm24_V3.0-207
	FULL_LINUX_VERSION2=2.6.32.42_stm24_V4.0-208
	STAPISDK_MULTICOM_VERSION=4.0.5
elif [ "$STAPISDK_VERSION" = "36.0" -o "$STAPISDK_VERSION" = "36.2" ]; then
	FULL_LINUX_VERSION2=2.6.32.42_stm24_V4.0-208
	STAPISDK_MULTICOM_VERSION=4.0.5
elif [ "$STAPISDK_VERSION" = "38.0" -o "$STAPISDK_VERSION" = "38.1" ]; then
	FULL_LINUX_VERSION2=2.6.32.57_stm24_V5.0-210
	STAPISDK_MULTICOM_VERSION=4.0.5P2
else
# if [ "$STAPISDK_VERSION" = "30.0" ]; then
# 	FULL_LINUX_VERSION=2.3
	echo "ERROR: not setted linux version for $STAPISDK_VERSION!!!!"
	return
#	exit 1
fi
export FULL_LINUX_VERSION2 STAPISDK_MULTICOM_VERSION

make -C $PRJROOT scripts
if [ -z "$STB830_SDK" ]; then
	. $PRJROOT/src/elecard/setups/common.sh
else
#LINUX_VERSION - this variable sets in stapisdk`s setenv.sh
	export LINUX_VERSION=2.4
fi

export FULL_LINUX_VERSION=${FULL_LINUX_VERSION2%-*}
export KDIR=$BUILDROOT/packages/linux-sh4-$FULL_LINUX_VERSION
export MULTICOM_SOURCE=$BUILDROOT/packages/multicom-$STAPISDK_MULTICOM_VERSION

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


#Check if stapisdk version is changed from last time
TIMESTAMPS_DIR=$BUILDROOT/timestamps
STAPISDK_VERSION_FILE=$TIMESTAMPS_DIR/stapisdk_ver
[ -e $TIMESTAMPS_DIR ] || mkdir -p $TIMESTAMPS_DIR
[ -e $STAPISDK_VERSION_FILE ] || touch $STAPISDK_VERSION_FILE
STAPISDK_VERSION_PREV=`cat $STAPISDK_VERSION_FILE`
if [ "$STAPISDK_VERSION" != "$STAPISDK_VERSION_PREV" ]; then
#if version is changed, clean st2fx libraries and kernel modules
	echo -e "\nSTAPISDK version changed from $STAPISDK_VERSION_PREV to $STAPISDK_VERSION."
	echo -e "So remove st2fx libraries and kernel modules!\n"
	$PRJROOT/bin/cleanSt2fxLibs.sh
	rm -rf $ROOTFS/lib/modules/*
	rm -rf $PRJROOT/src/elecard/apps/elcd/src/objs $PRJROOT/src/elecard/apps/testServer/src/objs
	rm -f $TIMESTAMPS_DIR/.configlinux $TIMESTAMPS_DIR/.makeapilib
	echo "$STAPISDK_VERSION" > $STAPISDK_VERSION_FILE
fi


#unset variables that came from source $BUILDROOT/.prjconfig
#unset `set | grep "^CONFIG_" | cut -f 1 -d =`
unset `cat $BUILDROOT/.prjconfig | grep "^CONFIG_" | cut -f 1 -d =`

rm -f $PRJROOT/.maketools

