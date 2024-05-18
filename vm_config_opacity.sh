#!/bin/bash

which compton >/dev/null 2>&1
if [ $? -ne 0 ]; then
    gxmessage -title "错误" "请先在软件管家中安装 compton"  -center
    exit 1
fi

gui_title="透明效果"
PID=$(pidof compton)
echo PID:$PID

action=$1
if [ "$action" == "" ]; then
	action=off
fi

if [ "$action" == "off" ]; then
	rm -rf ${app_home}/app_boot_config/opacity_enable
	if [ "$PID" == "" ]; then
		exit 0
	  else
		${app_home}/busybox kill $PID
		rlt=$?
		exit $rlt
	fi
fi

touch ${app_home}/app_boot_config/opacity_enable


if [ "$PID" != "" ]; then
	echo "已经启动"
	exit 0
fi

echo "正在启动"
compton &
