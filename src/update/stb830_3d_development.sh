#!/bin/sh

source $(dirname $0)/../../etc/checkEnvs.sh
source $PRJROOT/src/update/build_post.sh

BUILD_SCRIPT_FW=3d_firmware

UPD_CONFIG=dev
#ENABLE_VIDIMAX=1

#Comment that add to firmware pack name
SHORT_COMMENT=3D

export ENABLE_3DRENDERING=1

#rebuild STAPI module with difine ENABLE_3DRENDERING=1
make -C /opt/STM/stapisdk-35.1/stapp purge_apilib MODULE=sthdmi

if  make -C /opt/STM/stapisdk-35.1/stapp apilib MODULE=sthdmi && 
    make -C $PRJROOT firmware
then
    #rebuild STAPI module to avoid building 3D firmares afterwards.
    export -n ENABLE_3DRENDERING
    
    make -C /opt/STM/stapisdk-35.1/stapp purge_apilib MODULE=sthdmi > /dev/null
    make -C /opt/STM/stapisdk-35.1/stapp apilib MODULE=sthdmi > /dev/null
fi
export -n ENABLE_3DRENDERING
