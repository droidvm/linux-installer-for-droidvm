#!/bin/bash

SWNAME=PyWebDAV3
DIR_DESKTOP_FILES=/usr/share/applications

action=$1
if [ "$action" == "" ]; then action=安装; fi

. ./scripts/common.sh

PKGS="python3-webdav"

if [ "${action}" == "卸载" ]; then
	# sudo apt-get remove -y ${SWNAME}
	apt-get autoremove --purge -y ${PKGS}
else
	sudo apt-get install -y ${PKGS}
	exit_if_fail $? "安装失败"

	gxmessage -title "提示" "安装已完成"  -center
fi
