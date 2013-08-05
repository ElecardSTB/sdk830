#!/bin/sh

source $(dirname $0)/default_env.sh

UPD_CONFIG=dev
SHORT_COMMENT=pvr.teletext

export ENABLE_PVR=1
export ENABLE_TELETEXT=1

rm -rf $PRJROOT/src/elecard/apps/elcd/src/objs

# -- Build firmware --------------------------------
prjmake firmware

rm -rf $PRJROOT/src/elecard/apps/elcd/src/objs
