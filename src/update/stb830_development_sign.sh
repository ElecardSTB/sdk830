#!/bin/sh

source $(dirname $0)/../../etc/checkEnvs.sh


UPD_CONFIG=dev
#ENABLE_VIDIMAX=1

##BUILD_SCRIPT_FW - script component define
##BUILD_WITHOUT_COMPONENTS_FW - disabling rootfs, kernel components
#BUILD_SCRIPT_FW=test
#BUILD_WITHOUT_COMPONENTS_FW=1

##BUILD_SIGN_WITH - private key with which firmware will be signed
##BUILD_ADD_KEYS_TO_FW - open keys that will be puted into firmware
BUILD_SIGN_WITH=elecard
BUILD_ADD_KEYS_TO_FW=elecard


#Comment that add to firmware pack name
#SHORT_COMMENT="something"

. $(dirname $0)/build_post.sh
