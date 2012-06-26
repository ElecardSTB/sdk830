#!/bin/sh

source $(dirname $0)/../../etc/checkEnvs.sh
source $PRJROOT/src/update/build_post.sh

UPD_CONFIG=dev
#ENABLE_VIDIMAX=1

make -C $PRJROOT firmware

