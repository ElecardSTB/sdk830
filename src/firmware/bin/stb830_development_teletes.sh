#!/bin/sh

source $(dirname $0)/default_env.sh

UPD_CONFIG=dev

BUILD_SCRIPT_FW=teletes
#BUILD_WITHOUT_COMPONENTS_FW=1

#Comment that add to firmware pack name
SHORT_COMMENT=teletes_updateaddr

export ENABLE_TELETES=1
make -C $PRJROOT/src/apps/StbMainApp clean
make -C $PRJROOT firmware

#export -n ENABLE_TELETES
make -C $PRJROOT/src/apps/StbMainApp clean
