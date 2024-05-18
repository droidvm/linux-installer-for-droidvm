#!/bin/bash

action=$1

gui_title="虚拟系统根目录设置"

if [ "$action" == "" ]; then
	action=unzip_path
fi

if [ "$action" == "sameAsHost" ]; then
	MSG="虚拟系统已设置为 以宿主根目录为根目录 示例 => /exbin/n/arm64"
	echo "">${app_home}/app_boot_config/cfg_rootfs_sameAsHost.txt
else
	MSG="虚拟系统已设置为 以解压缩路径为根目录"
	rm -rf  ${app_home}/app_boot_config/cfg_rootfs_sameAsHost.txt
fi

gxmessage -title "${gui_title}" "${MSG}  ，重启生效" -center -buttons "立即重启:1,稍后重启:0"
if [ $? -eq 1 ]; then
    exec /exbin/tools/vm_OSReboot.sh
fi
