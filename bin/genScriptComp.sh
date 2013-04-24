#!/bin/bash

[ -z "$BUILD_SCRIPT_FW" ] && exit 0

CUR_DIR=$(dirname $0)
source $CUR_DIR/../etc/checkEnvs.sh

COMPONENT_DIR=$BUILDROOT/comps
SCRIPT_COMP_SEARCH_DIRS="$PRJROOT/src/firmware/scriptComponents \
						$PRJROOT/src/elecard/firmware/scriptComponents"

SCRIPT_COMP_SEARCH_NEW_DIRS="$PRJROOT/src/firmware/src \
						$PRJROOT/src/elecard/firmware/src"

searchScriptDir() {
	[ -z "$1" ] && return

	foundScriptDir=
	for dir in `find $SCRIPT_COMP_SEARCH_NEW_DIRS -maxdepth 1 -type d -name $1`; do
		if [ -d "$dir/script" ]; then
			foundScriptDir=$dir/script
			return 0;
		fi
	done
	#old paths
	foundScriptDir=`find $SCRIPT_COMP_SEARCH_DIRS -maxdepth 1 -type d -name $1 | head -n 1`
	if [ -z "$foundScriptDir" ]; then
		echo "ERROR: Cant find \"$BUILD_SCRIPT_FW\" script folder. Search in: $SCRIPT_COMP_SEARCH_NEW_DIRS $SCRIPT_COMP_SEARCH_DIRS"
		exit -1
	fi
}

echo_message "Creating script component:"
rm -f $COMPONENT_DIR/script.tgz
searchScriptDir $BUILD_SCRIPT_FW
echo "Found \"$BUILD_SCRIPT_FW\" script folder: $foundScriptDir"
echo -n "Creating archive... "
pushd $foundScriptDir >/dev/null && tar -czf $COMPONENT_DIR/script.tgz ./* && popd >/dev/null
ret=$?
[ $ret -eq 0 ] && echo "done" || echo "error"

exit $ret
