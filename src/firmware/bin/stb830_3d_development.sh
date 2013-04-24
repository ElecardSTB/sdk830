#!/bin/sh

source $(dirname $0)/default_env.sh

update3Dcomponents() {
	prjmake stsdk sub=purge_apilib MODULE=sthdmi
	#Rebuild also stfrontend, to fix linking errors: undefined reference to `STFRONTEND_*'
	for i in sthdmi stfrontend; do 
		#this fixes errors like: No rule to make target `libstfrontend.a', needed by `libstapi_stpti4.a'. Stop.
		[ -e $DVD_MAKE/Modules.symvers ] || echo -n " " > $DVD_MAKE/Modules.symvers
		prjmake stsdk sub=apilib MODULE=$i
	done
}

BUILD_SCRIPT_FW=3d_firmware

UPD_CONFIG=dev
#ENABLE_VIDIMAX=1

#Comment that add to firmware pack name
SHORT_COMMENT=3D

# Rebuild STAPI module and StbMainApp with ENABLE_3DRENDERING=1
export ENABLE_3DRENDERING=1
update3Dcomponents

# -- Build firmware --------------------------------
prjmake firmware

# Rebuild STAPI module to avoid building 3D firmares afterwards
export -n ENABLE_3DRENDERING
update3Dcomponents

