#!/bin/sh

source $(dirname $0)/default_env.sh

export UPD_CONFIG=dev
#ENABLE_VIDIMAX=1

export SHORT_COMMENT=resetSettings
export BUILD_SCRIPT_FW=resetSettings
export BUILD_WITHOUT_COMPONENTS_FW=1

# -- Build firmware --------------------------------
prjmake firmware
