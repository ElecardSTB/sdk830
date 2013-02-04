#!/bin/sh

# Try to mount USB storage devices with type vfat - usually a USB memory stick,
# if that fails then try mounting with type ext3 or ext2 - usually a hard disk.

# Location of all auto-mounted devices
mount_base="/mnt"

# Empty or ',rw' for read/write, ",ro" for read only
# Fixme: read only should probably be the default.
RDWR=""

# Log stdout and stderr
exec 1>/tmp/automount.log 2>&1
#exec 1>/dev/console 2>&1
#set -x

unmount() {
	mountpoint=$1

	if [ -e "$mountpoint" ]; then
		umount -f "$mountpoint"
		rmdir "$mountpoint"

		# Unmount succeeded
		echo "==> Unmounted $MDEV ($mountpoint)" | tee /dev/console
		exit 0
	fi
	exit 1
}

isMounted() {
	grep "^$MDEV [^ ]* $1" /proc/mounts &>/dev/null && return 0 || return 1
}

if [ -z "$MDEV" ]; then
	echo "ERROR! Cant detect mount device."
fi
mountpoint=$mount_base/$MDEV

if [ "$ACTION" = remove ]; then

	if ! isMounted; then
		exit 0
	fi
	for fs in vfat ext3 ext2 fuseblk; do
		if isMounted $fs; then
			echo "trying unmount $MDEV $fs"
			# Execute filesystem specific unmount script if present
			# FIXME: If need to pass $mountpoint to the unmount script ?
			[ -x /sbin/umount.$fs ] && /sbin/umount.$fs

			unmount $mountpoint
			exit $?
		fi
	done
else
	if echo $MDEV | grep "sd[a-z]$" &>/dev/null; then
		if ls /dev/$MDEV[0-9]* &>/dev/null; then
			echo "$MDEV has partitions, so don't try to mount it"
			exit 0
		fi
	fi
	if isMounted; then
		echo "$MDEV has already mounted"
		exit 0
	fi

	echo "$MDEV create $mountpoint"
	mkdir -p "$mountpoint"

	for fs in vfat ext3 ext2; do
		echo "try $MDEV $fs on $mountpoint"
		MOUNT_OPTS=
		if [ $fs = vfat ]; then
[% IF CONFIG_TESTSERVER_ENABLE -%]
			MOUNT_OPTS=",codepage=866,iocharset=utf8,errors=continue"
[% ELSE -%]
			MOUNT_OPTS=",codepage=866,iocharset=utf8,errors=remount-ro"
[% END -%]
		fi

		if mount -t $fs -o noatime${RDWR}${MOUNT_OPTS} $MDEV $mountpoint; then
			# Execute filesystem specific mount script if present
			[ -x /sbin/mount.$fs ] && /sbin/mount.$fs $mountpoint
			if [ $fs = vfat ]; then
				echo "Check fat file system $MDEV"
#					dosfsck -a $MDEV
			fi

			# Mount succeeded
			echo "==> Mounted $MDEV on $mountpoint" | tee /dev/console
			echo "done $fs"

			exit 0
		else
			echo "Not mounted, return=$?"
#			ls -la "$mountpoint" | tee /dev/console
		fi
	done

	echo "try $MDEV ntfs on $mountpoint"
	if ntfs-3g -o noatime${RDWR} $MDEV $mountpoint; then
		# Mount succeeded
		echo "==> Mounted $MDEV on $mountpoint" | tee /dev/console
		echo "done ntfs"

		exit 0
	else
		echo "Not mounted, return=$?"
#		ls -la "$mountpoint" | tee /dev/console
	fi

	umount -f $mountpoint
	# Mount attempts failed... remove mount directory

	rmdir $mountpoint
	echo "remove $mountpoint"

fi
