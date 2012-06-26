#!/bin/sh

source $(dirname $0)/../../etc/checkEnvs.sh
source $PRJROOT/src/update/build_post.sh

UPD_CONFIG=dev
#ENABLE_VIDIMAX=1

#BUILD_SCRIPT_FW=clinika_updateurl
BUILD_SCRIPT_FW=test
BUILD_WITHOUT_COMPONENTS_FW=1

make -C $PRJROOT firmware
