#!/bin/sh

source $(dirname $0)/default_env.sh

UPD_CONFIG=dev
#ENABLE_VIDIMAX=1

#BUILD_SCRIPT_FW=clinika_updateurl
BUILD_SCRIPT_FW=test
BUILD_WITHOUT_COMPONENTS_FW=1

# -- Build firmware --------------------------------
prjmake firmware
