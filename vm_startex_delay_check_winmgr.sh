#!/bin/bash

rm -rf /tmp/xwindowmgr_started

source ${tools_dir}/vm_configx.sh

function checkif_xwindowmgr_started() {
	if [ -f /tmp/xwindowmgr_started ]; then
		echo "xwindowmgr 启动成功"  > ${APP_STDIO_NAME}
	else
		echo -e "\n\nxwindowmgr 启动失败\n当前xserver: ${XSRV_NAME}\n正在切换成Xvfb\n请重新打开虚拟电脑\n\n" | tee "/exbin/tmp/promptmsg.txt"  > ${APP_STDIO_NAME}
		echo2apk "#promptmsg"

		echo "Xvfb xlorie">${DirGuiConf}/xserver_order.txt
	fi
}

sleep 8
checkif_xwindowmgr_started

