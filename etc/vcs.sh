#!/bin/sh


detectVCS() {
	Return_Val="echo 0"
	if [ ! -d $1 ]; then
		return 1
	fi
	pushd $1 1>/dev/null || return 1
#	if git svn info &> /dev/null; then
#		Return_Val="git log -n 1 --pretty='%b' ./ | grep 'git-svn-id:' | cut -f 2 -d @ | cut -f 1 -d ' '"
#	else
#		#Return_Val="svn info"
#		if svn info &> /dev/null; then
#			Return_Val="svn info | grep 'Last Changed Rev:' | cut -f 4 -d ' '"
#		fi
#	fi
	popd 1>/dev/null
}

getLastModificationVersion() {
	vcs_cmd="$1"
	shift
#	cvs_cmd="date -u -d \"`git log -n 1 --pretty='%ai'`\" +%y.%m.%d_%H.%M"
	time_stamp=0
	Return_Val=`date -u -d @$time_stamp +%y.%m.%d_%H.%M`
#	echo $*
#	pwd
	for i in $*; do
		if [ ! -d $i ]; then continue; fi
		pushd $i 1>/dev/null || continue
#		echo $i
		tmp=`git log -n 1 --pretty='%at' ./`
		tmp=${tmp:-1}
#		echo $tmp
		git_hash=`git log -n 1 --pretty='%h' ./`
		if [ $time_stamp -lt $tmp ]; then
			time_stamp=$tmp
			Return_Val=`date -u -d @$tmp +%y%m%d%H%M`
			Return_Val2=`date -u -d @$tmp +%y.%m.%d_%H.%M`_$git_hash
#			echo $Return_Val2
		fi
		popd 1>/dev/null
	done

	Return_Val=${Return_Val:-0}
	return
}

STB820_vcs_get_version() {
	getLastModificationVersion "$STB820_vcs_cmd" $*
}

STB830_vcs_get_version() {
	getLastModificationVersion "$STB830_vcs_cmd" $*
}

# if [ -z "$STB830_SDK" ]; then
# 	if [ -z "$STB820_vcs_cmd" ]; then
# 		detectVCS $PRJROOT/src/apps/StbMainApp/
# 		export STB820_vcs_cmd="$Return_Val"
# 	fi
# 	if [ -z "$STB830_vcs_cmd" ]; then
# 		detectVCS $PRJROOT
# 		export STB830_vcs_cmd="$Return_Val"
# 	fi
# fi
