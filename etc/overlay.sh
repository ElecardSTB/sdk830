#!/bin/bash

# This function copies or removes file tree from $1 to $2
# $3 copy/remove
# $4 verbose
function overlay() {
	local overlay_dirs=`find $1/* -type d | sort`
	local overlay_files=`find $1/* -type f -o -type l`
	local D
	local F
	if [ "$3" = "1" ]; then
		for i in $overlay_dirs; do
			D=${i#$1/}
			[ "$4" = "1" ] 2>/dev/null && echo "Create directory $2/$D"
			mkdir "$2/$D" 2>/dev/null
		done
	fi
	for i in $overlay_files; do
		F=${i#$1/}
		if [ "$3" = "1" ]; then
			[ "$4" = "1" ] 2>/dev/null && echo "Add overlay file $2/$F"
			cp -Pf "$i" "$2/$F"
		else
			[ "$4" = "1" ] 2>/dev/null && echo "Remove overlay file $2/$F"
			rm -f       "$2/$F"
		fi
	done
	if [ "$3" != "1" ]; then
		for i in $overlay_dirs; do
			D=${i#$1/}
			rmdir "$2/$D" 2>/dev/null && [ "$4" = "1" ] 2>/dev/null && echo "Removed empty directory $2/$D"
		done
	fi
}
