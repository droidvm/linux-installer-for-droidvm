#!/bin/bash

action=$1

gui_title="proot设置"

if [ "$action" == "" ]; then
	action=userland-box86
fi

if [ "$action" == "termux-box86" ]; then
	proot_selected=proot-termux-box86
elif [ "$action" == "userland-box86" ]; then
	proot_selected=proot-userland-box86
elif [ "$action" == "userland-ndk" ]; then
	proot_selected=proot-userland-ndk
elif [ "$action" == "userbinfmt" ]; then
	proot_selected=proot-userbinfmt
fi

if [ "${proot_selected}" != "" ]; then
	echo "${proot_selected}">${app_home}/app_boot_config/cfg_proot_name.txt
	gxmessage -title "${gui_title}" "已设置为 ${proot_selected}  ，重启生效"  -center
	exit 0
fi
