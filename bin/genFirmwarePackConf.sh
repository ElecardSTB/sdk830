#!/bin/bash


addToFWNAME() {
	FWNAME=${FWNAME}${1:+.$1}
}

getLastCommit() {
	STB830_vcs_get_version "$@"
	getBranch $1
	Return_Val=($Return_Val)$Return_Val2
}

CUR_DIR=$(dirname $0)
UPDATE_DIR=$PRJROOT/src/update
OUTDIR=$BUILDROOT/firmware
COMPDIR=$BUILDROOT/comps


source $CUR_DIR/../etc/checkEnvs.sh
source $PRJROOT/etc/vcs.sh
pushd $PRJROOT 1>/dev/null

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
	if [ ! -e $UPDATE_DIR/.development_revision ]; then
		echo "1" > $UPDATE_DIR/.development_revision
	fi
	upd_config_rev=`cat $UPDATE_DIR/.development_revision`
	if [ -n "$INCREMENT_REVISION" ]; then
		echo $(($upd_config_rev+1)) > $UPDATE_DIR/.development_revision
	fi
else if [ "$UPD_CONFIG" = "rel" ]; then
	ALWAYSUPDATE=0
	upd_config_rev=`cat $UPDATE_DIR/.release_revision`
else
	echo "Firmware configuration setted not properly UPD_CONFIG=\"$UPD_CONFIG\", should be dev/rel"
	popd
	exit 1
fi
fi
UPD_CONFIG_REV=`printf %04d $upd_config_rev`
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

getBranch ./
BRANCH=$Return_Val
#LANG=ENG
LANG=

if [ -n "$BUILD_SCRIPT_FW" ]; then
	COMPONENTS=script
fi
# Comps effect on firmware pack size, so skip adding "comps" to efp name.
# if [ "$BUILD_WITHOUT_COMPONENTS_FW" != "1" ]; then
# 	COMPONENTS=${COMPONENTS:+${COMPONENTS}_}comps
# fi


#FWNAME=STB830.$UPD_CONFIG.rev$UPD_CONFIG_REV.$DATE.${BRANCH}svn${FIRMWAREVER}.${LANG}${HOSTNAME}${COMPONENTS}${COMMENT}
FWNAME=STB830
addToFWNAME ${UPD_CONFIG}${UPD_CONFIG_REV}
addToFWNAME $DATE
#addToFWNAME $BRANCH
#addToFWNAME $FIRMWAREVER
addToFWNAME $LANG
addToFWNAME $HOSTNAME
addToFWNAME $COMPONENTS
addToFWNAME $SHORT_COMMENT


#create efp configuration file
export ALWAYSUPDATE SYSID SYSREV_PKG FWNAME OUTDIR COMPDIR KERNELVER ROOTFSVER USERFSVER BUILD_SCRIPT_FW BUILD_WITHOUT_COMPONENTS_FW
$PRJROOT/bin/prjfilter $PRJROOT/etc/stb830.conf.in $COMPDIR/stb830_efp.conf

printEnv() {
	if [ -n "${!1}" ]; then
		echo "$1=${!1}" >> ${descFile}
	else
		echo "#$1 not defined" >> ${descFile}
	fi
}

# Create description file
descFile=$COMPDIR/firmwareDesc
echo "#Elecard STB Firmware Update Pack" > ${descFile}
echo "#Firmware pack name:       " $FWNAME.efp >> ${descFile}
echo "#Firmware Pack Ver(date):  " $SYSREV_PKG >> ${descFile}
echo "#System id:                " $SYSID >> ${descFile}
echo "#Build configuration:      " $UPD_CONFIG >> ${descFile}
echo "#Always Update Flag:       " $ALWAYSUPDATE >> ${descFile}

echo "#STAPISDK version:         " $STAPISDK_VERSION >> ${descFile}
# echo "#Build Host: "              $HOSTNAME >> ${descFile}
# echo "#Output Standard:"        $STANDARD >> ${descFile}
# echo "#Default System Serial:"  $SYSSER >> ${descFile}
# echo "#Default MAC Address:"    $SYSMAC >> ${descFile}
echo -e "\n" >> ${descFile}
printEnv HOSTNAME
printEnv DATE_READABLE
printEnv STB830_SDK

if [ -n "$BUILD_SCRIPT_FW" ]; then
	echo -e "\n#Script:" >> ${descFile}
	printEnv BUILD_SCRIPT_FW
fi

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

	echo -e "\n#Defines:" >> ${descFile}
	printEnv ENABLE_VIDIMAX
	# echo "#Signatures:"             `ls $UPDATER_DIR/certificates` >> ${descFile}
	#echo "ENABLE_VERIMATRIX="         $ENABLE_VERIMATRIX >> ${descFile}
	#echo "ENABLE_SECUREMEDIA="        $ENABLE_SECUREMEDIA >> ${descFile}
fi


popd 1>/dev/null
exit 0
