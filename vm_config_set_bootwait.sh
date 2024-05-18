#!/bin/bash

action=$1

gui_title="启动等待秒数"

if [ "$action" == "" ]; then
	action=stop
fi

if [ "$action" == "stop" ]; then
    rm -rf ${app_home}/app_boot_config/cfg_bootup_wait_seconds.txt
	gxmessage -title "${gui_title}" "已设置为不等待，重启生效"  -center
	exit 0
else
	echo "3">${app_home}/app_boot_config/cfg_bootup_wait_seconds.txt
	gxmessage -title "${gui_title}" "已设置为3秒，重启生效"  -center
fi
