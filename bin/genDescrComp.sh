#!/bin/bash

CUR_DIR=$(dirname $0)
source $CUR_DIR/../etc/checkEnvs.sh

COMPONENT_DIR=$BUILDROOT/comps
SIGNATURES_DIR=$COMPONENT_DIR/fwinfo/signatures
KEY_SEARCH_DIRS="$PRJROOT/src/firmware/keys/private \
				$PRJROOT/src/elecard/firmware/keys/private"

searchKey() {
	[ -z "$1" ] && return

	foundKey=
	for key_dir in $KEY_SEARCH_DIRS; do
		if [ -e $key_dir/$1.pem ]; then
			foundKey=$key_dir/$1.pem
			break;
		fi
	done
	if [ -z "$foundKey" ]; then
		echo "ERROR: Cant find \"$i.pem\". Search in: $KEY_SEARCH_DIRS"
		exit -1
	fi
}

if [ "$BUILD_SIGN_WITH" ]; then
	components=
	if [ "$BUILD_WITHOUT_COMPONENTS_FW" != "1" ]; then
		components="$components kernel rootfs"
	fi
	if [ "$BUILD_SCRIPT_FW" ]; then
		rm -f $COMPONENT_DIR/script1
		ln -s script.tgz $COMPONENT_DIR/script1
		components="$components script"
	fi
	echo_message "Sign components: \"$components\", with: \"$BUILD_SIGN_WITH\" keys"

	mkdir -p $SIGNATURES_DIR
	for i in $BUILD_SIGN_WITH; do
		searchKey $i
		echo "Found \"$i\" prvate key: $foundKey"
		mkdir -p $SIGNATURES_DIR/$i
		for j in $components; do
			echo -en "\tCalculating sign for \"$j\" component..."
			openssl dgst -sign $foundKey -out $SIGNATURES_DIR/$i/$j.sha1 -sha1 $COMPONENT_DIR/${j}1
			[ $? -ne 0 ] && exit -2
			echo "done"
		done
	done
	rm -f $COMPONENT_DIR/script1
fi

pushd $COMPONENT_DIR/fwinfo >/dev/null && tar -czf $COMPONENT_DIR/fwinfo.tgz ./* && popd >/dev/null

exit $?
