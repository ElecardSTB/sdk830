#!/bin/bash


addToFWNAME() {
	FWNAME=${FWNAME}${1:+.$1}
}

printEnv() {
	if [ -n "${!1}" ]; then
		echo "$1=${!1}" >> ${descFile}
	else
		echo "#$1 not defined" >> ${descFile}
	fi
}

getLastCommit() {
	STB830_vcs_get_version "$@"
	getBranch $1
	Return_Val=($Return_Val)$Return_Val2
}

CUR_DIR=$(dirname $0)
SRC_FIRMWARE_DIR=$PRJROOT/src/firmware
OUTDIR=$BUILDROOT/firmware
COMPDIR=$BUILDROOT/comps


source $CUR_DIR/../etc/checkEnvs.sh
source $PRJROOT/etc/vcs.sh
pushd $PRJROOT 1>/dev/null

echo_message "Generate firmware description:"

get_ver="git svn info"
if ! $get_ver &> /dev/null; then
	get_ver="svn info"
	if ! $get_ver &> /dev/null; then
		get_ver="echo Last Changed Rev: 0"
	fi
fi

if [ ! "$UPD_CONFIG" ]; then
	UPD_CONFIG=dev
#	UPD_CONFIG=rel
fi

upd_config_rev=0
if [ "$UPD_CONFIG" = "dev" ]; then
	ALWAYSUPDATE=1
	if [ ! -e $SRC_FIRMWARE_DIR/.development_revision ]; then
		echo "1" > $SRC_FIRMWARE_DIR/.development_revision
	fi
	upd_config_rev=`cat $SRC_FIRMWARE_DIR/.development_revision`
	if [ -n "$INCREMENT_REVISION" ]; then
		echo $(($upd_config_rev+1)) > $SRC_FIRMWARE_DIR/.development_revision
	fi
else if [ "$UPD_CONFIG" = "rel" ]; then
	ALWAYSUPDATE=0
	upd_config_rev=`cat $SRC_FIRMWARE_DIR/.release_revision`
else
	echo "Firmware configuration setted not properly UPD_CONFIG=\"$UPD_CONFIG\", should be dev/rel"
	popd
	exit 1
