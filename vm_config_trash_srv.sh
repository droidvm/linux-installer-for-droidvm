#!/bin/bash

action=$1

gui_title="回收站服务进程"

if [ "$action" == "" ]; then
	action=stop
fi

if [ "$action" == "stop" ]; then
	rm -rf ${app_home}/app_boot_config/trash_enable
	gxmessage -title "${gui_title}" "回收站已禁用，重启生效"  -center
	exit 0
else
	touch ${app_home}/app_boot_config/trash_enable
	gxmessage -title "${gui_title}" "回收站已启用，重启生效。(进程增多，更易卡死)"  -center
fi
