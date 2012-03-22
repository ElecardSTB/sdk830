#!/bin/sh

if [ -n "`cat /proc/cmdline | grep burn_flash`" ]; then
	some_update=""
	echo "Starting flashing..."
	if [ -e /firmware/u-boot.bin ]; then
		echo "    flash u-boot... "
		flash_eraseall /dev/mtd0
		nandwrite /dev/mtd0 /firmware/u-boot.bin -p
		some_update="u-boot "
		echo "done."
	fi
	if [ -e /firmware/envs ]; then
		echo "    flash u-boot environment... "
		flash_eraseall /dev/mtd1
		nandwrite /dev/mtd1 /firmware/envs -p
		some_update="${some_update}u-boot_envs "
		echo "done."
	fi
	if [ -e /firmware/kernel0 ]; then
		echo "    flash kernel0... "
		flash_eraseall /dev/mtd2
		nandwrite /dev/mtd2 /firmware/kernel0 -p
		some_update="${some_update}kernel0 "
		echo "done."
	fi
	if [ -e /firmware/kernel1 ]; then
		echo "    flash kernel1... "
		flash_eraseall /dev/mtd3
		nandwrite /dev/mtd3 /firmware/kernel1 -p
		echo "done."
		some_update="${some_update}kernel1 "
	fi
	if [ -e /firmware/rootfs1 ]; then
		echo "    flash main rootfs... "
		flash_eraseall /dev/mtd4
		nandwrite /dev/mtd4 /firmware/rootfs1 -p
		echo "done."
		some_update="${some_update}rootfs1 "
	fi
	if [ -n "$some_update" ]; then
		echo "flashing done for: $some_update"
		echo "***PLESAE REBOOT***"
	else
		echo "nothing to flash."
	fi
fi


exit $?
