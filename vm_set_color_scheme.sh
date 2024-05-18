#!/bin/bash

newcs=$1

if [ "${newcs}" == "" ]; then
    newcs="light"
fi

echo ${newcs}> ${PATH_VmColorscheme}


if [ "${newcs}" == "light" ]; then
    echo "Adwaita">${PATH_GTK_THEME_NAME}
else
    echo "Adwaita-dark">${PATH_GTK_THEME_NAME}
fi


echo "配色方案已变更,正在重启图形界面"
# export force_copy_xconf_files=1
${tools_dir}/vm_startx.sh xserver
