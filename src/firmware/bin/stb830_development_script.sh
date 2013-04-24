#!/bin/sh

source $(dirname $0)/default_env.sh

UPD_CONFIG=dev
#ENABLE_VIDIMAX=1

BUILD_SCRIPT_FW=test
#BUILD_WITHOUT_COMPONENTS_FW=1

#Comment that add to firmware pack name
SHORT_COMMENT=clinica_nsk_init

# -- Build firmware --------------------------------
prjmake firmware
