#!/bin/sh

USB_DIR=`mount | grep /mnt/sd | awk -F'type' '{print $1}' | awk -F'on ' '{print $2}' | tr -d ' ' | tr '\n' ':'| cut -d':' -f1`

fusermount -u "$USB_DIR""/opened"
