#!/bin/sh

USB_DIR=`mount | grep /mnt/sd | awk -F'type' '{print $1}' | awk -F'on ' '{print $2}' | tr -d ' ' | tr '\n' ':'| cut -d':' -f1`

echo $USB_DIR

#if [ $USB_DIR -eq "" ]; then echo "Error: No USB mounted" && exit; fi

HIDDEN_DIR="$USB_DIR""/._hidden"
OPEN_DIR="$USB_DIR""/opened"

echo $HIDDEN_DIR
echo $OPEN_DIR

PASSWD=`hwconfigManager a 0 FUSION_PASSWD | grep VALUE | cut -d' ' -f2`
NEW_PASSWD=`printf "%s\n%s" $(od -x -N 100 --width=10 /dev/random | head -n 1 | sed "s/^0000000//" | sed "s/\s*//g")`

if [ -d "$HIDDEN_DIR" ] && [ -d "$OPEN_DIR" ]; then
	echo "extracted password "$PASSWD"."

	# try to mount encfs
	encfs --extpass='echo $PASSWD' $HIDDEN_DIR $OPEN_DIR
else
	echo "Warning! remove $OPEN_DIR and $HIDDEN_DIR and recreate."
	rm -rf $HIDDEN_DIR
	rm -rf $OPEN_DIR

	echo "mkdir $HIDDEN_DIR..."
	mkdir $HIDDEN_DIR
	echo "mkdir $OPEN_DIR..."
	mkdir $OPEN_DIR

	# save password
	echo $NEW_PASSWD"."
	hwconfigManager l 0 FUSION_PASSWD $NEW_PASSWD

	# first time volume creation
	printf 'x\n2\n128\n1024\n1\nYes\nYes\nNo\nNo\n0\nYes' | encfs --extpass='echo $NEW_PASSWD' $HIDDEN_DIR $OPEN_DIR;
fi

#check if we are ok
MOUNT_RESULT=`mount | grep fuse.encfs | grep $OPEN_DIR`
echo "mount result: "$MOUNT_RESULT


