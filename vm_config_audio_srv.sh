#!/bin/bash

action=$1

gui_title="安卓端声音服务进程"

if [ "$action" == "" ]; then
	action=stop
fi

if [ "$action" == "stop" ]; then
    echo "0">${app_home}/app_boot_config/cfg_autostart_audio_service.txt
	gxmessage -title "${gui_title}" "声音播放服务已不会自行启动，重启生效"  -center
	exit 0
else
    rm -rf ${app_home}/app_boot_config/cfg_autostart_audio_service.txt
	gxmessage -title "${gui_title}" "声音播放服务已设置为自行启动，重启生效"  -center
fi
