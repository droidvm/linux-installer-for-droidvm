#!/bin/bash

SWNAME=vlc

action=$1
if [ "$action" == "" ]; then action=安装; fi

. ./scripts/common.sh

if [ "${action}" == "卸载" ]; then
	apt-get autoremove --purge -y ${SWNAME}
else
	sudo apt-get install -y --allow-downgrades ${SWNAME}
	exit_if_fail $? "安装失败"
	gxmessage -title "提示" "安装已完成"  -center &
fi
