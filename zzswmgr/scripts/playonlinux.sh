#!/bin/bash

SWNAME=playonlinux

action=$1
if [ "$action" == "" ]; then action=安装; fi

if [ "${action}" == "卸载" ]; then
	sudo apt-get remove -y ${SWNAME}
else
	sudo apt-get install -y ${SWNAME}
	gxmessage -title "提示" "安装已完成，请查看桌面上的 软件 文件夹"  -center
fi
