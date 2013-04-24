#!/bin/sh

source `dirname ${BASH_SOURCE[0]}`/../../../etc/checkEnvs.sh

#Comment that add to firmware pack name
export SHORT_COMMENT=${SHORT_COMMENT:-$1}

#default environment
export ENABLE_VIDIMAX BUILD_SCRIPT_FW BUILD_WITHOUT_COMPONENTS_FW BUILD_SIGN_WITH BUILD_ADD_KEYS_TO_FW
export ENABLE_PPP=1
export UPD_CONFIG=dev
