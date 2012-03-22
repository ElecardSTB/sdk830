#!/bin/sh

#Check if there are has 10M free memory in the system
#sysmem=`free | grep Mem | (read i j k mem x; echo $mem )`
#echo "sysmem=$sysmem"
#if [ 1024 -ge $sysmem ]; then
#	echo "ERROR!!! Not enough memory"
#	return 1;
#fi


#Create 10M test file
#cd /tmp
cd /var/etc
if [ -e ./testFile ]; then
  rm ./testFile
fi
dd if=/dev/urandom of=./testFile bs=1024 count=1024
#dd if=/dev/urandom of=./testFile_t bs=1024 count=1024
#for i in `seq 1 10`; do
#	cat ./testFile_t >> ./testFile
#done
#rm ./testFile_t

#Run test for every mount point
mount | grep /mnt/sd | \
while read dev i point other; do
	echo "Run test for $dev"
#	usbTest.sh $dev /tmp/testFile &
	touch /mnt/$dev/test.hex 2>/dev/null
	rm -f /mnt/$dev/test.hex 2>/dev/null
#	if [ $? -ne 0 ]; then
		mount -o remount,rw /mnt/$dev
#	fi
	usbtest /mnt/$dev /var/etc/testFile &
done

