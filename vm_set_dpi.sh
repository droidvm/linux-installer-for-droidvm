#!/bin/bash

newdpi=$1

if [ "${newdpi}" == "" ]; then
    newdpi=150
fi


echo ${newdpi}> ${PATH_VMDPI}

echo "DPI已变更,正在重启图形界面"
# export force_copy_xconf_files=1
${tools_dir}/vm_startx.sh xserver