fi
fi
UPD_CONFIG_REV=`printf %04d $upd_config_rev`
REVISION=${UPD_CONFIG}${UPD_CONFIG_REV}
#Why here we define this. See $PRJROOT/src/elecard/apps/COMMONLib/include/common.h[94]: #define STB830_SYSID_INCOMPATIBLE_PART	0x00020090
SYSID=02-001-1-00-00.01
DATE=`date +'%Y%m%d%H%M'`
DATE_READABLE=`date +'%Y-%m-%d %H:%M:%S'`
HOSTNAME=`uname -n`
SYSREV_PKG=${DATE#??}

KERNELVER=0
ROOTFSVER=0
#USERFSVER=0
FIRMWAREVER=0

echo "Components last commit:"
STB830_vcs_get_version src/linux src/initramfs src/elecard/updater
KERNELVER=$Return_Val
KERNELVER_GIT=$Return_Val2
echo " KERNELVER_GIT=$KERNELVER_GIT"

STB830_vcs_get_version src/rootfs src/apps src/modules src/elecard/stapisdk src/elecard/updater
ROOTFSVER=$Return_Val
ROOTFSVER_GIT=$Return_Val2
echo " ROOTFSVER_GIT=$ROOTFSVER_GIT"


echo "Repositories last commit:"
STB830_vcs_get_version ./
FIRMWAREVER=$Return_Val
getBranch ./
SDK830_GIT=($Return_Val)$Return_Val2
echo " sdk_830=$SDK830_GIT"

STB830_vcs_get_version src/apps
getBranch src/apps
ELECARD_APPS_GIT=($Return_Val)$Return_Val2
echo " elecard-apps(src/apps)=$ELECARD_APPS_GIT"

if [ -z "$STB830_SDK" ]; then
	STB830_vcs_get_version src/elecard
	getBranch src/elecard
	PRIVATE_SDK830_GIT=($Return_Val)$Return_Val2
	echo " sdk830-private(src/elecard)=$PRIVATE_SDK830_GIT"

#Fix it when repo will be separated
	STB830_vcs_get_version src/elecard/apps/COMMONLib src/elecard/apps/NETLib src/elecard/updater/firmwareCommon src/elecard/updater/hwconfigManager
	getBranch src/elecard/apps/COMMONLib
	PRIVATE_ELECARD_APPS_GIT=($Return_Val)$Return_Val2
	echo " private-elecard-apps(src/elecard/apps)=$PRIVATE_ELECARD_APPS_GIT"
fi

#getBranch ./
#BRANCH=$Return_Val
#LANG=ENG
LANG=

COMPONENTS=${BUILD_SCRIPT_FW:+script}
SIGN=${BUILD_SIGN_WITH:+sign}
# Comps effect on firmware pack size, so skip adding "comps" to efp name.
# if [ "$BUILD_WITHOUT_COMPONENTS_FW" != "1" ]; then
# 	COMPONENTS=${COMPONENTS:+${COMPONENTS}_}comps
# fi

#This file uses as dependence in $PRJROOT/src/initramfs/Makefile
CUR_PUBLIC_KEYS_FILELIST=$COMPDIR/.pubKeysList
if [ "$BUILD_ADD_KEYS_TO_FW" != "`cat $CUR_PUBLIC_KEYS_FILELIST`" ]; then
#Needs to rebuild initramfs. Refresh file with list of public keys.
	echo -n "$BUILD_ADD_KEYS_TO_FW" > $CUR_PUBLIC_KEYS_FILELIST
fi


#FWNAME=STB830.$UPD_CONFIG.rev$UPD_CONFIG_REV.$DATE.${BRANCH}svn${FIRMWAREVER}.${LANG}${HOSTNAME}${COMPONENTS}${COMMENT}
FWNAME=STB830
addToFWNAME $REVISION
addToFWNAME $DATE
#addToFWNAME $BRANCH
#addToFWNAME $FIRMWAREVER
addToFWNAME $LANG
addToFWNAME $HOSTNAME
addToFWNAME $COMPONENTS
addToFWNAME $SIGN
addToFWNAME $SHORT_COMMENT


#create efp configuration file
export ALWAYSUPDATE SYSID SYSREV_PKG FWNAME OUTDIR COMPDIR KERNELVER ROOTFSVER USERFSVER BUILD_SCRIPT_FW BUILD_WITHOUT_COMPONENTS_FW
$PRJROOT/bin/prjfilter $PRJROOT/etc/stb830.conf.in $COMPDIR/stb830_efp.conf


# Create description file
rm -rf $COMPDIR/fwinfo $COMPDIR/firmwareDesc
mkdir $COMPDIR/fwinfo
descFile=$COMPDIR/fwinfo/firmwareDesc
echo "#Elecard STB Firmware Update Pack" > ${descFile}
echo "#Firmware pack name:       " $FWNAME.efp >> ${descFile}
echo "#Firmware Pack Ver(date):  " $SYSREV_PKG >> ${descFile}
echo "#System id:                " $SYSID >> ${descFile}
echo "#Build configuration:      " $UPD_CONFIG >> ${descFile}
echo "#Always Update Flag:       " $ALWAYSUPDATE >> ${descFile}

echo "#STAPISDK version:         " $STAPISDK_VERSION >> ${descFile}
echo "#Kernel version:           " $FULL_LINUX_VERSION >> ${descFile}
# echo "#Build Host: "              $HOSTNAME >> ${descFile}
# echo "#Output Standard:"        $STANDARD >> ${descFile}
# echo "#Default System Serial:"  $SYSSER >> ${descFile}
# echo "#Default MAC Address:"    $SYSMAC >> ${descFile}
echo -e "\n" >> ${descFile}
printEnv HOSTNAME
printEnv REVISION
printEnv DATE_READABLE
printEnv STB830_SDK
printEnv BUILD_SCRIPT_FW
printEnv BUILD_WITHOUT_COMPONENTS_FW

if [ "$BUILD_WITHOUT_COMPONENTS_FW" != "1" ]; then
	echo -e "\n#Components versions (gos to efp header):" >> ${descFile}
	printEnv KERNELVER
	printEnv ROOTFSVER
#	printEnv USERFSVER
	echo -e "#Components time and hash:" >> ${descFile}
	printEnv KERNELVER_GIT
	printEnv ROOTFSVER_GIT
	echo -e "\n#Branch, time and hash of repositories:" >> ${descFile}
	printEnv SDK830_GIT
	printEnv ELECARD_APPS_GIT
	if [ -z "$STB830_SDK" ]; then
		printEnv PRIVATE_SDK830_GIT
		printEnv PRIVATE_ELECARD_APPS_GIT
	fi

	source $BUILDROOT/.prjconfig
	echo -e "\n#MainApp:" >> ${descFile}
	printEnv CONFIG_ELECD_ENABLE
	printEnv CONFIG_TESTSERVER_ENABLE
	printEnv CONFIG_TESTTOOL_ENABLE

	if [ -n "$CONFIG_ELECD_ENABLE" ]; then
		echo -e "\n#StbMainApp defines:" >> ${descFile}
		printEnv ENABLE_VIDIMAX
		printEnv ENABLE_VERIMATRIX
		printEnv ENABLE_SECUREMEDIA
	fi

	echo -e "\n#Public keys included into rootfs:" >> ${descFile}
	printEnv BUILD_ADD_KEYS_TO_FW
	# echo "#Signatures:"             `ls $UPDATER_DIR/certificates` >> ${descFile}
else
	echo -e "\n#Branch, time and hash of repositories:" >> ${descFile}
	printEnv SDK830_GIT
fi

echo -en "\n\n" >> ${descFile}
echo -e "#Components signed with:" >> ${descFile}
printEnv BUILD_SIGN_WITH


popd 1>/dev/null
exit 0
