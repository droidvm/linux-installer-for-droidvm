#!/bin/bash

SWNAME=xpra
DIR_DESKTOP_FILES=/usr/share/applications

action=$1
if [ "$action" == "" ]; then action=安装; fi

. ./scripts/common.sh

PKGS="xpra"

if [ "${action}" == "卸载" ]; then
	# sudo apt-get remove -y ${SWNAME}
	apt-get autoremove --purge -y ${PKGS}
else
	sudo apt-get install -y ${PKGS}
	exit_if_fail $? "安装失败"

	# 处理 debian 系统发行版中 "/etc/X11/Xsession true" 运行报错的问题
	# xpra Xsession: unable to launch "true" X session --- "true" not executable
	cp -f ./scripts/res/20x11-common_process-args  /etc/X11/Xsession.d/

	gxmessage -title "提示" "安装已完成"  -center
fi
