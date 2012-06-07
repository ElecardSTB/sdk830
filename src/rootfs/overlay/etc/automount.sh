#!/bin/sh

# Try to mount USB storage devices with type vfat - usually a USB memory stick,
# if that fails then try mounting with type ext3 or ext2 - usually a hard disk.

# Location of all auto-mounted devices
mount_base="/mnt"

# Empty or ',rw' for read/write, ",ro" for read only
# Fixme: read only should probably be the default.
RDWR=""

# Log stdout and stderr
exec 1>/tmp/automount.log
#exec 1>/dev/console
exec 2>&1
#set -x

unmount()
{
	mountpoint=$1
	#mountpoint="$(echo $1 | tr "[:lower:]" "[:upper:]" | sed 's/SD\(.\)/Disk \1/' | sed 's/ \(.\)\(.\)/ \1 Partition \2/' )"
	
	if [ -e "${mount_base}/${mountpoint}" -a -n "${mountpoint}" ]
	then
		umount -f "${mount_base}/${mountpoint}"
		rmdir "${mount_base}/${mountpoint}"

		# Unmount succeeded
		echo "==> Unmounted $MDEV (${mount_base}/${mountpoint})" >/dev/console
		exit 0
	fi
	exit 1
}

if [ "$ACTION" = remove ]
then

	for fs in vfat ext3 ext2
	do
		if [ -n "$(mount -t $fs | grep "$MDEV ")" ]
		then
			echo "trying unmount $MDEV $fs"
			# Execute filesystem specific unmount script if present
			# Fixme: shouldn't "${mount_base}/${mountpoint}" be passed to the unmount script ?
			[ -x /sbin/umount.${fs} ] && /sbin/umount.${fs}

			unmount $MDEV
			exit $?
		fi
	done

	if [ -n "$(mount -t fuseblk | grep $MDEV)" ]
	then
		echo "trying unmount $MDEV ntfs"

		unmount $MDEV
		exit $?
	fi
else
	#mountpoint="$(echo ${MDEV} | tr "[:lower:]" "[:upper:]" | sed 's/SD\(.\)/Disk \1/' | sed 's/ \(.\)\(.\)/ \1 Partition \2/' )"
	mountpoint=$MDEV

	if [ -n "${mountpoint}" ]
	then
		if [ -n "$(echo $MDEV | grep "sd[a-z]$")" -a "$(ls /dev/$MDEV* | grep -c $MDEV)" != "1" ]; then
			echo "$MDEV has partitions, so skip it"
			exit 0
		fi
		
		echo "$MDEV create ${mount_base}/${mountpoint}"
		mkdir -p "${mount_base}/${mountpoint}"

		for fs in vfat ext3 ext2
		do
			echo "try ${MDEV} ${fs} on ${mount_base}/${mountpoint}"
			if [ $fs = vfat ]; then
[% IF CONFIG_TESTSERVER_ENABLE -%]
				MOUNT_OPTS=",codepage=866,iocharset=utf8,errors=continue"
[% ELSE -%]
				MOUNT_OPTS=",codepage=866,iocharset=utf8,errors=remount-ro"
[% END -%]
			else
				MOUNT_OPTS=
			fi

			if mount -t $fs -o noatime${RDWR}${MOUNT_OPTS} $MDEV "${mount_base}/${mountpoint}"
			then
				# Execute filesystem specific mount script if present
				[ -x /sbin/mount.${fs} ] && /sbin/mount.${fs} "${mount_base}/${mountpoint}"
				if [ $fs = vfat ]; then
					echo "Check fat file system $MDEV"
#					dosfsck -a ${MDEV}
				fi

				# Mount succeeded
				echo "==> Mounted $MDEV on ${mount_base}/${mountpoint}" >/dev/console
				echo "done ${fs}"

				exit 0
			else
				echo "Not mounted, return=$?"
	#			ls -la "${mount_base}/${mountpoint}" >/dev/console
			fi
		done

		echo "try ${MDEV} ntfs on ${mount_base}/${mountpoint}"
		if ntfs-3g -o noatime${RDWR} $MDEV "${mount_base}/${mountpoint}"
		then
			# Mount succeeded
			echo "==> Mounted $MDEV on ${mount_base}/${mountpoint}" >/dev/console
			echo "done ntfs"

			exit 0
		else
			echo "Not mounted, return=$?"
#			ls -la "${mount_base}/${mountpoint}" >/dev/console
		fi

		umount -f "${mount_base}/${mountpoint}"
		# Mount attempts failed... remove mount directory

		rmdir "${mount_base}/${mountpoint}"
		echo "remove ${mount_base}/${mountpoint}"
	else
		echo "cant detect mountpoint"
	fi

fi
