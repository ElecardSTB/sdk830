#!/bin/sh

source $(dirname $0)/default_env.sh

UPD_CONFIG=dev
#ENABLE_VIDIMAX=1

make -C $PRJROOT firmware

