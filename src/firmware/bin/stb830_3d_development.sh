#!/bin/sh

source $(dirname $0)/default_env.sh

BUILD_SCRIPT_FW=3d_firmware

UPD_CONFIG=dev
#ENABLE_VIDIMAX=1

#Comment that add to firmware pack name
SHORT_COMMENT=3D

# Rebuild STAPI module and StbMainApp with ENABLE_3DRENDERING=1
export ENABLE_3DRENDERING=1
make -C $PRJROOT/src/apps/StbMainApp clean
make -C $STSDKROOT/stapp purge_apilib MODULE=sthdmi
#this is workaround for build sthdmi error
[ -e $DVD_MAKE/Modules.symvers ] || echo -n " " > $DVD_MAKE/Modules.symvers
make -C $STSDKROOT/stapp apilib MODULE=sthdmi

# Build 3D firmware
make -C $PRJROOT firmware

# Rebuild STAPI module to avoid building 3D firmares afterwards
export -n ENABLE_3DRENDERING
make -C $PRJROOT/src/apps/StbMainApp clean
make -C $STSDKROOT/stapp purge_apilib MODULE=sthdmi
#this is workaround for build sthdmi error
[ -e $DVD_MAKE/Modules.symvers ] || echo -n " " > $DVD_MAKE/Modules.symvers
make -C $STSDKROOT/stapp apilib MODULE=sthdmi

