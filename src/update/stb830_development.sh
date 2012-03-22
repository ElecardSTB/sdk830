#!/bin/sh

source $(dirname $0)/../../etc/checkEnvs.sh


UPD_CONFIG=dev
#ENABLE_VIDIMAX=1

#Comment that add to firmware pack name
SHORT_COMMENT=$1

export UPD_CONFIG ENABLE_VIDIMAX BUILD_SCRIPT_FW BUILD_WITHOUT_COMPONENTS_FW SHORT_COMMENT

make -C $PRJROOT firmware

