#!/bin/bash

export PRJROOT=`pwd`

CONFIG=$PRJROOT/etc/configs/config_stb830_testServer

if [ ! -e $PRJROOT/setups/common.sh ]; then
	echo "ERROR"
	echo "Cant find \$PRJROOT/setups/common.sh"
	echo "\$PRJROOT=$PRJROOT"
	return
fi

source $PRJROOT/setups/common.sh

export HW_VER=stb830_st
