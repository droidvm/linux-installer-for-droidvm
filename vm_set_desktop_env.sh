#!/bin/bash

new_de=$1
USE_XFCE4=0


if [ "${new_de}" == "xfce" ]; then
	USE_XFCE4=1
    which startxfce4 >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        USE_XFCE4=0
        gxmessage -title "错误"   $'\nxfce4未安装\n'  -center
        exit 0
    fi
fi


if [ ${USE_XFCE4} -eq 1 ]; then
    echo "1" > ${app_home}/app_boot_config/cfg_use_xfce4.txt
else
    echo "0" > ${app_home}/app_boot_config/cfg_use_xfce4.txt
fi



/exbin/tools/vm_startx.sh xwinman
