#!/bin/bash

FS_TARGET=$1
echo
echo   "************************************************************************"
printf "##   %-65s##\n" "Trim $FS_TYPE"
echo   "************************************************************************"

FS_TYPE_U=$(echo $FS_TYPE | tr [:lower:] [:upper:])

#export $FS_TYPE_U=$FS_TARGET
#grep "^\$$FS_TYPE_U" ./trim_fs.txt | xargs echo rm -rf | sh --noprofile -v
prjfilter $FS_TYPE_U=$FS_TARGET ./trim_fs_template.txt ./trim_fs.txt
trim_files=`grep "^$FS_TARGET" ./trim_fs.txt`
echo "Template file names for removing:"
echo $trim_files | tr " " "\n"
rm -rf $trim_files

find $FS_TARGET -name .svn -type d | xargs rm -rf


