#!/bin/sh

#$1 - device
#$2 - test file


# Log stdout and stderr
exec 1>/tmp/usbtest_$1.log
exec 2>&1

mount_point=/mnt/$1
test_file=$2
usb_file=$mount_point/test.hex
alive_file=/tmp/usbtest_$1.alive



#Check if there are has 10M free memory on the flash
sysmem=`/bin/df -k | grep $mount_point | (read i j k mem x; echo $mem)`
#echo "sysmem=$sysmem"
if [ 10240 -ge $sysmem ]; then
	echo "ERROR!!! Not enough memory on $mount_point"
	return 1;
fi

echo "1" > $alive_file
errors=0
while [ `cat $alive_file` -ne 0 ]; do 
	cp $test_file $usb_file
	if [ $? -ne 0 ]; then
		let errors+=1
	fi
	cmp $test_file $usb_file
	rm $usb_file
	if [ $errors -gt 50 ]; then
		echo "!!!!A lot of errors see log: /tmp/usbtest_${1}.log" >/dev/console
		break
	fi
done

echo "!!!!Ending usb test for $1" >/dev/console
if [ -e $usb_file ]; then
	rm $usb_file
fi
