#!/bin/sh

USB_EXISTING_DIR=`mount | grep /mnt/sd | awk -F'type' '{print $1}' | awk -F'on ' '{print $2}' | tr -d ' ' | tr '\n' ':'| cut -d':' -f1`
USB_FS=`mount | grep /mnt/sd | awk -F'type' '{print $2}' | awk -F'(' '{print $1}' | tr -d ' '`
USB_DEV=`ls /dev/sd* | grep 1`
SD_DIR=`ls /dev/sd* | grep 1 | awk -F'dev/' '{print $2}'`

echo "usb_fs = $USB_FS"
echo "usb_dev = $USB_DEV"

if [ "$USB_EXISTING_DIR" == "" ]; then
	USB_DIR="/mnt/"$SD_DIR
	mkdir $USB_DIR
else 
	USB_DIR=$USB_EXISTING_DIR
fi
echo "usb_dir = $USB_DIR"

if [ "$USB_FS" != "ext2" ]; then
	echo "umount -f $USB_DIR"
	umount -l $USB_DIR
	echo "mkfs.ext2 -F $USB_DEV"
	mkfs.ext2 -F $USB_DEV 
	echo "mount $USB_DEV $USB_DIR"
	mount -o rw -t ext2 $USB_DEV $USB_DIR 
	chmod 777 $USB_DIR
	echo "ok"
fi
