#!/bin/sh

source $(dirname $0)/default_env.sh


# disableConfig() - comment variable in config file
# $1 - config file
# $2 - variable name
#
disableConfig() {
	[ ! -e "$1" -o -z "$2" ] && return 255
	sed -i "s|^$2=.*|# $2 is not set|" $1
}

# setConfig() - set variable in config file
# $1 - config file
# $2 - variable name
# $3 - value, default "y"
#
setConfig() {
	[ ! -e "$1" -o -z "$2" ] && return 255
	local value=${3:-y}

	if grep -E "^# $2 is not set" $1 &>/dev/null; then
		sed -i "s|^# $2 is not set|$2=$value|" $1
	elif grep -E "^$2=.*" $1 &>/dev/null; then
		sed -i "s|^$2=.*|$2=$value|" $1
	else
		echo "$2=$value" >> $1;
	fi
}

# addAfter() {
# 
# }

#Return orginal config for rootfs
returnOrigConfig() {
	[ ! -e $TMP_ORIG_CONFIG ] && return 255
	echo "Return original buildroot configuration!"
	cp -f $TMP_ORIG_CONFIG $BUILDROOT_ROOTFS_CFG
	rm $TMP_ORIG_CONFIG
}

trap "returnOrigConfig" SIGHUP SIGINT SIGTERM


SHORT_COMMENT=vlp_nand
BUILDROOT_ROOTFS_CFG=$BUILDROOT/packages/buildroot/output_rootfs/.config

#Reserve original config for rootfs
TMP_ORIG_CONFIG=`mktemp /tmp/.config-XXXXXX`
cp -f $BUILDROOT_ROOTFS_CFG $TMP_ORIG_CONFIG

#Seting configs to generate jffs2 image for very large page nand
disableConfig	$BUILDROOT_ROOTFS_CFG	BR2_TARGET_ROOTFS_JFFS2_NANDFLASH_2K_128K
setConfig		$BUILDROOT_ROOTFS_CFG	BR2_TARGET_ROOTFS_JFFS2_CUSTOM
setConfig		$BUILDROOT_ROOTFS_CFG	BR2_TARGET_ROOTFS_JFFS2_CUSTOM_PAGESIZE		0x1000
setConfig		$BUILDROOT_ROOTFS_CFG	BR2_TARGET_ROOTFS_JFFS2_CUSTOM_EBSIZE		0x40000
setConfig		$BUILDROOT_ROOTFS_CFG	BR2_TARGET_ROOTFS_JFFS2_PAGESIZE			0x1000
setConfig		$BUILDROOT_ROOTFS_CFG	BR2_TARGET_ROOTFS_JFFS2_EBSIZE				0x40000

# -- Build firmware --------------------------------
prjmake firmware

returnOrigConfig
